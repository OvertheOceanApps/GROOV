//
//  YoutubeAPI.swift
//  groov
//
//  Created by Kyujin Kim on 2020/02/21.
//  Copyright © 2020 Mildwhale. All rights reserved.
//

import Foundation
import Moya

enum YoutubeAPI {
    case suggestion(keyword: String)
    case search(suggestion: String, apiKey: String)
    case videos(ids: [String], apiKey: String)
}

extension YoutubeAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .suggestion:
            return URL(string: "http://google.com")!
            
        case .search, .videos:
            return URL(string: "https://www.googleapis.com")!
        }
    }

    var path: String {
        switch self {
        case .suggestion:
            return "/complete/search"
            
        case .search:
            return "/youtube/v3/search"
            
        case .videos:
            return "/youtube/v3/videos"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .suggestion(let keyword):
            let encodable = YoutubeSuggestionParameter(q: keyword.replacingOccurrences(of: " ", with: "+"))
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain
            
        case .search(let suggestion, let apiKey):
            let encodable = YoutubeSearchParameter(q: suggestion, key: apiKey)
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain

        case .videos(let ids, let apiKey):
            let encodable = YoutubeVideosParameter(ids: ids, apiKey: apiKey)
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }
    
    var validationType: ValidationType { return .none }
    var headers: [String: String]? { return nil }
}

private struct YoutubeSuggestionParameter: Encodable {
    let output: String = "toolbar"
    let ds: String = "yt"
    let hl: String = "en"
    let q: String
}

private struct YoutubeSearchParameter: Encodable {
    let part: String = "id"
    let type: String = "video"
    let maxResults: Int = 10
    let q: String
    let key: String
}

private struct YoutubeVideosParameter: Encodable {
    let part: String = "snippet,contentDetails"
    let id: String
    let type: String = "video"
    let maxResults: Int = 10
    let key: String
    
    init(ids: [String], apiKey: String) {
        id = ids.joined(separator: ",")
        key = apiKey
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        do {
            let encodedData = try JSONEncoder().encode(self)
            if let json = try JSONSerialization.jsonObject(with: encodedData, options: []) as? [String: Any] {
                return json
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    var queryString: String {
        if let json = dictionary {
            var queryItems: [URLQueryItem] = []
            json.forEach { (key, value) in
                if let value = value as? String {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            
            var components = URLComponents()
            components.queryItems = queryItems
            
            guard let queryString = components.query else { return "" }
            return queryString
        }
        
        return ""
    }
}
