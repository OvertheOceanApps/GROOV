//
//  Constants.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2016. 7. 15..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

//struct PlayStyle {
//    static let OneRepeat = "play_style_one_repeat"
//    static let AllRepeat = "play_style_all_repeat"
//    static let Shuffle = "play_style_shuffle"
//}

enum PlayState: String {
    case play, pause
}

struct GRVColor {
    static let mainTextColor = UIColor.init(netHex: 0x80838E)
    static let subTextColor = UIColor.init(netHex: 0x4F525D)
    
    static let backgroundColor = UIColor.init(netHex: 0x1E2124)
    static let separatorColor = UIColor.init(netHex: 0x15191C)
    static let alertViewSeparatorColor = UIColor(netHex: 0xAAAAAA)
    
    static let tableviewRowDeleteColor = UIColor.init(netHex: 0xFF204F)
    
    static let gradationFirstColor = UIColor.init(netHex: 0x5A8EC5)
    static let gradationSecondColor = UIColor.init(netHex: 0x53C5C2)
    static let gradationThirdColor = UIColor.init(netHex: 0x34EFA4)
    static let gradationFourthColor = UIColor.init(netHex: 0x00FF98)
}

struct StoryboardId {
    static let PlaylistList = "SBIdPlaylistList"
    static let GRAlert = "SBIdGRAlert"
    static let VideoList = "SBIdVideoList"
    static let Search = "SBIdSearch"
    static let Settings = "SBIdSettings"
}

struct Constants {
    enum Layout {
    }
}
