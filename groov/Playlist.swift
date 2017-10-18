//
//  Playlist.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 14..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var recentVideo: String = ""
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var order: Int = 0
    @objc dynamic var playStyle: String = "play_style_all_repeat"
    @objc dynamic var createdAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, recentVideo: String, isFavorite: Bool) {
        self.init()
        self.title = title
        self.recentVideo = recentVideo
        self.isFavorite = isFavorite
    }
}
