//
//  Video.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 14..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import Foundation
import RealmSwift

class Video: Object {
    @objc dynamic var id: String = UUID().uuidString // unique id
    @objc dynamic var playlistId: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var createdAt: Date = Date()
    // id
    @objc dynamic var kind: String = ""           // id["kind"]
    @objc dynamic var videoId: String = ""        // id["videoId"]
    // snippet
    @objc dynamic var title: String = ""          // snippet["title"]
    @objc dynamic var channelId: String = ""      // snippet["channelId"]
    @objc dynamic var channelTitle: String = ""   // snippet["channelTitlte"]
    @objc dynamic var desc: String =  ""          // snippet["description"]
    @objc dynamic var isLive: String = ""         // snippet["liveBroadcastContent"]
    @objc dynamic var publishedAt: String = ""    // snippet["publishedAt"]
    // snippet - thumbnails
    @objc dynamic var thumbnailDefault: String = ""   // snippet["thumbnails"]["default"]["url"]
    @objc dynamic var thumbnailHigh: String = ""      // snippet["thumbnails"]["high"]["url"]
    @objc dynamic var thumbnailMedium: String = ""    // snippet["thumbnails"]["medium"][""url"]
    // contentDetails
    @objc dynamic var duration: String = "" // contentDetails["duration"]
    
    func publishedAtFormatted() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date: Date = dateFormatter.date(from: publishedAt)!
        return Date().getRelativeTime(date)
    }
    
    func createdAtFormatted() -> String {
        return Date().getRelativeTime(createdAt)
    }
    
    func parseDictionaryToModel(_ dict: Dictionary<String, AnyObject>) {
        print(dict)
        if let videoId = dict["id"] as? String {
            self.videoId = videoId
        }
        if let kind = dict["kind"] as? String {
            self.kind = kind
        }
        if dict["snippet"] != nil {
            if let title = dict["snippet"]!["title"] {
                self.title = title as! String
            }
            if let cId = dict["snippet"]!["channelId"] {
                self.channelId = cId as! String
            }
            if let cTitle = dict["snippet"]!["channelTitle"] {
                self.channelTitle = cTitle as! String
            }
            if let desc = dict["snippet"]!["description"] {
                self.desc = desc as! String
            }
            if let isLive = dict["snippet"]!["liveBroadcastContent"] {
                self.isLive = isLive as! String
            }
            if let publishedAt = dict["snippet"]!["publishedAt"] {
                self.publishedAt = publishedAt as! String
            }
            
            if dict["snippet"]!["thumbnails"] != nil {
                let thumbnails = dict["snippet"]!["thumbnails"] as! Dictionary<String, AnyObject>
                if thumbnails["default"] != nil {
                    if let url = thumbnails["default"]!["url"] {
                        self.thumbnailDefault = url as! String
                    }
                }
                if thumbnails["high"] != nil {
                    if let url = thumbnails["high"]!["url"] {
                        self.thumbnailHigh = url as! String
                    }
                }
                if thumbnails["medium"] != nil {
                    if let url = thumbnails["medium"]!["url"] {
                        self.thumbnailMedium = url as! String
                    }
                }
            }
        }
        if dict["contentDetails"] != nil {
            if let duration = dict["contentDetails"]!["duration"] as? String {
                self.duration = duration.getYoutubeFormattedDuration()
            }
        }
    }
    
    convenience init(dict: Dictionary<String, AnyObject>) {
        self.init()
        parseDictionaryToModel(dict)
    }
    
    func durationString() -> String {
        return duration != "" ? "--:--" : duration
    }
}
