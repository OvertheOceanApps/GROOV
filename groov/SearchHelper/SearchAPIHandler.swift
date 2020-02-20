//
//  SearchAPIHandler.swift
//  groov
//
//  Created by Kyujin Kim on 2020/02/20.
//  Copyright © 2020 Mildwhale. All rights reserved.
//

import Foundation
import Moya
import SWXMLHash

final class SearchAPIHandler {
    typealias SuggestionCompletionHandler = ([String]) -> ()
    typealias GetVideosCompletionHandler = ([Video]) -> ()
    
    private let kAPIKeyYoutube: String = Bundle.main.object(forInfoDictionaryKey: "YoutubeAPIKey") as! String
    private let provider = MoyaProvider<YoutubeAPI>(plugins: [NetworkLoggerPlugin()])
    
    private var latestSuggestion: String? {
        didSet {
            if oldValue != latestSuggestion {
                nextPageToken = nil
            }
        }
    }
    // TODO: pageToken & Pagination
    private var nextPageToken: String?
    
    // MARK: - Function
    func requestSuggestion(of keyword: String, completionHandler: @escaping SuggestionCompletionHandler) {
        provider.request(.suggestion(keyword: keyword)) { result in
            var suggestions: [String] = []
            
            switch result {
            case .success(let response):
                SWXMLHash.parse(response.data)["toplevel"]["CompleteSuggestion"].all.forEach {
                    guard let element = $0["suggestion"].element, let data = element.attribute(by: "data") else { return }
                    suggestions.append(data.text)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            completionHandler(suggestions)
        }
    }
    
    func requestVideos(of suggestion: String, completionHandler: @escaping GetVideosCompletionHandler) {
        provider.request(.search(suggestion: suggestion, apiKey: kAPIKeyYoutube)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = try response.mapJSON() as? [String: Any] {
                        var ids: [String] = []
                        
                        if let items = json["items"] as? [[String: AnyObject]] {
                            items.forEach {
                                if let videoId = $0["id"] as? [String: AnyObject], let id = videoId["videoId"] as? String {
                                    ids.append(id)
                                }
                            }
                        }
                        
                        self.requestVideos(of: ids, completionHandler: completionHandler)
                        return
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            completionHandler([])
        }
    }
    
    private func requestVideos(of videoIds: [String], completionHandler: @escaping GetVideosCompletionHandler) {
        provider.request(.videos(ids: videoIds, apiKey: kAPIKeyYoutube)) { result in
            var videos: [Video] = []
            
            switch result {
            case .success(let response):
                do {
                    if let json = try response.mapJSON() as? [String: Any] {
                        if let items = json["items"] as? [[String: AnyObject]] {
                            items.forEach {
                                videos.append(Video(dict: $0))
                            }
                        }
                    }
                    
                    completionHandler(videos)
                    return
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            completionHandler(videos)
        }
    }
}
