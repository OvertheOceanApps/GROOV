//
//  GRSearchBar.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 13..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class GRSearchBar: UISearchBar {
    var preferredFont: UIFont!
    var preferredTextColor: UIColor!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, font: UIFont, textColor: UIColor) {
        super.init(frame: frame)
        self.frame = frame
        preferredFont = font
        preferredTextColor = textColor
        searchBarStyle = .prominent
        isTranslucent = false
    }
    
    func indexOfSearchFieldInSubviews() -> Int! {
        var index: Int!
        let searchBarView = subviews[0] as UIView
        for i in 0..<searchBarView.subviews.count {
            if searchBarView.subviews[i].isKind(of: UITextField.self) {
                index = i
                break
            }
        }
        return index
    }
    
    override func draw(_ rect: CGRect) {
        if let index = indexOfSearchFieldInSubviews() {
            let searchField: UITextField = subviews[0].subviews[index] as! UITextField
            searchField.font = preferredFont
            searchField.textColor = preferredTextColor
            searchField.tintColor = preferredTextColor
            searchField.backgroundColor = UIColor.white
            searchField.clearButtonMode = .whileEditing
            searchField.autocorrectionType = .no
            searchField.autocapitalizationType = .none
            searchField.spellCheckingType = .no
        }
    }
}
