//
//  SearchViewDataManager.swift
//  groov
//
//  Created by Kyujin Kim on 2020/02/24.
//  Copyright © 2020 Mildwhale. All rights reserved.
//

import Foundation
import RealmSwift
import Moya

protocol SearchViewDataManagerDelegate: class {
    func suggestionsUpdated()
    func videoListUpdated(canRequestNextPage: Bool)
    func error(api: YoutubeAPI, error: Error)
}

final class SearchViewDataManager {
    // MARK: - Value
    // MARK: Public
    var suggestions: [String] = [] {
        didSet {
            if oldValue != suggestions {
                delegate?.suggestionsUpdated()
            }
        }
    }
    var recentlyAddedVideos: [Video] = []
    var searchedVideos: [Video] = [] {
        didSet {
            if oldValue != searchedVideos {
                delegate?.videoListUpdated(canRequestNextPage: nextPageToken != nil)
            }
        }
    }
    
    weak var delegate: SearchViewDataManagerDelegate?
    
    // MARK: Private
    private let debouncer: Debouncer = Debouncer(interval: 0.3)
    private var nextPageToken: String?
    
    private var cancellables: [Cancellable] = []
    
    // MARK: - Function
    // MARK: Public
    init() {
        updateRecentlyAddedVideos()
    }
    
    func video(at indexPath: IndexPath) -> Video? {
        if searchedVideos.isEmpty == false, indexPath.row < searchedVideos.count {
            return searchedVideos[indexPath.row]
        } else if recentlyAddedVideos.isEmpty == false, indexPath.row < recentlyAddedVideos.count {
            return recentlyAddedVideos[indexPath.row]
        }
        return nil
    }
    
    func updateRecentlyAddedVideos() {
        let realm = try! Realm()
        recentlyAddedVideos = Array(realm.objects(Video.self).sorted(byKeyPath: "createdAt", ascending: false))
    }
    
    func requestSuggestionList(keyword: String) {
        cancelAllRequest()
        nextPageToken = nil
        suggestions = []
        searchedVideos = []
        
        let trimmedString = keyword.trimmingCharacters(in: .whitespaces)
        guard trimmedString.isEmpty == false else {
            debouncer.resetTimer()
            return
        }
        
        debouncer.call { [weak self] in
            guard let self = self else { return }
            
            let cancellable = SearchAPIHandler().requestSuggestion(of: keyword) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let suggestions):
                    self.suggestions = suggestions
                    
                case .failure(let error):
                    self.delegate?.error(api: .suggestion(keyword: keyword), error: error)
                }
            }
            self.cancellables.append(cancellable)
        }
    }
    
    func requestVideos(suggestion: String) {
        requestVideos(suggestion: suggestion, token: nil)
    }
    
    func requestNextPageIfAvailable(suggestion: String) {
        guard let token = nextPageToken else { return }
        nextPageToken = nil
        
        requestVideos(suggestion: suggestion, token: token)
    }
    
    // MARK: Private
    private func cancelAllRequest() {
        cancellables.forEach {
            if $0.isCancelled == false {
                $0.cancel()
            }
        }
        cancellables.removeAll()
    }
    
    private func requestVideos(suggestion: String, token: String?) {
        let cancellable = SearchAPIHandler().requestVideoIds(of: suggestion, token: token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.nextPageToken = data.token
                self.requestVideos(ids: data.ids, token: token)
                
            case .failure(let error):
                var api: YoutubeAPI {
                    if let token = token {
                        return .pagination(suggestion: suggestion, token: token)
                    }
                    return .videoId(suggestion: suggestion)
                }
                self.delegate?.error(api: api, error: error)
            }
        }
        cancellables.append(cancellable)
    }
    
    private func requestVideos(ids: [String], token: String?) {
        let cancellable = SearchAPIHandler().requestVideos(with: ids) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videos):
                var newVideos: [Video] = []
                if token == nil {
                    newVideos = videos
                } else {
                    newVideos = self.searchedVideos
                    newVideos.append(contentsOf: videos)
                }
                self.searchedVideos = newVideos
                
            case .failure(let error):
                self.delegate?.error(api: .videoList(ids: ids), error: error)
            }
        }
        cancellables.append(cancellable)
    }
}
