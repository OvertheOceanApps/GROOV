//
//  GRSearchController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 13..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

protocol GRSearchControllerDelegate: class {
    func didTapOnSearchButton()
    func didTapOnCancelButton()
}

class GRSearchController: UISearchController, UISearchBarDelegate {
    var aSearchBar: GRSearchBar!
    weak var aDelegate: GRSearchControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(searchResultsController: UIViewController!, frame: CGRect, font: UIFont, textColor: UIColor, tintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        configureSearchBar(frame, font: font, textColor: textColor, bgColor: tintColor)
    }
    
    func configureSearchBar(_ frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        aSearchBar = GRSearchBar(frame: frame, font: font, textColor: textColor)
        aSearchBar.barTintColor = bgColor
        aSearchBar.tintColor = UIColor.white
        aSearchBar.delegate = self
    }
}

// MARK: Search Bar Delegate
extension GRSearchController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        aSearchBar.resignFirstResponder()
        aDelegate?.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        aSearchBar.resignFirstResponder()
        aDelegate?.didTapOnCancelButton()
    }
}
