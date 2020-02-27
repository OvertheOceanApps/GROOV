//
//  SearchSuggestTableViewCell.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2017. 3. 17..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit

class SearchSuggestTableViewCell: UITableViewCell {
    @IBOutlet var keywordLabel: UILabel!
    var keyword: String!
    
    func initCell(_ kw: String) {
        self.keyword = kw
        self.keywordLabel.text = kw
    }

}
