//
//  LibraryViewController.swift
//  groov
//
//  Created by PilGwonKim on 2017. 10. 29..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GROOV."
        self.setNavigation()
    }
    
    func setNavigation() {
        // set navigation title text font
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey.foregroundColor: UIColor.white
        ]
        
        // set navigation back button
        let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "navigation_back"), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationItem.leftBarButtonItem = backBarButton
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func dismissVC() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initWebView()
    }
    
    func initWebView() {
        let htmlFile = Bundle.main.path(forResource: "license", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: nil)
        webView.scrollView.bounces = false
    }

}
