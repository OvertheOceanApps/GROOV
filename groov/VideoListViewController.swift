//
//  VideoListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RealmSwift
import AssistantKit
import SwiftMessages
import StoreKit

protocol VideoListViewControllerDelegate {
    func recentVideoChanged(_ playlist: Playlist)
}

class VideoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, YTPlayerViewDelegate, SearchViewControllerDelegate {
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
    
    var delegate: VideoListViewControllerDelegate!
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
        self.navigationItem.title = "Video List"
        self.setNavigationBar()
        self.loadVideos()
        self.setUpComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar()
        self.startTimer()
    }
    
    func startTimer() {
        guard self.durationTimer == nil else { return }
        
        let ti: Double = 0.5
        if #available(iOS 10.0, *) {
            self.durationTimer = Timer.scheduledTimer(withTimeInterval: ti, repeats: true, block: { (timer) in
                self.checkVideoCurrentTime()
            })
        } else {
            self.durationTimer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(checkVideoCurrentTime), userInfo: nil, repeats: true)
        }
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    func stopTimer() {
        guard self.durationTimer != nil else { return }
        self.durationTimer.invalidate()
        self.durationTimer = nil
    }
    
    func setNavigationBar() {
        // set navigation title text font
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]

        // set navigation back button
        let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigation_back"), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        // set navigation clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        
        // design change under iOS 11
        if UIDevice().userInterfaceIdiom == .phone
        && Device.osVersion < Device.os11 { // iOS 10
            videoPlayerViewTopConstraint.constant = -64
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissVC() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoPlayerView.pauseVideo()
        self.videoPaused()
    }
    
    func setUpComponents() {
        self.videoPlayerView.delegate = self
        self.progressImageView.setWidth(self.view.width)
    }
    
    func loadVideos() {
        let realm = try! Realm()
        self.videoArray = Array(realm.objects(Video.self).filter("playlistId = %@", self.playlist.id).sorted(byKeyPath: "order"))
        if self.videoArray.count > 0 {
            self.videoTableView.reloadData()
            self.videoSelected(0, play: false)
        }
        self.setBlankViewHidden()
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
    
    func loadVideoById(_ vId: String) {
        let vars = ["playsinline": 1, "controls": 0, "showinfo": 0, "modestbranding": 1, "rel": 0, "fs": 0]
        self.videoPlayerView.load(withVideoId: vId, playerVars: vars)
    }
    
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
            self.videoSelected(indexPath.row, play:true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction.init(style: .normal, title: "삭제하기") { (action, indexPath) in
            self.tableView(self.videoTableView, commit: .delete, forRowAt: indexPath)
        }
        deleteAction.backgroundColor = GRVColor.tableviewRowDeleteColor
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if autoPlay {
            self.videoPlayerView.playVideo()
            self.videoPlayed()
        }
        self.initProgress()
    }
    
    func initProgress() {
        let totalDuration: Int = Int(self.videoPlayerView.duration())
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        
        self.progressBackgroundView.setWidth(0)
        
//        if self.currentSelectedCell != nil {
//            self.currentSelectedCell.progressChanged(p: 0)
//        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch(state) {
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
    
    @IBAction func searchVideoButtonClicked() {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        searchVC.delegate = self
        let navController = UINavigationController(rootViewController: searchVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    func videoAdded(_ video: Video) {
        let realm = try! Realm()
        try! realm.write {
            video.createdAt = NSDate() as Date
            video.playlistId = playlist.id
            video.order = self.videoArray.count
            realm.add(video)
            playlist.recentVideo = video.title
            
            
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(.success)
            warning.configureDropShadow()

            warning.configureTheme(backgroundColor: UIColor.init(netHex: 0x292b30), foregroundColor: UIColor.white)
            warning.configureContent(title: "비디오 추가 완료", body: "\(video.title)")
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            warningConfig.duration = .seconds(seconds: 0.2)

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
        
        delegate.recentVideoChanged(playlist)
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
    
    func videoPlayed() {
        self.currentPlayState = PlayState.Play
        self.playPauseButton.setImage(#imageLiteral(resourceName: "video_control_pause"), for: .normal)
        if self.currentSelectedCell != nil {
            self.currentSelectedCell.videoPlayed()
        }
    }
    
    func videoPaused() {
        self.currentPlayState = PlayState.Pause
        self.playPauseButton.setImage(#imageLiteral(resourceName: "video_control_play"), for: .normal)
        if self.currentSelectedCell != nil {
            self.currentSelectedCell.videoPaused()
        }
    }
}
