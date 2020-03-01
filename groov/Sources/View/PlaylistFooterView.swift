//
//  PlaylistFooterView.swift
//  groov
//
//  Created by PilGwonKim on 2020/03/01.
//  Copyright © 2020 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class PlaylistFooterView: BaseView {
    let addFolderButton: UIButton = UIButton()

    override func addSubviews() {
        super.addSubviews()
        
        addSubview(addFolderButton)
    }
        
    override func layout() {
        super.layout()
        
        addFolderButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(169)
            $0.height.equalTo(36)
        }
    }
        
    override func style() {
        super.style()
        
        backgroundColor = GRVColor.backgroundColor
        
        addFolderButton.setImage(UIImage(named: L10n.imgAddFolder), for: .normal)
    }
}
