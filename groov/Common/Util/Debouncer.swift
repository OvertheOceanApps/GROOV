//
//  Debouncer.swift
//  groov
//
//  Created by Kyujin Kim on 03/08/2019.
//  Copyright © 2019 Mildwhale. All rights reserved.
//
import Foundation

final class Debouncer {
    private var interval: TimeInterval
    private var timer: Timer?
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func call(action: @escaping () -> Void) {
        resetTimer()
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: false, block: { (_) in
                action()
            })
        }
    }
    
    func resetTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}
