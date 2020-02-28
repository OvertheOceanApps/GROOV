//
//  VideoListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftMessages
import StoreKit

protocol VideoListViewControllerDelegate: class {
    func recentVideoChanged(_ playlist: Playlist)
}

class VideoListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate, SearchViewControllerDelegate {
    @IBOutlet var videoPlayerView: YTPlayerView!
    @IBOutlet var videoTableView: UITableView!
    @IBOutlet var blankView: UIView!
    @IBOutlet var durationWrapperView: UIView!
    @IBOutlet var videoControlView: UIView!
    @IBOutlet var controlView: UIView!
    @IBOutlet var runningTimeLabel: UILabel!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var progressImageView: UIImageView!
    @IBOutlet var progressBackgroundView: UIView!
    @IBOutlet var videoPlayerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var searchVideoButton: UIButton!
    
    weak var delegate: VideoListViewControllerDelegate?
    var playlist: Playlist! = nil
    var videoArray: Array<Video> = []
    var currentVideo: Video! = nil
    var autoPlay: Bool = false
    var currentPlayState: String! = PlayState.Pause
    var currentSelectedCell: VideoListTableViewCell!
    var durationTimer: Timer! = nil
    var totalPlayTime: Float = 0 // for review. review time > 10s -> review request
    var reviewAsked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.videoList
        self.loadVideos()
        self.initComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarClear()
        self.setNavigationBackButton()
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoPlayerView.pauseVideo()
        self.videoPaused()
    }
    
    func initComponents() {
        self.videoPlayerView.delegate = self
        self.progressImageView.setWidth(self.view.width)
        self.searchVideoButton.setImage(UIImage(named: L10n.imgSearchVideo), for: .normal)
    }
    
    func initProgress() {
        let totalDuration: Int = Int(self.videoPlayerView.duration())
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        
        self.progressBackgroundView.setWidth(0)
    }
}

// MARK: Timer Control
extension VideoListViewController {
    
    func startTimer() {
        guard self.durationTimer == nil else { return }
        
        let ti: Double = 0.5
        if #available(iOS 10.0, *) {
            self.durationTimer = Timer.scheduledTimer(withTimeInterval: ti, repeats: true, block: { _ in
                self.checkVideoCurrentTime()
            })
        } else {
            self.durationTimer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(checkVideoCurrentTime), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        guard self.durationTimer != nil else { return }
        self.durationTimer.invalidate()
        self.durationTimer = nil
    }
}

// MARK: Video List Data
extension VideoListViewController {
    
    func loadVideos() {
        let realm = try! Realm()
        self.videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", self.playlist.id).sorted(byKeyPath: "order"))
        if self.videoArray.count > 0 {
            self.videoTableView.reloadData()
            self.videoSelected(0, play: false)
        }
        self.setBlankViewHidden()
    }
    
    func videoSelected(_ index: Int, play: Bool) {
        autoPlay = play
        
        if let selectedCell = self.videoTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoListTableViewCell {
            selectedCell.titleLabel.textColor = UIColor.white
            selectedCell.channelLabel.textColor = UIColor.white
            selectedCell.durationLabel.textColor = GRVColor.mainTextColor
            selectedCell.showProgress()
            
            if self.currentSelectedCell != nil && self.currentSelectedCell != selectedCell {
                self.videoPaused()
                self.currentSelectedCell.titleLabel.textColor = GRVColor.mainTextColor
                self.currentSelectedCell.channelLabel.textColor = GRVColor.mainTextColor
                self.currentSelectedCell.hideProgress()
            }
            
            self.currentSelectedCell = selectedCell
        }
        
        self.updateCurrentVideoInfo(videoArray[index], play: play)
        self.loadVideoById(currentVideo.videoId)
        self.videoTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }
    
    func updateCurrentVideoInfo(_ video: Video, play: Bool) {
        self.currentVideo = video
        self.navigationItem.title = video.title
    }
    
    func videoAdded(_ video: Video) {
        let realm = try! Realm()
        try! realm.write {
            video.createdAt = NSDate() as Date
            video.playlistId = playlist.id
            video.order = self.videoArray.count
            realm.add(video)
            playlist.recentVideo = video.title
            
            TrackUtil.sendVideoAddedEvent(title: video.title)
            
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(.success)
            warning.configureDropShadow()
            
            warning.configureTheme(backgroundColor: UIColor.init(netHex: 0x292b30), foregroundColor: UIColor.white)
            warning.configureContent(title: L10n.videoAddComplete, body: "\(video.title)")
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: .statusBar)
            warningConfig.duration = .seconds(seconds: 0.3)
            
            SwiftMessages.show(config: warningConfig, view: warning)
        }
        
        self.videoArray.append(video)
        self.setBlankViewHidden()
        self.videoTableView.beginUpdates()
        let indexPath = IndexPath(row: self.videoArray.count-1, section: 0)
        self.videoTableView.insertRows(at: [indexPath], with: .automatic)
        self.videoTableView.endUpdates()
        
        if let selectedCell = self.videoTableView.cellForRow(at: indexPath) as? VideoListTableViewCell {
            if self.currentSelectedCell == nil && self.videoArray.count > 0 {
                self.currentSelectedCell = selectedCell
                self.videoSelected(indexPath.row, play: false)
            }
        }
        
        delegate?.recentVideoChanged(playlist)
    }
    
    func setBlankViewHidden() {
        var hidden: Bool = true
        if self.videoArray.count == 0 {
            hidden = false
        }
        self.blankView.isHidden = hidden
        self.durationWrapperView.isHidden = !hidden
        self.videoControlView.isHidden = !hidden
        self.videoPlayerView.isHidden = !hidden
        self.videoTableView.isHidden = !hidden
    }
}

// MARK: Player Methods
extension VideoListViewController {
    
    func loadVideoById(_ vId: String) {
        let vars = ["playsinline": 1, "controls": 0, "showinfo": 0, "modestbranding": 1, "rel": 0, "fs": 0]
        self.videoPlayerView.load(withVideoId: vId, playerVars: vars)
    }
    
    func getNextVideoIndex() -> Int {
        if let currentIndex = self.videoArray.find({$0 == self.currentVideo}) {
            return currentIndex + 1 >= self.videoArray.count ? 0 : currentIndex + 1
        }
        return 0
    }
    
    func getPreviousVideoIndex() -> Int {
        if let currentIndex = self.videoArray.find({$0 == self.currentVideo}) {
            return currentIndex - 1 < 0 ? self.videoArray.count - 1 : currentIndex - 1
        }
        return 0
    }
    
    func videoPlayed() {
        self.currentPlayState = PlayState.Play
        self.playPauseButton.setImage(Asset.videoControlPause.image, for: .normal)
        if self.currentSelectedCell != nil {
            self.currentSelectedCell.videoPlayed()
        }
    }
    
    func videoPaused() {
        self.currentPlayState = PlayState.Pause
        self.playPauseButton.setImage(Asset.videoControlPlay.image, for: .normal)
        if self.currentSelectedCell != nil {
            self.currentSelectedCell.videoPaused()
        }
    }
}

// MARK: YT Player View Delegate
extension VideoListViewController {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if autoPlay {
            self.videoPlayerView.playVideo()
            self.videoPlayed()
        }
        self.initProgress()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case YTPlayerState.playing:
            print("Video playing")
        case YTPlayerState.paused:
            print("Video paused")
        case YTPlayerState.ended:
            self.videoSelected(self.getNextVideoIndex(), play: true)
        default:
            print("other")
        }
    }
}

// MARK: Table View Datasource, Delegate
extension VideoListViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCellIdentifier", for: indexPath) as! VideoListTableViewCell
        cell.initCell(videoArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = self.videoTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? VideoListTableViewCell
        if self.currentSelectedCell != nil && selectedCell == self.currentSelectedCell { // user selected current playing cell
            if currentPlayState == PlayState.Play { // play -> pause
                self.videoPlayerView.pauseVideo()
                self.videoPaused()
            } else { // pause -> play
                self.videoPlayerView.playVideo()
                self.videoPlayed()
            }
        } else { // else -> play
            self.videoSelected(indexPath.row, play: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction.init(style: .normal, title: L10n.delete) { (_, indexPath) in
            self.tableView(self.videoTableView, commit: .delete, forRowAt: indexPath)
        }
        deleteAction.backgroundColor = GRVColor.tableviewRowDeleteColor
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let parentId = self.playlist.id
            let targetId = self.videoArray[indexPath.row].id
            self.videoArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // db work in background
            let realm = try! Realm()
            // delete target video
            if let v = realm.objects(Video.self).filter("id = %@", targetId).first {
                try! realm.write {
                    realm.delete(v)
                }
            }
            // reorder all video
            for (idx, v) in Array(realm.objects(Video.self).filter("playlistId = %@", parentId).sorted(byKeyPath: "order")).enumerated() {
                try! realm.write {
                    v.order = idx
                }
            }
            self.videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", parentId).sorted(byKeyPath: "order"))
            self.setBlankViewHidden()
        }
    }
}

// MARK: IBActions
extension VideoListViewController {
    
    @IBAction func searchVideoButtonClicked() {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.Search) as! SearchViewController
        searchVC.delegate = self
        let navController = UINavigationController(rootViewController: searchVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func toggleControlView() {
        if self.controlView.alpha == 1 {
            UIView.animate(withDuration: 0.4, animations: {
                self.controlView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.controlView.alpha = 1
            })
        }
    }
    
    @IBAction func previousButtonClicked() {
        self.videoSelected(self.getPreviousVideoIndex(), play: true)
        self.videoPlayed()
    }
    
    @IBAction func nextButtonClicked() {
        self.videoSelected(self.getNextVideoIndex(), play: true)
        self.videoPlayed()
    }
    
    @IBAction func playPauseButtonClicked() {
        if currentPlayState == PlayState.Pause {
            self.videoPlayerView.playVideo()
            self.videoPlayed()
        } else {
            self.videoPlayerView.pauseVideo()
            self.videoPaused()
        }
    }
}

// MARK: Ask App Store Review and Star Rate
extension VideoListViewController {
    
    @objc func checkVideoCurrentTime() {
        if self.videoPlayerView.playerState() == .playing {
            let currentTime: Int = Int(self.videoPlayerView.currentTime())
            let totalDuration: Int = Int(self.videoPlayerView.duration())
            
            let currentTimeString: String = String.init(hms: currentTime.secToHMS())
            let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
            runningTimeLabel.text = "\(currentTimeString) / \(totalDurationString)"
            
            let progress: CGFloat = CGFloat(currentTime) / CGFloat(totalDuration)
            UIView.animate(withDuration: 0.5, animations: {
                self.progressBackgroundView.setWidth(self.durationWrapperView.width * progress)
            })
            
            totalPlayTime += 0.5
            if totalPlayTime >= 10 {
                if #available(iOS 10.3, *) {
                    self.askReview()
                }
            }
        }
    }
    
    @available(iOS 10.3, *)
    func askReview() {
        if reviewAsked == false {
            reviewAsked = true
            
            let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            if UserDefaults.standard.object(forKey: ver) != nil {
                return
            }
            
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set("Y", forKey: ver)
        }
    }
}
