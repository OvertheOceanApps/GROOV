//
//  groovSnapshot.swift
//  groovSnapshot
//
//  Created by Riiid_Pilgwon on 2020/02/26.
//  Copyright © 2020 PilGwonKim. All rights reserved.
//

import XCTest

class groovSnapshot: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        app.launchEnvironment = ["XCUITEST": "1"]
        setupSnapshot(app)
        app.launch()
    }
    
    func testSnapshot() {
    }
}
