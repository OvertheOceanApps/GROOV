//
//  PlaylistListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 20..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, VideoListViewControllerDelegate, GRAlertViewControllerDelegate {
    
    var playlistArray: Array<Playlist> = []
    @IBOutlet var playlistTableView: UITableView!
    @IBOutlet var blankView: UIView!
    @IBOutlet var footerView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setNavigationBarBackgroundColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("FolderList", comment: "")
        self.initComponents()
        self.loadPlaylists()
    }
    
    func initComponents() {
        // init Table View
        self.playlistTableView.backgroundColor = GRVColor.backgroundColor
        
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(loadPlaylists), name: NSNotification.Name(rawValue: "clear_realm"), object: nil)
        
        // init footer view
        footerView.backgroundColor = GRVColor.backgroundColor
    }
}

// MARK: GR Alert View Controller Delegate
extension PlaylistListViewController {
    
    func alertViewAddButtonTouched(title: String) {
        self.addPlaylist(title)
    }
}

// MARK: Load Playlist
extension PlaylistListViewController {
    
    @objc func loadPlaylists() {
        let realm = try! Realm()
        self.playlistArray = Array(realm.objects(Playlist.self).sorted(byKeyPath: "order"))
        self.setBlankViewHidden()
        self.playlistTableView.reloadData()
    }
    
    func setBlankViewHidden() {
        var hidden: Bool = true
        if self.playlistArray.count == 0 {
            hidden = false
        }
        self.blankView.isHidden = hidden
        self.playlistTableView.isHidden = !hidden
    }
    
    func addPlaylist(_ title: String) {
        let realm = try! Realm()
        let p = Playlist(value: ["title": title, "order": self.playlistArray.count])
        try! realm.write {
            realm.add(p)
        }
        
        self.playlistArray.append(p)
        self.setBlankViewHidden()
        self.playlistTableView.beginUpdates()
        let indexPath = IndexPath(row: self.playlistArray.count-1, section: 0)
        self.playlistTableView.insertRows(at: [indexPath], with: .automatic)
        self.playlistTableView.endUpdates()
    }
    
    func recentVideoChanged(_ playlist: Playlist) {
        if let index = self.playlistArray.find({$0 == playlist}) {
            self.playlistArray[index] = playlist
            self.playlistTableView.beginUpdates()
            let indexPath = IndexPath(row: index, section: 0)
            self.playlistTableView.reloadRows(at: [indexPath], with: .automatic)
            self.playlistTableView.endUpdates()
        }
    }
}

// MARK: IBActions
extension PlaylistListViewController {
    
    @IBAction func addButtonClicked() {
        let alertVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.GRAlert) as! GRAlertViewController
        alertVC.delegate = self
        self.presentWithFade(targetVC: alertVC)
    }
    
    @IBAction func showSettingsVC() {
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.Settings) as! SettingsViewController
        let navController = UINavigationController.init(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: Table View Datasource, Delegate
extension PlaylistListViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCellIdentifier", for: indexPath) as! PlaylistTableViewCell
        cell.initCell(self.playlistArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoListVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.VideoList) as! VideoListViewController
        videoListVC.playlist = playlistArray[indexPath.row]
        videoListVC.delegate = self
        self.navigationController?.pushViewController(videoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction.init(style: .normal, title: NSLocalizedString("Delete", comment: "")) { (action, indexPath) in
            self.tableView(self.playlistTableView, commit: .delete, forRowAt: indexPath)
        }
        deleteAction.backgroundColor = GRVColor.tableviewRowDeleteColor
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = self.playlistArray[indexPath.row]
            let targetId = playlist.id
            self.playlistArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let realm = try! Realm()
            // delete target playlist's videos
            for v in Array(realm.objects(Video.self).filter("playlistId = %@", playlist.id).sorted(byKeyPath: "order")) {
                try! realm.write {
                    realm.delete(v)
                }
            }
            // delete target playlist
            if let pl = realm.objects(Playlist.self).filter("id = %@", targetId).first {
                try! realm.write {
                    realm.delete(pl)
                }
            }
            // reorder all playlist
            for (idx, pl) in Array(realm.objects(Playlist.self).sorted(byKeyPath: "order")).enumerated() {
                try! realm.write {
                    pl.order = idx
                }
            }
            self.playlistArray = Array(realm.objects(Playlist.self).sorted(byKeyPath: "order"))
            self.setBlankViewHidden()
        }
    }
}
