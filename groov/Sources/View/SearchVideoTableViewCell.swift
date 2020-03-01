//
//  SearchVideoTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class SearchVideoTableViewCell: BaseTableViewCell {
    private let thumbnailImageView: UIImageView = UIImageView()
    private let titleLabel: UILabel = UILabel()
    private let channelLabel: UILabel = UILabel()
    private let durationLabel: UILabel = UILabel()
    
    var video: Video! = nil
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(thumbnailImageView)
        addSubview(titleLabel)
        addSubview(channelLabel)
        addSubview(durationLabel)
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
            $0.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(15)
        }
        
        channelLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(20)
        }
        
        durationLabel.snp.makeConstraints {
            $0.top.equalTo(channelLabel.snp.bottom).offset(7)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(15)
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
    }
    
    func updateVideo(_ video: Video) {
        self.video = video
        titleLabel.text = video.title
        channelLabel.text = video.channelTitle
        durationLabel.text = video.durationString()
        
        if let url = URL(string: video.getThumbnailUrl()) {
            thumbnailImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
    }
}
