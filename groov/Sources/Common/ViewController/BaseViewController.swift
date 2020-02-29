//
//  BaseViewController.swift
//  groov
//
//  Created by PilGwonKim on 2018. 3. 18..
//  Copyright © 2018년 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class BaseViewController: UIViewController {
    let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
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
        view.backgroundColor = UIColor.white
    }
    
    func behavior() {
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func initNavigationBarStyle() {
        // set navigation title text font
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
    }
    
    func setNavigationBarBackgroundColor() {
        initNavigationBarStyle()
        
        // set navigation with background color
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = GRVColor.backgroundColor
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setNavigationBarClear() {
        initNavigationBarStyle()
        
        // set navigation clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.barTintColor = UIColor.clear
    }
    
    func setNavigationBackButton() {
        let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigation_back"), style: .plain, target: self, action: #selector(popVC))
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func popVC() {
        _ = navigationController?.popViewController(animated: true)
    }
}
