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
import YoutubeKit

protocol VideoListViewControllerDelegate: class {
    func recentVideoChanged(_ playlist: Playlist)
}

class VideoListViewController: BaseViewController {
    @IBOutlet var videoPlayerContainerView: UIView!
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
    
    let videoPlayer: YTSwiftyPlayer = YTSwiftyPlayer(playerVars: [.showControls(.hidden),
                                                                  .showModestbranding(true),
                                                                  .playsInline(true),
                                                                  .showInfo(false),
                                                                  .showFullScreenButton(false),
                                                                  .showRelatedVideo(false)])
    
    weak var delegate: VideoListViewControllerDelegate?
    var playlist: Playlist! = nil
    var videoArray: Array<Video> = []
    var currentVideo: Video! = nil
    var autoPlay: Bool = false
    var currentPlayState: String! = PlayState.Pause
    var currentSelectedCell: VideoListTableViewCell!
    var totalPlayTime: Float = 0 // for review. review time > 10s -> review request
    var reviewAsked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.videoList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isMovingToParent {
            initComponents()
            loadVideos()
        }
        
        setNavigationBarClear()
        setNavigationBackButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayer.pauseVideo()
        videoPaused()
    }
    
    func initComponents() {
        videoPlayerContainerView.addSubview(videoPlayer)
        
        videoPlayer.delegate = self
        videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.leadingAnchor.constraint(equalTo: videoPlayerContainerView.leadingAnchor).isActive = true
        videoPlayer.trailingAnchor.constraint(equalTo: videoPlayerContainerView.trailingAnchor).isActive = true
        videoPlayer.topAnchor.constraint(equalTo: videoPlayerContainerView.topAnchor).isActive = true
        videoPlayer.bottomAnchor.constraint(equalTo: videoPlayerContainerView.bottomAnchor).isActive = true
        videoPlayer.loadPlayer()
        
        progressImageView.setWidth(view.width)
        searchVideoButton.setImage(UIImage(named: L10n.imgSearchVideo), for: .normal)
    }
    
    func initProgress() {
        let totalDuration: Int = Int(videoPlayer.duration ?? 0)
        let totalDurationString: String = String(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        
        progressBackgroundView.setWidth(0)
    }
}

// MARK: - Video List Data
extension VideoListViewController {
    func loadVideos() {
        let realm = try! Realm()
        videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", playlist.id).sorted(byKeyPath: "order"))
        if videoArray.count > 0 {
            videoTableView.reloadData()
        }
        setBlankViewHidden()
    }
    
    func videoSelected(_ index: Int, play: Bool) {
        autoPlay = play
        
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoListTableViewCell {
            selectedCell.titleLabel.textColor = UIColor.white
            selectedCell.channelLabel.textColor = UIColor.white
            selectedCell.durationLabel.textColor = GRVColor.mainTextColor
            selectedCell.showProgress()
            
            if currentSelectedCell != nil && currentSelectedCell != selectedCell {
                videoPaused()
                currentSelectedCell.titleLabel.textColor = GRVColor.mainTextColor
                currentSelectedCell.channelLabel.textColor = GRVColor.mainTextColor
                currentSelectedCell.hideProgress()
            }
            
            currentSelectedCell = selectedCell
        }
        
        updateCurrentVideoInfo(videoArray[index])
        if play {
            loadVideoById(currentVideo.videoId)
        } else {
            videoPlayer.cueVideo(videoID: currentVideo.videoId)
        }
        videoTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
    }
    
    func updateCurrentVideoInfo(_ video: Video) {
        currentVideo = video
        navigationItem.title = video.title
    }
    
    func setBlankViewHidden() {
        var hidden: Bool = true
        if videoArray.count == 0 {
            hidden = false
        }
        blankView.isHidden = hidden
        durationWrapperView.isHidden = !hidden
        videoControlView.isHidden = !hidden
        videoPlayer.isHidden = !hidden
        videoTableView.isHidden = !hidden
    }
}

// MARK: - SearchViewControllerDelegate
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
}

// MARK: - Player Methods
extension VideoListViewController {
    func loadVideoById(_ vId: String) {
        videoPlayer.loadVideo(videoID: vId)
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

// MARK: - YTSwiftyPlayerDelegate
extension VideoListViewController: YTSwiftyPlayerDelegate {
    func playerReady(_ player: YTSwiftyPlayer) {
        if videoArray.isEmpty == false {
            videoSelected(0, play: false)
        }
        
        if autoPlay {
            videoPlayer.playVideo()
            videoPlayed()
        }
        initProgress()
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        switch state {
        case .ended:
            videoSelected(getNextVideoIndex(), play: true)
        default:
            break
        }
    }
    
    func player(_ player: YTSwiftyPlayer, didUpdateCurrentTime currentTime: Double) {
        updateProgress(by: currentTime)
    }
    
    func player(_ player: YTSwiftyPlayer, didReceiveError error: YTSwiftyPlayerError) {
        print(#function, error)
    }
}

// MARK: - Table View Datasource, Delegate
extension VideoListViewController: UITableViewDataSource, UITableViewDelegate {
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
        let selectedCell = videoTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? VideoListTableViewCell
        if currentSelectedCell != nil && selectedCell == currentSelectedCell {
            // user selected current playing cell
            if currentPlayState == PlayState.Play { // play -> pause
                videoPlayer.pauseVideo()
                videoPaused()
            } else { // pause -> play
                videoPlayer.playVideo()
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

// MARK: - IBActions
extension VideoListViewController {
    @IBAction func searchVideoButtonClicked() {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: StoryboardId.Search) as! SearchViewController
        searchVC.delegate = self
        let navController = UINavigationController(rootViewController: searchVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
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
            videoPlayer.playVideo()
            videoPlayed()
        } else {
            videoPlayer.pauseVideo()
            videoPaused()
        }
    }
}

// MARK: - Ask App Store Review and Star Rate
extension VideoListViewController {
    func updateProgress(by currentTime: Double) {
        guard videoPlayer.playerState == .playing, let duration = videoPlayer.duration else { return }
        let currentTime: Int = Int(currentTime)
        let totalDuration: Int = Int(duration)
        
        let currentTimeString: String = String(hms: currentTime.secToHMS())
        let totalDurationString: String = String(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "\(currentTimeString) / \(totalDurationString)"
        
        let progress: CGFloat = CGFloat(currentTime) / CGFloat(totalDuration)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.progressBackgroundView.setWidth(self.durationWrapperView.width * progress)
        })
        
        totalPlayTime += 0.5
        if totalPlayTime >= 10 {
            askReview()
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
