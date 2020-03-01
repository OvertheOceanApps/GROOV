//
//  VideoListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import RealmSwift
import SwiftMessages
import StoreKit
import YoutubeKit

protocol VideoListViewControllerDelegate: class {
    func recentVideoChanged(_ playlist: Playlist)
}

class VideoListViewController: BaseViewController {
    private let searchBarButton: UIBarButtonItem = UIBarButtonItem(image: Asset.searchFavicon.image, style: .plain, target: nil, action: nil)
    private let blankView: BlankView = BlankView(.video)
    private let videoPlayer: YTSwiftyPlayer = YTSwiftyPlayer()
    private let videoTableView: UITableView = UITableView()
    private let durationView: UIView = UIView()
    private let videoControlView: UIControl = UIControl()
    private let videoControlContentView: UIControl = UIControl()
    private let runningTimeLabel: UILabel = UILabel()
    private let previousButton: UIButton = UIButton(type: .system)
    private let forwardButton: UIButton = UIButton(type: .system)
    private let playPauseButton: UIButton = UIButton(type: .system)
    private let progressImageView: UIImageView = UIImageView()
    private let controlMaskImageView: UIImageView = UIImageView()
    
    var progressImageViewWidth: Constraint?
    
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
    
    override func addSubviews() {
        super.addSubviews()
        
        navigationItem.rightBarButtonItem = searchBarButton
        
        view.addSubview(blankView)
        view.addSubview(videoPlayer)
        view.addSubview(videoTableView)
        view.addSubview(durationView)
        view.addSubview(videoControlView)
        
        durationView.addSubview(runningTimeLabel)
        durationView.addSubview(progressImageView)
        
        videoControlView.addSubview(videoControlContentView)
        videoControlContentView.addSubview(controlMaskImageView)
        videoControlContentView.addSubview(previousButton)
        videoControlContentView.addSubview(forwardButton)
        videoControlContentView.addSubview(playPauseButton)
        
        videoTableView.register(VideoListTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
        
    override func layout() {
        super.layout()
        
        blankView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        videoPlayer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        
        videoTableView.snp.makeConstraints {
            $0.top.equalTo(videoPlayer.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        durationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        
        videoControlView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.snp.width).multipliedBy(9.0/16.0)
        }
        
        videoControlContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        progressImageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            progressImageViewWidth = $0.width.equalTo(0).constraint
            $0.height.equalTo(1)
        }
        
        runningTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(100)
            $0.height.equalTo(15)
        }
        
        controlMaskImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        previousButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(50)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        forwardButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(50)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        playPauseButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(44)
        }
    }
        
    override func style() {
        super.style()
        
        navigationItem.title = L10n.videoList
        
        view.backgroundColor = GRVColor.backgroundColor
        
        searchBarButton.tintColor = UIColor.white
        
        videoTableView.backgroundColor = GRVColor.backgroundColor
        
        progressImageView.contentMode = .scaleAspectFill
        progressImageView.clipsToBounds = true
        progressImageView.image = Asset.loadingGradation.image
        
        runningTimeLabel.text = "0:00:00 / 0:00:00"
        runningTimeLabel.textAlignment = .right
        runningTimeLabel.textColor = UIColor(netHex: 0xCCCCCC)
        runningTimeLabel.font = UIFont.systemFont(ofSize: 9)
        
        controlMaskImageView.contentMode = .scaleAspectFill
        controlMaskImageView.clipsToBounds = true
        controlMaskImageView.image = Asset.videoControlBackground.image
        
        previousButton.setImage(Asset.videoControlPrevious.image, for: .normal)
        previousButton.tintColor = UIColor.white
        
        forwardButton.setImage(Asset.videoControlForward.image, for: .normal)
        forwardButton.tintColor = UIColor.white
        
        playPauseButton.setImage(Asset.videoControlPlay.image, for: .normal)
        playPauseButton.tintColor = UIColor.white
    }
        
    override func behavior() {
        super.behavior()
        
        videoPlayer.delegate = self
        
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        loadVideos()
        
        searchBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.showSearchVC()
            }
            .disposed(by: disposeBag)
            
        blankView.addButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.showSearchVC()
            }
            .disposed(by: disposeBag)
        
        videoControlView.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.4, animations: {
                    self.videoControlContentView.alpha = 1 - self.videoControlContentView.alpha
                })
            }
            .disposed(by: disposeBag)
            
        videoControlContentView.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.4, animations: {
                    self.videoControlContentView.alpha = 1 - self.videoControlContentView.alpha
                })
            }
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.videoSelected(self.getPreviousVideoIndex(), play: true)
                self.videoPlayed()
            }
            .disposed(by: disposeBag)
        
        forwardButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.videoSelected(self.getNextVideoIndex(), play: true)
                self.videoPlayed()
            }
            .disposed(by: disposeBag)
        
        playPauseButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if self.currentPlayState == PlayState.Pause {
                    self.videoPlayer.playVideo()
                    self.videoPlayed()
                } else {
                    self.videoPlayer.pauseVideo()
                    self.videoPaused()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func showSearchVC() {
        let vc: SearchViewController = SearchViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarBackgroundColor()
        setNavigationBackButton()
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayer.pauseVideo()
        videoPaused()
    }
    
    func resetProgress() {
        let totalDuration: Int = Int(videoPlayer.duration ?? 0)
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        progressImageViewWidth?.update(offset: 0)
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
        durationView.isHidden = !hidden
        videoControlView.isHidden = !hidden
        videoPlayer.isHidden = !hidden
        videoTableView.isHidden = !hidden
    }
}

// MARK: Player Methods
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

// MARK: YT Player View Delegate
extension VideoListViewController: YTSwiftyPlayerDelegate {
//    func playerViewDidBecomeReady(_ playerView: YTSwiftyPlayer) {
//        if autoPlay {
//            videoPlayerView.playVideo()
//            videoPlayed()
//        }
//        resetProgress()
//    }
//
//    func playerView(_ playerView: YTSwiftyPlayer, didChangeTo state: YTPlayerState) {
//        switch state {
//        case .ended:
//            videoSelected(getNextVideoIndex(), play: true)
//        default: break
//        }
//    }
}

// MARK: Table View Datasource, Delegate
extension VideoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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

// MARK: Ask App Store Review and Star Rate
extension VideoListViewController {
    @objc func checkVideoCurrentTime() {
        guard let duration = videoPlayer.duration, videoPlayer.playerState == .playing else { return }
        let currentTime: Int = Int(videoPlayer.currentTime)
        let totalDuration: Int = Int(duration)
        
        let currentTimeString: String = String.init(hms: currentTime.secToHMS())
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "\(currentTimeString) / \(totalDurationString)"
        
        let progress: CGFloat = CGFloat(currentTime) / CGFloat(totalDuration)
        progressImageViewWidth?.update(offset: progress * view.bounds.width)
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            self.durationView.layoutIfNeeded()
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
            guard UserDefaults.standard.object(forKey: ver) == nil else { return }
            
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set("Y", forKey: ver)
        }
    }
}
