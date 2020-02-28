//
//  TrackUtil.swift
//  groov
//
//  Created by PilGwonKim on 2018. 4. 8..
//  Copyright © 2018년 PilGwonKim. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class TrackUtil: NSObject {
    class func sendPlaylistAddedEvent(title: String) {
        Analytics.logEvent("playlist_added", parameters: [
            AnalyticsParameterItemName: title as NSObject,
            AnalyticsParameterContentType: "playlist" as NSObject
            ])
    }

    class func sendVideoAddedEvent(title: String) {
        Analytics.logEvent("video_added", parameters: [
            AnalyticsParameterItemName: title as NSObject,
            AnalyticsParameterContentType: "video" as NSObject
            ])
    }
}
