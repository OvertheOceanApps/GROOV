//
//  ChoosePlaylistViewController.swift
//  groov
//
//  Created by KimFeeLGun on 2016. 7. 27..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RealmSwift
import CWStatusBarNotification

class ChoosePlaylistViewController: UITableViewController {
    @IBOutlet var playlistTableView: UITableView!
    var targetVideo: Video!
    var playlistArray: Array<Playlist> = []
    var notification: CWStatusBarNotification!
    
    @IBOutlet var videoImageView: UIImageView!
    @IBOutlet var videoTitleLabel: UILabel!
    @IBOutlet var videoDescLabel: UILabel!
    @IBOutlet var videoChannelLabel: UILabel!
    @IBOutlet var videoPublishedAtLabel: UILabel!
    
    func initHeaderView(_ video: Video) {
        self.videoTitleLabel.text = video.title
        self.videoDescLabel.text = video.desc
        self.videoChannelLabel.text = video.channelTitle
        self.videoPublishedAtLabel.text = video.publishedAtFormatted()
        self.videoImageView.kf.setImage(with: URL(string: video.thumbnailDefault)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNotification()
        self.setUpNavigationBar()
        self.setUpTitleView()
        self.initHeaderView(targetVideo)
        self.loadPlaylists()
    }
    
    func setUpNotification() {
        self.notification = CWStatusBarNotification()
        self.notification.notificationLabelBackgroundColor = UIColor.white
        self.notification.notificationLabelTextColor = UIColor.black
    }
    
    func setUpNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "navigation_dismiss"), style: .plain, target: self, action: #selector(dismissVC))
        self.navigationItem.rightBarButtonItem = dismissButton
    }
    
    func setUpTitleView() {
        let logoLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        logoLabel.text = "Choose Playlist"
        logoLabel.textAlignment = .center
        logoLabel.font = UIFont.boldSystemFont(ofSize: 20)
        logoLabel.textColor = UIColor.white
        self.navigationItem.titleView = logoLabel
    }
    
    func loadPlaylists() {
        let realm = try! Realm()
        self.playlistArray = Array(realm.objects(Playlist.self).sorted(byKeyPath: "order"))
        if self.playlistArray.count > 0 {
            self.playlistTableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCellIdentifier", for: indexPath) as! PlaylistTableViewCell
        cell.initCell(self.playlistArray[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.addVideoToPlaylist(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Playlists"
    }
    
    func addVideoToPlaylist(_ index: Int) {
        let realm = try! Realm()
        let playlist: Playlist = playlistArray[index]
        try! realm.write {
            targetVideo.createdAt = NSDate() as Date
            targetVideo.playlistId = playlist.id
            targetVideo.order = realm.objects(Video.self).filter("playlistId = %@", playlist.id).count
            realm.add(targetVideo)
            playlist.recentVideo = targetVideo.title
        }
        self.notification.display(withMessage: "Video Added Successfully", forDuration: 1.5)
        self.dismissVC()
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }

}
