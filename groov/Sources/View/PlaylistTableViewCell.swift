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
        backgroundColor = GRVColor.backgroundColor
        titleLabel.text = playlist.title
        if playlist.recentVideo == "" {
            videoTitleLabel.text = "No Recent Video"
        } else {
            videoTitleLabel.text = playlist.recentVideo
        }
    }
}
