//
//  GRSearchController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 13..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

protocol GRSearchControllerDelegate {
    func didTapOnSearchButton()
    func didTapOnCancelButton()
}

class GRSearchController: UISearchController, UISearchBarDelegate {
    var aSearchBar: GRSearchBar!
    var aDelegate: GRSearchControllerDelegate!
    
    init(searchResultsController: UIViewController!, frame: CGRect, font: UIFont, textColor: UIColor, tintColor: UIColor) {
        super.init(searchResultsController: searchResultsController)
        self.configureSearchBar(frame, font: font, textColor: textColor, bgColor: tintColor)
    }
    
    func configureSearchBar(_ frame: CGRect, font: UIFont, textColor: UIColor, bgColor: UIColor) {
        self.aSearchBar = GRSearchBar(frame: frame, font: font, textColor: textColor)
        self.aSearchBar.barTintColor = bgColor
        self.aSearchBar.tintColor = UIColor.white
        self.aSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.aSearchBar.resignFirstResponder()
        self.aDelegate.didTapOnSearchButton()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.aSearchBar.resignFirstResponder()
        self.aDelegate.didTapOnCancelButton()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
