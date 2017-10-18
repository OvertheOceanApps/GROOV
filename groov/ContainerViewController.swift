//
//  ContainerViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    var sideMenuViewController: MenuViewController? {
        willSet {
            if self.sideMenuViewController != nil {
                if self.sideMenuViewController!.view != nil {
                    self.sideMenuViewController!.view!.removeFromSuperview()
                }
                self.sideMenuViewController!.removeFromParentViewController()
            }
        }
        didSet {
            self.view!.addSubview(self.sideMenuViewController!.view)
            self.addChildViewController(self.sideMenuViewController!)
        }
    }
    
    var mainNavController: MainNavigationController? {
        willSet {
            if self.mainNavController != nil {
                if self.mainNavController!.view != nil {
                    self.mainNavController!.view!.removeFromSuperview()
                }
                self.mainNavController!.removeFromParentViewController()
            }
        }
        didSet {
            self.view!.addSubview(self.mainNavController!.view)
            self.addChildViewController(self.mainNavController!)
        }
    }
    
    let kWidthSidebar: CGFloat = 150
    var menuShown: Bool = false
    fileprivate var toggleMenuObserver: NSObjectProtocol?
    struct Notifications {
        static let toggleMenu: String = "ToggleMenu"
    }
    
    func toggleMenu() {
        if menuShown {
            self.hideMenu()
        } else {
            self.showMenu()
        }
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.hideMenu()
    }
    
    func showMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainNavController!.view.frame = CGRect(x: self.view.x + self.kWidthSidebar, y: self.view.y, width: self.view.width, height: self.view.height)
        }, completion: {(Bool) -> Void in
            self.menuShown = true
        })
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainNavController!.view.frame = CGRect(x: 0, y: self.view.y, width: self.view.width, height: self.view.height)
        }, completion: {(Bool) -> Void in
            self.menuShown = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuVC: MenuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.sideMenuViewController = menuVC
        
        let mainNC: MainNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
        self.mainNavController = mainNC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserver()
    }
    
    func addObserver() {
        let center = NotificationCenter.default
        toggleMenuObserver = center.addObserver(forName: NSNotification.Name(rawValue: Notifications.toggleMenu), object: nil, queue: nil, using: { (notification) in
            self.toggleMenu()
        })
    }
    
    func removeObserver() {
        let center = NotificationCenter.default
        if toggleMenuObserver != nil {
            center.removeObserver(toggleMenuObserver!)
        }
    }

}
