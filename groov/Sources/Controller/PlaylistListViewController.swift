//
//  PlaylistListViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 20..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import RealmSwift

class PlaylistListViewController: BaseViewController {
    var playlistArray: Array<Playlist> = []
    private let playlistTableView: UITableView = UITableView()
    private let footerView: PlaylistFooterView = PlaylistFooterView()
    private let blankView: BlankView = BlankView(.playlist)
    
    private let cellIdentifier: String = "PlaylistCellIdentifier"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationBarBackgroundColor()
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        view.addSubview(blankView)
        view.addSubview(playlistTableView)
        
        playlistTableView.register(PlaylistTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
        
    override func layout() {
        super.layout()
        
        blankView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        playlistTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
        
    override func style() {
        super.style()
        
        navigationItem.title = L10n.folderList
        
        playlistTableView.backgroundColor = GRVColor.backgroundColor
    }
        
    override func behavior() {
        super.behavior()
        
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        
        loadPlaylists()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPlaylists), name: NSNotification.Name(rawValue: "clear_realm"), object: nil)
        
        footerView.addFolderButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.showGRAlertVC()
            }
            .disposed(by: disposeBag)
        
        blankView.addButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.showGRAlertVC()
            }
            .disposed(by: disposeBag)
    }
    
    func showGRAlertVC() {
        let vc: GRAlertViewController = GRAlertViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.presentWithFade(targetVC: vc)
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
        blankView.isHidden = !(playlistArray.count == 0)
        playlistTableView.isHidden = playlistArray.count == 0
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlaylistTableViewCell
        cell.updatePlaylist(playlistArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc: VideoListViewController = VideoListViewController()
        vc.playlist = playlistArray[indexPath.row]
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
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
