//
//  VideoListTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import KDCircularProgress

class VideoListTableViewCell: BaseTableViewCell {
    private let thumbnailImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let channelLabel: UILabel = UILabel()
    private let durationLabel: UILabel = UILabel()
    private let playPauseButton: UIButton = UIButton()
    private let progressRingView: KDCircularProgress = KDCircularProgress()
    
    var video: Video! = nil
    var progress: Float = 0.0
    var circleTimer: Timer! = nil
    
    let kYoutubeThumbnail = "mqdefault"
    let kYoutubeImageUrl = "https://i.ytimg.com/vi"
    // https://i.ytimg.com/vi/mzYM9QKKWSg/default.jpg
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(thumbnailImageView)
        addSubview(titleLabel)
        addSubview(channelLabel)
        addSubview(durationLabel)
        addSubview(playPauseButton)
        addSubview(progressRingView)
    }
        
    override func layout() {
        super.layout()
        
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(25)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(73)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(29)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(14)
            $0.height.equalTo(15)
        }
        
        channelLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(14)
            $0.height.equalTo(20)
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.equalTo(channelLabel.snp.bottom).offset(7)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(14)
            $0.height.equalTo(15)
        }
        
        playPauseButton.snp.makeConstraints {
            $0.center.equalTo(progressRingView)
            $0.size.equalTo(30)
        }
        
        progressRingView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(9)
            $0.leading.equalTo(channelLabel.snp.trailing).offset(9)
            $0.leading.equalTo(durationLabel.snp.trailing).offset(9)
            $0.trailing.equalToSuperview().inset(23)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(34)
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        selectionStyle = .none
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        titleLabel.textColor = GRVColor.mainTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 13.5)
        
        channelLabel.textColor = GRVColor.mainTextColor
        channelLabel.font = UIFont.systemFont(ofSize: 12)
        
        durationLabel.textColor = GRVColor.subTextColor
        durationLabel.font = UIFont.systemFont(ofSize: 11)

        playPauseButton.setImage(Asset.videoListCellPlay.image, for: .normal)
        
        progressRingView.set(colors: GRVColor.gradationFirstColor, GRVColor.gradationSecondColor, GRVColor.gradationThirdColor, GRVColor.gradationFourthColor)
        progressRingView.angle = 360
        progressRingView.startAngle = 90
        progressRingView.clockwise = false
        progressRingView.gradientRotateSpeed = 0
        progressRingView.glowAmount = 1
        progressRingView.progressThickness = 0.2
        progressRingView.trackThickness = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        progressRingView.isHidden = true
    }
    
    func updateVideo(_ video: Video) {
        self.video = video
        titleLabel.text = video.title
        channelLabel.text = video.channelTitle
        durationLabel.text = video.durationString()
        updateThumnailImageView()
    }
    
    func updateThumnailImageView() {
        let imageUrlString = "\(kYoutubeImageUrl)/\(video.videoId)/\(kYoutubeThumbnail).jpg"
        if let url = URL(string: imageUrlString) {
            thumbnailImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
    }
}

extension VideoListTableViewCell {
    func cellSelected(_ selected: Bool) {
        if selected {
            titleLabel.textColor = UIColor.white
            channelLabel.textColor = UIColor.white
            durationLabel.textColor = GRVColor.mainTextColor
            progressRingView.isHidden = false
        } else {
            titleLabel.textColor = GRVColor.mainTextColor
            channelLabel.textColor = GRVColor.mainTextColor
            durationLabel.textColor = GRVColor.subTextColor
            progressRingView.isHidden = true
        }
    }
}

// MARK: Video Methods
extension VideoListTableViewCell {
    func videoPlayed() {
        startTimer()
        playPauseButton.setImage(Asset.videoListCellPause.image, for: .normal)
    }
    
    func videoPaused() {
        stopTimer()
        playPauseButton.setImage(Asset.videoListCellPlay.image, for: .normal)
    }
}

// MARK: Progress Methods
extension VideoListTableViewCell {
    func progressChanged(p: Float) {
        progressRingView.isHidden = false
        
        let angle = p * Float(360)
        progressRingView.animate(toAngle: Double(angle), duration: 0.1, completion: nil)
        progress = p
    }
    
    @objc func circulateProgress() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.progressRingView.transform = self.progressRingView.transform.rotated(by: CGFloat(Double.pi/4))
        }
    }
}

// MARK: Timer Methods
extension VideoListTableViewCell {
    func startTimer() {
        guard circleTimer == nil else { return }
        
        let ti: Double = 0.1
        circleTimer = Timer.scheduledTimer(withTimeInterval: ti, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.circulateProgress()
        })
    }
    
    func stopTimer() {
        guard circleTimer != nil else { return }
        circleTimer.invalidate()
        circleTimer = nil
    }
}
