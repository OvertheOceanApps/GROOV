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
    case videoId(suggestion: String)
    case videoList(ids: [String])
    case pagination(suggestion: String, token: String)
}

extension YoutubeAPI: TargetType {
    static let key = Bundle.main.object(forInfoDictionaryKey: "YoutubeAPIKey") as! String
    
    var baseURL: URL {
        switch self {
        case .suggestion:
            return URL(string: "http://google.com")!
            
        case .videoId, .videoList, .pagination:
            return URL(string: "https://www.googleapis.com")!
        }
    }

    var path: String {
        switch self {
        case .suggestion:
            return "/complete/search"
            
        case .videoId, .pagination:
            return "/youtube/v3/search"
            
        case .videoList:
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
            
        case .videoId(let suggestion):
            let encodable = YoutubeSearchParameter(q: suggestion, key: YoutubeAPI.key)
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain

        case .videoList(let ids):
            let encodable = YoutubeVideosParameter(ids: ids, apiKey: YoutubeAPI.key)
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain
            
        case .pagination(let suggestion, let token):
            let encodable = YoutubeSearchParameter(q: suggestion, key: YoutubeAPI.key, pageToken: token)
            if let dictionary = encodable.dictionary {
                return .requestParameters(parameters: dictionary, encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }
    
    var validationType: ValidationType { return .none }
    var headers: [String: String]? {
        return [
            "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? ""
        ]
    }
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
    var pageToken: String?
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
