//
//  SearchVideoViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import CWStatusBarNotification

protocol SearchVideoViewControllerDelegate {
    func videoAdded(_ video: Video)
}

class SearchVideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GRSearchControllerDelegate {
    @IBOutlet var resultTableView: UITableView!
    var resultArray: Array<Video> = []
    var isSearching: Bool = false
    var searchController: GRSearchController!
    var delegate: SearchVideoViewControllerDelegate!
    var notification: CWStatusBarNotification!
    var recentVideos: Array<Video> = []
    
    let kAPIKeyYoutube: String = "AIzaSyCerap6sBRWheVMwPdzae-tcz9DWMEY-Gw"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNotification()
        self.setUpNavigationBar()
        self.configureSearchController()
        self.setUpNavigationLeftBar()
        self.getRecentAddedVideos()
    }
    
    func getRecentAddedVideos() {
        let realm = try! Realm()
        self.recentVideos = Array(realm.objects(Video.self).sorted(byKeyPath: "createdAt", ascending: false))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.aSearchBar.becomeFirstResponder()
    }
    
    func setUpNotification() {
        self.notification = CWStatusBarNotification()
        self.notification.notificationLabelBackgroundColor = UIColor.white
        self.notification.notificationLabelTextColor = UIColor.black
    }
    
    func setUpNavigationBar() {
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func setUpNavigationLeftBar() {
        if delegate != nil { // from VideoListVC
            let dismissButton = UIButton(frame: CGRect(x: 10, y: 30, width: 30, height: 30))
            dismissButton.setImage(#imageLiteral(resourceName: "navigation_dismiss"), for: UIControlState())
            dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            self.view.addSubview(dismissButton)
        } else { // from Sidebar
            let sidebarButton = UIButton(frame: CGRect(x: 10, y: 30, width: 30, height: 30))
            sidebarButton.setImage(#imageLiteral(resourceName: "side_menu_toggle"), for: UIControlState())
            sidebarButton.addTarget(self, action: #selector(showSideMenu), for: .touchUpInside)
            self.view.addSubview(sidebarButton)
        }
    }
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSideMenu() {
        let center = NotificationCenter.default
        center.post(Notification(name: Notification.Name(rawValue: ContainerViewController.Notifications.toggleMenu), object: self))
    }
    
    func configureSearchController() {
        let frame: CGRect = CGRect(x: 40, y: 20, width: self.view.width-40, height: 50)
        let font: UIFont = UIFont.boldSystemFont(ofSize: 15)
        self.searchController = GRSearchController(searchResultsController: self, frame: frame, font: font, textColor: UIColor.black, tintColor: UIColor.black)
        self.searchController.aSearchBar.placeholder = "Type Video Keyword"
        self.searchController.aDelegate = self
        self.view.addSubview(self.searchController.aSearchBar)
    }
    
    func didTapOnSearchButton() {
        let text = self.searchController.aSearchBar.text!
        if text == "" {
            self.isSearching = false
            self.resultTableView.reloadData()
        } else {
            self.isSearching = true
            self.getSearchResult(text)
        }
    }
    
    func didTapOnCancelButton() {
    }
    
    func getSearchResult(_ searchText: String) {
        let urlString = "https://www.googleapis.com/youtube/v3/search"
        let param: Dictionary<String, Any> = ["q": searchText, "part": "id", "type": "video", "maxResults": 10, "key": kAPIKeyYoutube]
        
        Alamofire.request(urlString, method: .get, parameters: param).responseJSON { (response) in
            print(response)
            if let json = response.result.value as? [String: Any] {
                var ids: Array<String> = []
                for item in json["items"] as! Array<Dictionary<String, AnyObject>> {
                    if let vid = item["id"] as? Dictionary<String, AnyObject> {
                        ids.append(vid["videoId"] as! String)
                    }
                }
                
                let urlString = "https://www.googleapis.com/youtube/v3/videos"
                let idString = ids.joined(separator: ",")
                let param: Dictionary<String, Any> = ["part": "snippet,contentDetails", "id": idString, "type": "video", "maxResults": 10, "key": self.kAPIKeyYoutube]
                Alamofire.request(urlString, method: .get, parameters: param).responseJSON { (response2) in
                    if let json2 = response2.result.value as? [String: Any] {
                        self.resultArray.removeAll()
                        for item in json2["items"] as! Array<Dictionary<String, AnyObject>> {
                            let v = Video()
                            v.parseDictionaryToModel(item)
                            self.resultArray.append(v)
                        }
                        self.resultTableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearching ? self.resultArray.count : self.recentVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "SearchCellIdentifier"
        let cell: SearchVideoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchVideoTableViewCell
        if self.isSearching {
            cell.initCell(self.resultArray[indexPath.row])
        } else {
            cell.initCell(self.recentVideos[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let targetVideo: Video = self.isSearching ? self.resultArray[indexPath.row] : self.recentVideos[indexPath.row]
        if delegate != nil { // from VideoListVC
            delegate.videoAdded(targetVideo)
            self.notification.display(withMessage: "Video Added Successfully", forDuration: 1.5)
        } else { // from Sidebar
            let chooseVC: ChoosePlaylistViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChoosePlaylistViewController") as! ChoosePlaylistViewController
            chooseVC.targetVideo = targetVideo
            let navController = UINavigationController(rootViewController: chooseVC)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.isSearching ? "Search Results" : "Recent Videos"
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}
