//
//  SearchViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2017. 3. 15..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit
import AssistantKit
import Alamofire
import SWXMLHash
import RealmSwift

protocol SearchViewControllerDelegate {
    func videoAdded(_ video: Video)
}

class SearchViewController: BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var resultTableView: UITableView!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    var underLineView: UIImageView!
    var isSearching: Bool = false
    var shouldShowRecentVideo: Bool = true
    var suggestResults: Array<String> = []
    var videoResults: Array<Video> = []
    var recentVideos: Array<Video> = []
    var delegate: SearchViewControllerDelegate!
    
    deinit {
        removeKeyboardNotification()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarBackgroundColor()
        self.initComponents()
        self.getRecentAddedVideos()
        self.addKeyboardNotification()
    }
    
    func initComponents() {
        self.initSearchBar()
        self.initSearchBarTextField()
        
        self.view.backgroundColor = GRVColor.backgroundColor
        self.resultTableView.backgroundColor = GRVColor.backgroundColor
    }
}

// MARK: Keyboard Notification
extension SearchViewController {
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receiveKeyboardNotification(_ notification: Notification) {
        guard let keyboardInfo = KeyboardNotification(notification) else { return }
        let keyboardHeight = keyboardInfo.isShowing ? keyboardInfo.endFrame.height : 0
        var newInset = UIEdgeInsets.zero
        newInset.bottom = keyboardHeight
        resultTableView.contentInset = newInset
    }
}

// MARK: Search Result, Recent Result, Auto Complete
extension SearchViewController {
    
    func getRecentAddedVideos() {
        let realm = try! Realm()
        self.recentVideos = Array(realm.objects(Video.self).sorted(byKeyPath: "createdAt", ascending: false))
    }
    
    func getSuggestResult(keyword: String) {
        self.isSearching = true
        
        var kw = keyword.replacingOccurrences(of: " ", with: "+")
        kw = kw.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlString = "http://google.com/complete/search?output=toolbar&ds=yt&hl=en&q=\(kw)"
        
        var results: Array<String> = []
        Alamofire.request(urlString, method: .get).response { (response) in
            if let str = String.init(data: response.data!, encoding: .utf8) {
                let dt = str.data(using: .utf8)
                let xml = SWXMLHash.parse(dt!)
                for result in xml["toplevel"]["CompleteSuggestion"].all {
                    if let element = result["suggestion"].element {
                        if let data = element.attribute(by: "data") {
                            results.append(data.text)
                        }
                    }
                }
                self.suggestResults = results
                self.resultTableView.reloadData()
            }
        }
    }
    
    func getVideoResult(_ searchText: String) {
        let kAPIKeyYoutube: String = Bundle.main.object(forInfoDictionaryKey: "YoutubeAPIKey") as! String
        let urlString = "https://www.googleapis.com/youtube/v3/search"
        let param: Dictionary<String, Any> = ["q": searchText, "part": "id", "type": "video", "maxResults": 10, "key": kAPIKeyYoutube]
        
        self.isSearching = false
        self.shouldShowRecentVideo = false
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
                let param: Dictionary<String, Any> = ["part": "snippet,contentDetails", "id": idString, "type": "video", "maxResults": 10, "key": kAPIKeyYoutube]
                Alamofire.request(urlString, method: .get, parameters: param).responseJSON { (response2) in
                    if let json2 = response2.result.value as? [String: Any] {
                        self.videoResults.removeAll()
                        for item in json2["items"] as! Array<Dictionary<String, AnyObject>> {
                            let v = Video()
                            v.parseDictionaryToModel(item)
                            self.videoResults.append(v)
                        }
                        self.resultTableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: Init Search Bar
extension SearchViewController {
    
    func initSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("SearchVideo", comment: "")
        self.searchBar.showsCancelButton = true
        self.searchBar.setImage(#imageLiteral(resourceName: "search_favicon"), for: .search, state: .normal)
        self.searchBar.setImage(#imageLiteral(resourceName: "search_close"), for: .clear, state: .normal)
        self.searchBar.searchBarStyle = .default
        self.searchBar.barTintColor = .white
        self.searchBar.sizeToFit()
        self.navigationItem.titleView = self.searchBar
        self.searchBar.becomeFirstResponder()
        
        var cancelButton: UIButton
        let topView: UIView = self.searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKind(of: NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
                cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                cancelButton.setTitleColor(GRVColor.mainTextColor, for: .normal)
            }
        }
        
        if let textField = firstSubview(of: UITextField.self, in: searchBar), let label = firstSubview(of: UILabel.self, in: searchBar) {
            underLineView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            underLineView.translatesAutoresizingMaskIntoConstraints = false
            underLineView.image = #imageLiteral(resourceName: "search_under_line")
            underLineView.clipsToBounds = true
            underLineView.contentMode = .scaleToFill
            textField.addSubview(underLineView)
            
            underLineView.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: label.frame.minX).isActive = true
            let trailingConstraints = underLineView.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
            trailingConstraints.priority = .defaultHigh
            trailingConstraints.isActive = true
            underLineView.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
            underLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        }
    }
    
    func firstSubview<T>(of type: T.Type, in view: UIView) -> T? {
        return view.subviews.compactMap { $0 as? T ?? firstSubview(of: T.self, in: $0) }.first
    }
    
    func initSearchBarTextField() {
        if let searchField = firstSubview(of: UITextField.self, in: searchBar) {
            searchField.textColor = .white
            searchField.tintColor = .white
            searchField.backgroundColor = .clear
            searchField.clearButtonMode = .whileEditing
            searchField.autocorrectionType = .no
            searchField.autocapitalizationType = .none
        }
    }
}

// MARK: Search Bar Delegate
extension SearchViewController {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.getVideoResult(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.replacingOccurrences(of: " ", with: "") == "" {
            self.shouldShowRecentVideo = true
            self.isSearching = false
            self.getRecentAddedVideos()
            self.resultTableView.reloadData()
            return
        }
        self.getSuggestResult(keyword: searchText)
    }
}

// MARK: Table View Datasource, Delegate
extension SearchViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching == false {
            self.resultTableView.separatorStyle = .singleLine
            if self.shouldShowRecentVideo == true {
                return self.recentVideos.count
            } else {
                return self.videoResults.count
            }
        }
        
        self.resultTableView.separatorStyle = .none
        return self.suggestResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSearching {
            return 44
        }
        return 110
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isSearching { // auto-complete, is searching
            let cellIdentifier: String = "SearchSuggestCellIdentifier"
            let cell: SearchSuggestTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchSuggestTableViewCell
            cell.initCell(self.suggestResults[indexPath.row])
            return cell
        }
        
        let cellIdentifier: String = "SearchVideoCellIdentifier"
        let cell: SearchVideoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchVideoTableViewCell
        if shouldShowRecentVideo == true { // show recent videos
            cell.initCell(self.recentVideos[indexPath.row])
        } else { // show search result videos
            cell.initCell(self.videoResults[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching == true {
            if let cell:SearchSuggestTableViewCell = tableView.cellForRow(at: indexPath) as? SearchSuggestTableViewCell {
                self.searchBar.text = cell.keyword
                self.getVideoResult(cell.keyword)
            }
        } else {
            let targetVideo: Video = self.shouldShowRecentVideo ? self.recentVideos[indexPath.row] : self.videoResults[indexPath.row]
            delegate.videoAdded(targetVideo)
        }
    }
}














