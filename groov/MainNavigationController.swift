//
//  MainNavigationController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    fileprivate var playlistsSelectedObserver: NSObjectProtocol?
//    fileprivate var searchSelectedObserver: NSObjectProtocol?
    fileprivate var settingsSelectedObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    fileprivate func addObservers() {
        let center = NotificationCenter.default
        
        playlistsSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.PlaylistsSelected), object: nil, queue: nil, using: { (notification: Notification!) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
            self.setViewControllers([vc], animated: false)
        })
        
//        searchSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.SearchSelected), object: nil, queue: nil, using: { (notification: Notification!) in
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchVideoViewController") as! SearchVideoViewController
//            self.setViewControllers([vc], animated: false)
//        })
        
        settingsSelectedObserver = center.addObserver(forName: NSNotification.Name(rawValue: MenuViewController.Notifications.SettingsSelected), object: nil, queue: nil, using: { (notification: Notification!) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.setViewControllers([vc], animated: false)
        })
    }
    
    fileprivate func removeObservers() {
        let center = NotificationCenter.default
        if playlistsSelectedObserver != nil {
            center.removeObserver(playlistsSelectedObserver!)
        }
//        if searchSelectedObserver != nil {
//            center.removeObserver(searchSelectedObserver!)
//        }
        if settingsSelectedObserver != nil {
            center.removeObserver(settingsSelectedObserver!)
        }
    }
}
