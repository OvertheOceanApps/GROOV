//
//  SettingsTableViewCell.swift
//  groov
//
//  Created by PilGwonKim on 2020/03/01.
//  Copyright © 2020 PilGwonKim. All rights reserved.
//

import UIKit
import SnapKit

class SettingsTableViewCell: BaseTableViewCell {
    let titleLabel: UILabel = UILabel()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(titleLabel)
    }
        
    override func layout() {
        super.layout()
        
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        selectionStyle = .none
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 13.5)
    }
}
