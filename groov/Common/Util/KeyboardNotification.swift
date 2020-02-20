//
//  KeyboardNotification.swift
//  groov
//
//  Created by Kyujin Kim on 01/10/2019.
//  Copyright © 2019 Mildwhale. All rights reserved.
//

import UIKit

final class KeyboardNotification {
    var isShowing: Bool {
        return notification.name == UIResponder.keyboardWillShowNotification ||
            notification.name == UIResponder.keyboardDidShowNotification
    }
    
    var beginFrame: CGRect {
        return notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect ?? .zero
    }
    
    var endFrame: CGRect {
        return notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
    }
    
    var duration: TimeInterval {
        return (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
    }
    
    var curve: UIView.AnimationOptions {
        let rawValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseOut.rawValue
        return UIView.AnimationOptions(rawValue: rawValue)
    }
    
    let notification: Notification
    init?(_ notification: Notification) {
        let compatibleNames = [UIResponder.keyboardWillShowNotification,
                               UIResponder.keyboardWillHideNotification,
                               UIResponder.keyboardDidShowNotification,
                               UIResponder.keyboardDidHideNotification]
        guard compatibleNames.contains(notification.name) else {
            return nil
        }
        self.notification = notification
    }
}
