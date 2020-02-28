//
//  BaseViewController.swift
//  groov
//
//  Created by PilGwonKim on 2018. 3. 18..
//  Copyright © 2018년 PilGwonKim. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    private func initNavigationBarStyle() {
        // set navigation title text font
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
    }
    
    func setNavigationBarBackgroundColor() {
        self.initNavigationBarStyle()
        
        // set navigation with background color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = GRVColor.backgroundColor
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func setNavigationBarClear() {
        self.initNavigationBarStyle()
        
        // set navigation clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    func setNavigationBackButton() {
        let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigation_back"), style: .plain, target: self, action: #selector(popVC))
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func popVC() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
