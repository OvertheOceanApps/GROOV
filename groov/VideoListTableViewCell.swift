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
        self.backgroundColor = GRVColor.backgroundColor
        self.video = video
        self.titleLabel.text = video.title
        self.channelLabel.text = video.channelTitle
        self.durationLabel.text = video.durationString()
        let imageUrl = "\(kYoutubeImageUrl)/\(video.videoId)/\(kYoutubeThumbnail).jpg"
        self.thumbnailImageView.kf.setImage(with: URL(string: imageUrl)!, placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        self.hideProgress()
        self.progressRingView.set(colors: GRVColor.gradationFirstColor, GRVColor.gradationSecondColor, GRVColor.gradationThirdColor, GRVColor.gradationFourthColor)
    }
    
    func videoPlayed() {
        self.startTimer()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "video_list_cell_pause"), for: .normal)
    }
    
    func videoPaused() {
        self.stopTimer()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "video_list_cell_play"), for: .normal)
    }
    
    func progressChanged(p: Float) {
        self.showProgress()
        
        let angle = p * Float(360)
        self.progressRingView.animate(toAngle: Double(angle), duration: 0.1, completion: nil)
        progress = p
    }
    
    func showProgress() {
        self.progressRingView.isHidden = false
    }
    
    func hideProgress() {
        self.progressRingView.isHidden = true
    }
    
    func startTimer() {
        guard self.circleTimer == nil else { return }
        
        let ti: Double = 0.1
        if #available(iOS 10.0, *) {
            self.circleTimer = Timer.scheduledTimer(withTimeInterval: ti, repeats: true, block: { (timer) in
                self.circulateProgress()
            })
        } else {
            self.circleTimer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(circulateProgress), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        guard self.circleTimer != nil else { return }
        self.circleTimer.invalidate()
        self.circleTimer = nil
    }
    
    @objc func circulateProgress() {
        UIView.animate(withDuration: 0.5) {
//            yourButton.transform = CGAffineTransformMakeRotation(45.0*M_PI/180.0);
            self.progressRingView.transform = self.progressRingView.transform.rotated(by: CGFloat(Double.pi/4))
        }
    }
}
