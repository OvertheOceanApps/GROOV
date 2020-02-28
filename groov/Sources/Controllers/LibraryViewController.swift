//
//  LibraryViewController.swift
//  groov
//
//  Created by PilGwonKim on 2017. 10. 29..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit

class LibraryViewController: BaseViewController {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GROOV."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarBackgroundColor()
        setNavigationBackButton()
        initWebView()
    }
}

// MARK: WebView
extension LibraryViewController {
    func initWebView() {
        let htmlFile = Bundle.main.path(forResource: "license", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: nil)
        webView.scrollView.bounces = false
    }
}
