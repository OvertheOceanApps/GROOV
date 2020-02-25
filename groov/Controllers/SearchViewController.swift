//
//  SearchViewController.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2017. 3. 15..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func videoAdded(_ video: Video)
}

extension Constants.Layout {
    enum SearchList {
        static let heightForSuggest: CGFloat = 44
        static let heightForVideo: CGFloat = 110
    }
}

final class SearchViewController: BaseViewController {
    enum SearchCellType {
        case suggest, recently, searched
    }
    
    @IBOutlet var resultTableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    weak var delegate: SearchViewControllerDelegate?
    
    private let searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    private let underLineView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

    private let dataManager: SearchViewDataManager = SearchViewDataManager()
    private var showingCellType: SearchCellType {
        if dataManager.searchedVideos.isEmpty == false {
            return .searched
        } else if dataManager.suggestions.isEmpty == false {
            return .suggest
        } else {
            return .recently
        }
    }
    
    deinit {
        removeKeyboardNotification()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
        addKeyboardNotification()
        
        setNavigationBarBackgroundColor()
        initComponents()
    }
    
    func initComponents() {
        initSearchBar()
        initSearchBarTextField()
        
        view.backgroundColor = GRVColor.backgroundColor
        resultTableView.backgroundColor = GRVColor.backgroundColor
    }
    
    private func reloadTableView() {
        switch showingCellType {
        case .suggest:              resultTableView.separatorStyle = .none
        case .recently, .searched:  resultTableView.separatorStyle = .singleLine
        }
        
        resultTableView.reloadData()
    }
}

// MARK: - Init Search Bar
extension SearchViewController {
    private func initSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("SearchVideo", comment: "")
        searchBar.showsCancelButton = true
        searchBar.setImage(#imageLiteral(resourceName: "search_favicon"), for: .search, state: .normal)
        searchBar.setImage(#imageLiteral(resourceName: "search_close"), for: .clear, state: .normal)
        searchBar.searchBarStyle = .default
        searchBar.barTintColor = .white
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        
        var cancelButton: UIButton
        let topView: UIView = searchBar.subviews[0] as UIView
        for subView in topView.subviews {
            if subView.isKind(of: NSClassFromString("UINavigationButton")!) {
                cancelButton = subView as! UIButton
                cancelButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
                cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                cancelButton.setTitleColor(GRVColor.mainTextColor, for: .normal)
            }
        }
        
        if let textField = firstSubview(of: UITextField.self, in: searchBar), let label = firstSubview(of: UILabel.self, in: searchBar) {
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
    
    private func firstSubview<T>(of type: T.Type, in view: UIView) -> T? {
        return view.subviews.compactMap { $0 as? T ?? firstSubview(of: T.self, in: $0) }.first
    }
    
    private func initSearchBarTextField() {
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

// MARK: - Keyboard Notification
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

// MARK: - SearchViewDataManagerDelegate
extension SearchViewController: SearchViewDataManagerDelegate {
    func suggestionsUpdated() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
            self.reloadTableView()
        }
    }
    
    func videoListUpdated(canRequestNextPage: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
            self.resultTableView.tableFooterView = canRequestNextPage ? LoadingIndicatorView() : nil
            self.reloadTableView()
        }
    }
    
    func error(api: YoutubeAPI, error: Error) {
        print(error.localizedDescription)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        activityIndicatorView.startAnimating()
        dataManager.requestSuggestionList(keyword: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        dataManager.requestSuggestionList(keyword: trimmedText)
        
        if trimmedText.isEmpty {
            dataManager.updateRecentlyAddedVideos()
            reloadTableView()
        } else {
            activityIndicatorView.startAnimating()
        }
        resultTableView.tableFooterView = nil
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch showingCellType {
        case .suggest:  return dataManager.suggestions.count
        case .recently: return dataManager.recentlyAddedVideos.count
        case .searched: return dataManager.searchedVideos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch showingCellType {
        case .suggest:
            let reuseIdentifier = "SearchSuggestCellIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            if let suggestCell = cell as? SearchSuggestTableViewCell {
                suggestCell.initCell(dataManager.suggestions[indexPath.row])
            }
            return cell
            
        case .recently, .searched:
            let reuseIdentifier = "SearchVideoCellIdentifier"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
            if let videoCell = cell as? SearchVideoTableViewCell, let video = dataManager.video(at: indexPath) {
                videoCell.initCell(video)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch showingCellType {
        case .suggest:              return Constants.Layout.SearchList.heightForSuggest
        case .recently, .searched:  return Constants.Layout.SearchList.heightForVideo
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch showingCellType {
        case .suggest:
            let keyword = dataManager.suggestions[indexPath.row]
            searchBar.text = keyword
            searchBar.resignFirstResponder()
            activityIndicatorView.startAnimating()
            dataManager.requestVideos(suggestion: keyword)
            
        case .recently, .searched:
            var targetVideo: Video {
                if dataManager.searchedVideos.isEmpty == false {
                    return dataManager.searchedVideos[indexPath.row]
                } else {
                    return dataManager.recentlyAddedVideos[indexPath.row]
                }
            }
            delegate?.videoAdded(targetVideo)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard showingCellType == .searched else { return }
        
        if cell is SearchVideoTableViewCell {
            let isLastCell = indexPath.row == (dataManager.searchedVideos.count - 1)
            if isLastCell, let suggestion = searchBar.text {
                dataManager.requestNextPageIfAvailable(suggestion: suggestion)
            }
        }
    }
}
