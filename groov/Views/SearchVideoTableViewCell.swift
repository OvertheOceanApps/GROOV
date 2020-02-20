//
//  SearchVideoTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import Kingfisher

class SearchVideoTableViewCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var channelLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    var video: Video! = nil
    
    let kYoutubeThumbnail = "mqdefault"
    let kYoutubeImageUrl = "https://i.ytimg.com/vi"
    // https://i.ytimg.com/vi/mzYM9QKKWSg/default.jpg
    
    func initCell(_ video: Video) {
        self.backgroundColor = GRVColor.backgroundColor
        self.video = video
        self.titleLabel.text = video.title
        self.channelLabel.text = video.channelTitle
        self.durationLabel.text = video.durationString()
        
        let imageUrlString = "\(kYoutubeImageUrl)/\(video.videoId)/\(kYoutubeThumbnail).jpg"
        if let url = URL(string: imageUrlString) {
            thumbnailImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
    }
}
