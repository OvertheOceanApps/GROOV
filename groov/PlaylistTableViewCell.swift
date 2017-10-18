//
//  PlaylistTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 6..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var videoTitleLabel: UILabel!
    
    func initCell(_ playlist: Playlist) {
        self.backgroundColor = GRVColor.backgroundColor
        self.titleLabel.text = playlist.title
        if playlist.recentVideo == "" {
            self.videoTitleLabel.text = "No Recent Video"
        } else {
            self.videoTitleLabel.text = playlist.recentVideo
        }
    }
}
