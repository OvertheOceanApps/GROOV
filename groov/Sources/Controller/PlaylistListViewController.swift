//
//  PlaylistListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 20..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistListViewController: BaseViewController {
    var playlistArray: Array<Playlist> = []
    @IBOutlet var playlistTableView: UITableView!
    @IBOutlet var blankView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var addFolderButton: UIButton!
    @IBOutlet var blankAddFolderButton: UIButton!
    
    private let cellIdentifier: String = "PlaylistCellIdentifier"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationBarBackgroundColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.folderList
        
        playlistTableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        initComponents()
        loadPlaylists()
    }
    
    func initComponents() {
        // init Table View
        playlistTableView.backgroundColor = GRVColor.backgroundColor
        
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(loadPlaylists), name: NSNotification.Name(rawValue: "clear_realm"), object: nil)
        
        // init footer view
        footerView.backgroundColor = GRVColor.backgroundColor
        
        // init button for localization
        addFolderButton.setImage(UIImage(named: L10n.imgAddFolder), for: .normal)
        blankAddFolderButton.setImage(UIImage(named: L10n.imgAddFolder), for: .normal)
    }
}

// MARK: GR Alert View Controller Delegate
extension PlaylistListViewController: GRAlertViewControllerDelegate {
    func alertViewAddButtonTouched(title: String) {
        addPlaylist(title)
    }
}

// MARK: Load Playlist
extension PlaylistListViewController {
    @objc func loadPlaylists() {
        let realm = try! Realm()
        playlistArray = Array(realm.objects(Playlist.self).sorted(byKeyPath: "order"))
        setBlankViewHidden()
        playlistTableView.reloadData()
    }
    
    func setBlankViewHidden() {
        var hidden: Bool = true
        if playlistArray.count == 0 {
            hidden = false
        }
        blankView.isHidden = hidden
        playlistTableView.isHidden = !hidden
    }
    
    func addPlaylist(_ title: String) {
        let realm = try! Realm()
        let p = Playlist(value: ["title": title, "order": playlistArray.count])
        try! realm.write {
            realm.add(p)
        }
        
        TrackUtil.sendPlaylistAddedEvent(title: title)
        
        playlistArray.append(p)
        setBlankViewHidden()
        playlistTableView.beginUpdates()
        let indexPath = IndexPath(row: playlistArray.count-1, section: 0)
        playlistTableView.insertRows(at: [indexPath], with: .automatic)
        playlistTableView.endUpdates()
    }
}

// MARK: VideoListViewControllerDelegate
extension PlaylistListViewController: VideoListViewControllerDelegate {
    func recentVideoChanged(_ playlist: Playlist) {
        if let index = playlistArray.find({$0 == playlist}) {
            playlistArray[index] = playlist
            playlistTableView.beginUpdates()
            let indexPath = IndexPath(row: index, section: 0)
            playlistTableView.reloadRows(at: [indexPath], with: .automatic)
            playlistTableView.endUpdates()
        }
    }
}

// MARK: IBActions
extension PlaylistListViewController {
    @IBAction func addButtonClicked() {
        let alertVC = storyboard?.instantiateViewController(withIdentifier: StoryboardId.GRAlert) as! GRAlertViewController
        alertVC.delegate = self
        presentWithFade(targetVC: alertVC)
    }
    
    @IBAction func showSettingsVC() {
        let vc: SettingsViewController = SettingsViewController()
        let nav = UINavigationController.init(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}

// MARK: Table View Datasource, Delegate
extension PlaylistListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaylistTableViewCell
        cell.updatePlaylist(playlistArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoListVC = storyboard?.instantiateViewController(withIdentifier: StoryboardId.VideoList) as! VideoListViewController
        videoListVC.playlist = playlistArray[indexPath.row]
        videoListVC.delegate = self
        navigationController?.pushViewController(videoListVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction: UITableViewRowAction = UITableViewRowAction.init(style: .normal, title: L10n.delete) { [weak self] (_, indexPath) in
            guard let self = self else { return }
            self.tableView(self.playlistTableView, commit: .delete, forRowAt: indexPath)
        }
        deleteAction.backgroundColor = GRVColor.tableviewRowDeleteColor
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlist = playlistArray[indexPath.row]
            let targetId = playlist.id
            playlistArray.remove(at: indexPath.row)
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
            playlistArray = Array(realm.objects(Playlist.self).sorted(byKeyPath: "order"))
            setBlankViewHidden()
        }
    }
}
