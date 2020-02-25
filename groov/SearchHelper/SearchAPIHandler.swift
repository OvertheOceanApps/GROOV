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
    typealias GetVideoIdsSuccessResult = (ids: [String], token: String?)
    
    typealias SuggestionCompletionHandler = (Result<[String], Error>) -> ()
    typealias GetVideoIdsCompletionHandler = (Result<GetVideoIdsSuccessResult, Error>) -> ()
    typealias GetVideosCompletionHandler = (Result<[Video], Error>) -> ()

    #if DEBUG
    private let provider = MoyaProvider<YoutubeAPI>(plugins: [NetworkLoggerPlugin()])
    #else
    private let provider = MoyaProvider<YoutubeAPI>()
    #endif
    
    // MARK: - Function
    func requestSuggestion(of keyword: String, completionHandler: @escaping SuggestionCompletionHandler) -> Cancellable {
        return provider.request(.suggestion(keyword: keyword)) { result in
            switch result {
            case .success(let response):
                var suggestions: [String] = []
                
                SWXMLHash.parse(response.data)["toplevel"]["CompleteSuggestion"].all.forEach {
                    guard let element = $0["suggestion"].element, let data = element.attribute(by: "data") else { return }
                    suggestions.append(data.text)
                }
                
                completionHandler(.success(suggestions))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func requestVideoIds(of suggestion: String, token: String?, completionHandler: @escaping GetVideoIdsCompletionHandler) -> Cancellable {
        var api: YoutubeAPI {
            if let token = token {
                return .pagination(suggestion: suggestion, token: token)
            }
            return .videoId(suggestion: suggestion)
        }
        
        return provider.request(api) { result in
            switch result {
            case .success(let response):
                do {
                    var nextPageToken: String?
                    var ids: [String] = []

                    if let json = try response.mapJSON() as? [String: Any] {
                        if let items = json["items"] as? [[String: AnyObject]] {
                            items.forEach {
                                if let videoId = $0["id"] as? [String: AnyObject], let id = videoId["videoId"] as? String {
                                    ids.append(id)
                                }
                            }
                        }
                        nextPageToken = json["nextPageToken"] as? String
                    }
                    
                    completionHandler(.success((ids, nextPageToken)))
                } catch {
                    completionHandler(.failure(error))
                }
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func requestVideos(with ids: [String], completionHandler: @escaping GetVideosCompletionHandler) -> Cancellable {
        return provider.request(.videoList(ids: ids)) { result in
            switch result {
            case .success(let response):
                do {
                    var videos: [Video] = []
                    
                    if let json = try response.mapJSON() as? [String: Any] {
                        if let items = json["items"] as? [[String: AnyObject]] {
                            items.forEach {
                                videos.append(Video(dict: $0))
                            }
                        }
                    }
                    
                    completionHandler(.success(videos))
                } catch {
                    completionHandler(.failure(error))
                }
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
