//
//  BaseTableViewCell.swift
//  groov
//
//  Created by PilGwonKim on 2020/03/01.
//  Copyright © 2020 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
    let disposeBag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        addSubviews()
        layout()
        style()
        behavior()
    }

    func addSubviews() {
    }

    func layout() {
    }

    func style() {
    }

    func behavior() {
    }
}
