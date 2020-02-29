//
//  PlaylistBlankView.swift
//  groov
//
//  Created by PilGwonKim on 2020/03/01.
//  Copyright © 2020 PilGwonKim. All rights reserved.
//

import UIKit

class PlaylistBlankView: BaseView {
    private let wrapperView: UIView = UIView()
    private let descriptionLabel: UILabel = UILabel()
    let addFolderButton: UIButton = UIButton()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(wrapperView)
        
        wrapperView.addSubview(descriptionLabel)
        wrapperView.addSubview(addFolderButton)
    }
        
    override func layout() {
        super.layout()
        
        wrapperView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(75)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(25)
        }
        
        addFolderButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(169)
            $0.height.equalTo(36)
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        
        descriptionLabel.text = L10n.msgAddNewFolder
        descriptionLabel.textColor = GRVColor.mainTextColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textAlignment = .center
        
        addFolderButton.setImage(UIImage(named: L10n.imgAddFolder), for: .normal)
    }
        
    override func behavior() {
        super.behavior()
    }
}
