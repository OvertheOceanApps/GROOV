//
//  SearchSuggestTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2017. 3. 17..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit
import SnapKit

class SearchSuggestTableViewCell: BaseTableViewCell {
    private let keywordLabel: UILabel = UILabel()
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(keywordLabel)
    }
        
    override func layout() {
        super.layout()
        
        keywordLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(13)
            $0.leading.equalToSuperview().inset(47)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(18)
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        selectionStyle = .none
        
        keywordLabel.textColor = GRVColor.subTextColor
        keywordLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    func updateKeyword(_ kw: String) {
        keywordLabel.text = kw
    }
}
