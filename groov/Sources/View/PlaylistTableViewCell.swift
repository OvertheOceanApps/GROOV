//
//  PlaylistTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 6..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: BaseTableViewCell {
    private let titleLabel: UILabel = UILabel()
    private let videoTitleLabel: UILabel = UILabel()
    private let bottomLineView: UIView = UIView()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(titleLabel)
        addSubview(videoTitleLabel)
        addSubview(bottomLineView)
    }
        
    override func layout() {
        super.layout()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(22)
            $0.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(20)
        }
        
        videoTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(22)
            $0.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(15)
        }
        
        bottomLineView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        selectionStyle = .none
        
        titleLabel.textColor = GRVColor.mainTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        
        videoTitleLabel.textColor = GRVColor.mainTextColor
        videoTitleLabel.font = UIFont.systemFont(ofSize: 12)
        
        bottomLineView.backgroundColor = GRVColor.separatorColor
    }
        
    override func behavior() {
        super.behavior()
    }
    
    func initCell(_ playlist: Playlist) {
        titleLabel.text = playlist.title
        videoTitleLabel.text = playlist.recentVideo.isEmpty ? L10n.noRecentVideo : playlist.recentVideo
    }
}
