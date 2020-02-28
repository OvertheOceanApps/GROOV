//
//  VideoListTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import Kingfisher
import KDCircularProgress

class VideoListTableViewCell: UITableViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var channelLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var progressRingView: KDCircularProgress!
    
    var video: Video! = nil
    var progress: Float = 0.0
    var circleTimer: Timer! = nil
    
    let kYoutubeThumbnail = "mqdefault"
    let kYoutubeImageUrl = "https://i.ytimg.com/vi"
    // https://i.ytimg.com/vi/mzYM9QKKWSg/default.jpg
    
    func initCell(_ video: Video) {
        backgroundColor = GRVColor.backgroundColor
        self.video = video
        titleLabel.text = video.title
        channelLabel.text = video.channelTitle
        durationLabel.text = video.durationString()
        
        let imageUrlString = "\(kYoutubeImageUrl)/\(video.videoId)/\(kYoutubeThumbnail).jpg"
        if let url = URL(string: imageUrlString) {
            thumbnailImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
        
        hideProgress()
        progressRingView.set(colors: GRVColor.gradationFirstColor, GRVColor.gradationSecondColor, GRVColor.gradationThirdColor, GRVColor.gradationFourthColor)
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
        showProgress()
        
        let angle = p * Float(360)
        progressRingView.animate(toAngle: Double(angle), duration: 0.1, completion: nil)
        progress = p
    }
    
    func showProgress() {
        progressRingView.isHidden = false
    }
    
    func hideProgress() {
        progressRingView.isHidden = true
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
