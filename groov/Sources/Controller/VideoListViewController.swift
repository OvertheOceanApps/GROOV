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

final class VideoListViewController: BaseViewController {
    // MARK: UI componenets
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
    private var progressImageViewWidth: Constraint?
    
    // MARK: Public Properties
    weak var delegate: VideoListViewControllerDelegate?
    
    // MARK: Private Properties
    private let playlist: Playlist
    private var videos: [Video] = []
    private var currentVideo: Video? {
        return currentSelectedCell?.video
    }
    private var playState: PlayState = .pause {
        didSet {
            switch playState {
            case .pause:
                playPauseButton.setImage(Asset.videoControlPlay.image, for: .normal)
                currentSelectedCell?.videoPaused()
                
            case .play:
                playPauseButton.setImage(Asset.videoControlPause.image, for: .normal)
                currentSelectedCell?.videoPlayed()
            }
        }
    }
    private var currentSelectedCell: VideoListTableViewCell? {
        didSet {
            navigationItem.title = currentSelectedCell?.video?.title
        }
    }
    
    private var autoPlay: Bool = false
    private var totalPlayTime: Float = 0 // for review. review time > 10s -> review request
    private var reviewAsked: Bool = false
    
    private let cellIdentifier: String = "VideoListCellIdentifier"
    
    // MARK: Initializer
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
        
        videoPlayer.setPlayerParameters([.showControls(.hidden),
                                         .showModestbranding(true),
                                         .playsInline(true),
                                         .showInfo(false),
                                         .showFullScreenButton(false),
                                         .showRelatedVideo(false)])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Setup ViewController
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
        videoPlayer.loadPlayer()
        
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        loadVideos()
        
        searchBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.presentSearchViewController()
            }
            .disposed(by: disposeBag)
            
        blankView.addButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.presentSearchViewController()
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
                self.playState = .play
            }
            .disposed(by: disposeBag)
        
        forwardButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.videoSelected(self.getNextVideoIndex(), play: true)
                self.playState = .play
            }
            .disposed(by: disposeBag)
        
        playPauseButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if self.playState == .pause {
                    self.videoPlayer.playVideo()
                    self.playState = .play
                } else {
                    self.videoPlayer.pauseVideo()
                    self.playState = .pause
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarBackgroundColor()
        setNavigationBackButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayer.pauseVideo()
        playState = .pause
    }
    
    private func presentSearchViewController() {
        let vc = SearchViewController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}

// MARK: - VideoList Data
extension VideoListViewController {
    private func loadVideos() {
        let realm = try! Realm()
        videos = Array(
            realm.objects(Video.self)
                .filter("playlistId = %@", playlist.id)
                .sorted(byKeyPath: "order")
            )
        
        if videos.isEmpty == false {
            videoTableView.reloadData()
        }
        
        setBlankViewHidden()
    }
    
    func videoSelected(_ index: Int, play: Bool) {
        autoPlay = play
        
        guard let selectedCell = videoTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VideoListTableViewCell else { return }
        
        if let previousSelectedCell = currentSelectedCell, previousSelectedCell != selectedCell {
            playState = .pause
            previousSelectedCell.cellSelected(false)
        }
        
        selectedCell.cellSelected(true)
        currentSelectedCell = selectedCell
        
        if let video = currentVideo {
            if play {
                videoPlayer.loadVideo(videoID: video.videoId)
            } else {
                videoPlayer.cueVideo(videoID: video.videoId)
            }
        }
        videoTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
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
            video.order = self.videos.count
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
        
        videos.append(video)
        setBlankViewHidden()
        
        videoTableView.beginUpdates()
        let indexPath = IndexPath(row: videos.count - 1, section: 0)
        videoTableView.insertRows(at: [indexPath], with: .automatic)
        videoTableView.endUpdates()
        
        if let selectedCell = videoTableView.cellForRow(at: indexPath) as? VideoListTableViewCell {
            if currentSelectedCell == nil && videos.isEmpty == false {
                currentSelectedCell = selectedCell
                videoSelected(indexPath.row, play: false)
            }
        }
        
        delegate?.recentVideoChanged(playlist)
    }
    
    func setBlankViewHidden() {
        let isHidden: Bool = videos.isEmpty == false
        blankView.isHidden = isHidden
        durationView.isHidden = !isHidden
        videoControlView.isHidden = !isHidden
        videoPlayer.isHidden = !isHidden
        videoTableView.isHidden = !isHidden
    }
}

// MARK: - Player Control Methods
extension VideoListViewController {
    private func getNextVideoIndex() -> Int {
        if let currentIndex = videos.find({$0 == currentVideo}) {
            return currentIndex + 1 >= videos.count ? 0 : currentIndex + 1
        }
        return 0
    }
    
    private func getPreviousVideoIndex() -> Int {
        if let currentIndex = videos.find({$0 == currentVideo}) {
            return currentIndex - 1 < 0 ? videos.count - 1 : currentIndex - 1
        }
        return 0
    }
}

// MARK: - YTSwiftyPlayerDelegate
extension VideoListViewController: YTSwiftyPlayerDelegate {
    func playerReady(_ player: YTSwiftyPlayer) {
        if videos.isEmpty == false {
            videoSelected(0, play: false)
        }

        if autoPlay {
            videoPlayer.playVideo()
            playState = .pause
        }
        resetProgress()
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        switch state {
        case .unstarted:
            playState = .pause
        case .ended:
            playState = .pause
            videoSelected(getNextVideoIndex(), play: true)
        case .playing:
            playState = .play
        case .paused:
            playState = .pause
        case .buffering:
            break
        case .cued:
            break
        }
    }
    
    func player(_ player: YTSwiftyPlayer, didReceiveError error: YTSwiftyPlayerError) {
        print(error)
    }
    
    func player(_ player: YTSwiftyPlayer, didUpdateCurrentTime currentTime: Double) {
        updateCurrentTime(by: currentTime)
    }
}

// MARK: - UITableViewDataSource
extension VideoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let videoCell = cell as? VideoListTableViewCell {
            videoCell.updateVideo(videos[indexPath.row])
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension VideoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCell = videoTableView.cellForRow(at: IndexPath(row: indexPath.row, section: 0)) as? VideoListTableViewCell
        if currentSelectedCell != nil && selectedCell == currentSelectedCell {
            // user selected current playing cell
            if playState == .play { // play -> pause
                videoPlayer.pauseVideo()
                playState = .pause
            } else { // pause -> play
                videoPlayer.playVideo()
                playState = .play
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
            let targetId = videos[indexPath.row].id
            videos.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
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
            videos = Array(realm.objects(Video.self).filter("playlistId = %@", parentId).sorted(byKeyPath: "order"))
            
            setBlankViewHidden()
        }
    }
}

// MARK: - Progress & App Store Review
extension VideoListViewController {
    private func updateCurrentTime(by currentTime: Double) {
        guard let duration = videoPlayer.duration, videoPlayer.playerState == .playing else { return }
        let currentTime: Int = Int(currentTime)
        let videoDuration: Int = Int(duration)
        let currentTimeString: String = String(hms: currentTime.secToHMS())
        let videoDurationString: String = String(hms: videoDuration.secToHMS())
        let progress: CGFloat = CGFloat(currentTime) / CGFloat(videoDuration)
        
        runningTimeLabel.text = "\(currentTimeString) / \(videoDurationString)"
        progressImageViewWidth?.update(offset: progress * view.bounds.width)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            self.durationView.layoutIfNeeded()
        })
        
        // for ask Review
        totalPlayTime += 0.5
        if totalPlayTime >= 10 {
            askReview()
        }
    }
    
    private func resetProgress() {
        let totalDuration: Int = Int(videoPlayer.duration ?? 0)
        let totalDurationString: String = String.init(hms: totalDuration.secToHMS())
        runningTimeLabel.text = "0:00:00 / \(totalDurationString)"
        progressImageViewWidth?.update(offset: 0)
    }
    
    private func askReview() {
        if reviewAsked == false {
            reviewAsked = true
            
            let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            guard UserDefaults.standard.object(forKey: ver) == nil else { return }
            
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set("Y", forKey: ver)
        }
    }
}
