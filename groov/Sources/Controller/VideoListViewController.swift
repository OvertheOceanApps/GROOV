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

class VideoListViewController: BaseViewController {
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
    
    private let cellIdentifier: String = "VideoListCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.videoList
        
        videoTableView.register(VideoListTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        loadVideos()
        initComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarClear()
        setNavigationBackButton()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayerView.pauseVideo()
        videoPaused()
    }
    
    func initComponents() {
        videoPlayerView.delegate = self
        progressImageView.setWidth(view.width)
        searchVideoButton.setImage(UIImage(named: L10n.imgSearchVideo), for: .normal)
    }
    
    func initProgress() {
        let totalDuration: Int = Int(videoPlayerView.duration())
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        
        progressBackgroundView.setWidth(0)
    }
}

// MARK: Timer Control
extension VideoListViewController {
    func startTimer() {
        guard durationTimer == nil else { return }
        
        let ti: Double = 0.5
        durationTimer = Timer.scheduledTimer(withTimeInterval: ti, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.checkVideoCurrentTime()
        })
    }
    
    func stopTimer() {
        guard durationTimer != nil else { return }
        durationTimer.invalidate()
        durationTimer = nil
    }
}

// MARK: Video List Data
extension VideoListViewController {
    func loadVideos() {
        let realm = try! Realm()
        videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", playlist.id).sorted(byKeyPath: "order"))
        if videoArray.count > 0 {
            videoTableView.reloadData()
            videoSelected(0, play: false)
        }
        setBlankViewHidden()
    }
    
    func videoSelected(_ index: Int, play: Bool) {
        autoPlay = play
        
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoListTableViewCell {
            selectedCell.cellSelected(true)
            
            if currentSelectedCell != nil && currentSelectedCell != selectedCell {
                videoPaused()
                currentSelectedCell.cellSelected(false)
            }
            
            currentSelectedCell = selectedCell
        }
        
        updateCurrentVideoInfo(videoArray[index], play: play)
        loadVideoById(currentVideo.videoId)
        videoTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }
    
    func updateCurrentVideoInfo(_ video: Video, play: Bool) {
        currentVideo = video
        navigationItem.title = video.title
    }
}

// MARK: SearchViewControllerDelegate
extension VideoListViewController: SearchViewControllerDelegate {
    func videoAdded(_ video: Video) {
        let realm = try! Realm()
        try! realm.write { [weak self] in
            guard let self = self else { return }
            
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
        
        videoArray.append(video)
        setBlankViewHidden()
        videoTableView.beginUpdates()
        let indexPath = IndexPath(row: videoArray.count-1, section: 0)
        videoTableView.insertRows(at: [indexPath], with: .automatic)
        videoTableView.endUpdates()
        
        if let selectedCell = videoTableView.cellForRow(at: indexPath) as? VideoListTableViewCell {
            if currentSelectedCell == nil && videoArray.count > 0 {
                currentSelectedCell = selectedCell
                videoSelected(indexPath.row, play: false)
            }
        }
        
        delegate?.recentVideoChanged(playlist)
    }
    
    func setBlankViewHidden() {
        var hidden: Bool = true
        if videoArray.count == 0 {
            hidden = false
        }
        blankView.isHidden = hidden
        durationWrapperView.isHidden = !hidden
        videoControlView.isHidden = !hidden
        videoPlayerView.isHidden = !hidden
        videoTableView.isHidden = !hidden
    }
}

// MARK: Player Methods
extension VideoListViewController {
    func loadVideoById(_ vId: String) {
        let vars = ["playsinline": 1, "controls": 0, "showinfo": 0, "modestbranding": 1, "rel": 0, "fs": 0]
        videoPlayerView.load(withVideoId: vId, playerVars: vars)
    }
    
    func getNextVideoIndex() -> Int {
        if let currentIndex = videoArray.find({$0 == currentVideo}) {
            return currentIndex + 1 >= videoArray.count ? 0 : currentIndex + 1
        }
        return 0
    }
    
    func getPreviousVideoIndex() -> Int {
        if let currentIndex = videoArray.find({$0 == currentVideo}) {
            return currentIndex - 1 < 0 ? videoArray.count - 1 : currentIndex - 1
        }
        return 0
    }
    
    func videoPlayed() {
        currentPlayState = PlayState.Play
        playPauseButton.setImage(Asset.videoControlPause.image, for: .normal)
        if currentSelectedCell != nil {
            currentSelectedCell.videoPlayed()
        }
    }
    
    func videoPaused() {
        currentPlayState = PlayState.Pause
        playPauseButton.setImage(Asset.videoControlPlay.image, for: .normal)
        if currentSelectedCell != nil {
            currentSelectedCell.videoPaused()
        }
    }
}

// MARK: YT Player View Delegate
extension VideoListViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if autoPlay {
            videoPlayerView.playVideo()
            videoPlayed()
        }
        initProgress()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .ended:
            videoSelected(getNextVideoIndex(), play: true)
        default: break
        }
    }
}

// MARK: Table View Datasource, Delegate
extension VideoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VideoListTableViewCell
        cell.updateVideo(videoArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = videoTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? VideoListTableViewCell
        if currentSelectedCell != nil && selectedCell == currentSelectedCell {
            // user selected current playing cell
            if currentPlayState == PlayState.Play { // play -> pause
                videoPlayerView.pauseVideo()
                videoPaused()
            } else { // pause -> play
                videoPlayerView.playVideo()
                videoPlayed()
            }
        } else { // else -> play
            videoSelected(indexPath.row, play: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction.init(style: .normal, title: L10n.delete) { [weak self] (_, indexPath) in
            guard let self = self else { return }
            self.tableView(self.videoTableView, commit: .delete, forRowAt: indexPath)
        }
        deleteAction.backgroundColor = GRVColor.tableviewRowDeleteColor
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let parentId = playlist.id
            let targetId = videoArray[indexPath.row].id
            videoArray.remove(at: indexPath.row)
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
            videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", parentId).sorted(byKeyPath: "order"))
            setBlankViewHidden()
        }
    }
}

// MARK: IBActions
extension VideoListViewController {
    @IBAction func searchVideoButtonClicked() {
        let vc: SearchViewController = SearchViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func toggleControlView() {
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            guard let self = self else { return }
            self.controlView.alpha = self.controlView.alpha == 1 ? 0 : 1
        })
    }
    
    @IBAction func previousButtonClicked() {
        videoSelected(getPreviousVideoIndex(), play: true)
        videoPlayed()
    }
    
    @IBAction func nextButtonClicked() {
        videoSelected(getNextVideoIndex(), play: true)
        videoPlayed()
    }
    
    @IBAction func playPauseButtonClicked() {
        if currentPlayState == PlayState.Pause {
            videoPlayerView.playVideo()
            videoPlayed()
        } else {
            videoPlayerView.pauseVideo()
            videoPaused()
        }
    }
}

// MARK: Ask App Store Review and Star Rate
extension VideoListViewController {
    @objc func checkVideoCurrentTime() {
        if videoPlayerView.playerState() == .playing {
            let currentTime: Int = Int(videoPlayerView.currentTime())
            let totalDuration: Int = Int(videoPlayerView.duration())
            
            let currentTimeString: String = String.init(hms: currentTime.secToHMS())
            let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
            runningTimeLabel.text = "\(currentTimeString) / \(totalDurationString)"
            
            let progress: CGFloat = CGFloat(currentTime) / CGFloat(totalDuration)
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let self = self else { return }
                self.progressBackgroundView.setWidth(self.durationWrapperView.width * progress)
            })
            
            totalPlayTime += 0.5
            if totalPlayTime >= 10 {
                askReview()
            }
        }
    }
    
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
