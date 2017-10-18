//
//  MenuViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileNameLabel: UILabel!
    @IBOutlet var profileIdLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    
    struct Notifications {
        static let PlaylistsSelected = "PlaylistsSelected"
        static let SearchSelected = "SearchSelected"
        static let SettingsSelected = "SettingsSelected"
    }
    
    override func viewDidLoad() {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "MenuCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuTableViewCell
        
        var title: String = ""
        switch indexPath.row {
            case 0:
                title = "Playlists"
            case 1:
                title = "Search Videos"
            case 2:
                title = "Settings"
            default:
                break
        }
        cell.titleLabel?.text = title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let center = NotificationCenter.default
        switch indexPath.row {
        case 0:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.PlaylistsSelected), object: self))
        case 1:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.SearchSelected), object: self))
        case 2:
            center.post(Notification(name: Notification.Name(rawValue: Notifications.SettingsSelected), object: self))
        default:
            print("Unrecognized menu index")
        }
        center.post(Notification(name: Notification.Name(rawValue: ContainerViewController.Notifications.toggleMenu), object: self))
    }

}
