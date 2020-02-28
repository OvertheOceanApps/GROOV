//
//  Extensions.swift
//  groov
//
//  Created by KimFeeLGun on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit

extension Date {
    func getRelativeTime(_ toTime: Date) -> String {
        var seconds: Int = Int(timeIntervalSince(toTime))
        var timeSuffix: String = ""
        
        if seconds >= 0 { // self가 toTime보다 미래
            timeSuffix = "ago"
        } else { // self가 toTime보다 과거
            seconds *= -1
            timeSuffix = "후"
        }
        
        let minutes: Int = seconds / 60
        let hours: Int = minutes / 60
        let days: Int = hours / 24
        let months: Int = days / 30
        let years: Int = months / 12
        
        var timeString = ""
        if seconds < 60 {
            timeString = "\(seconds) seconds"
        } else if minutes < 60 {
            timeString = "\(minutes) minutes"
        } else if hours < 24 {
            timeString = "\(hours) hours"
        } else if days < 30 {
            timeString = "\(days) days"
        } else if months < 12 {
            timeString = "\(months) months"
        } else {
            timeString = "\(years) years"
        }
        
        return "\(timeString) \(timeSuffix)"
    }
}

extension UIView {
    var width: CGFloat { return frame.size.width }
    var height: CGFloat { return frame.size.height }
    var size: CGSize { return frame.size}
    
    var origin: CGPoint { return frame.origin }
    var x: CGFloat { return frame.origin.x }
    var y: CGFloat { return frame.origin.y }
    var centerX: CGFloat { return center.x }
    var centerY: CGFloat { return center.y }
    
    var left: CGFloat { return frame.origin.x }
    var right: CGFloat { return frame.origin.x + frame.size.width }
    var top: CGFloat { return frame.origin.y }
    var bottom: CGFloat { return frame.origin.y + frame.size.height }
    
    func setWidth(_ width: CGFloat) {
        frame.size.width = width
    }
    
    func setHeight(_ height: CGFloat) {
        frame.size.height = height
    }
    
    func setSize(_ size: CGSize) {
        frame.size = size
    }
    
    func setOrigin(_ point: CGPoint) {
        frame.origin = point
    }
    
    func setX(_ x: CGFloat) {
        frame.origin = CGPoint(x: x, y: frame.origin.y)
    }
    
    func setY(_ y: CGFloat) {
        frame.origin = CGPoint(x: frame.origin.x, y: y)
    }
    
    func setCenterX(_ x: CGFloat) {
        center = CGPoint(x: x, y: center.y)
    }
    
    func setCenterY(_ y: CGFloat) {
        center = CGPoint(x: center.x, y: y)
    }
    
    func setTop(_ top: CGFloat) {
        frame.origin.y = top
    }
    
    func setLeft(_ left: CGFloat) {
        frame.origin.x = left
    }
    
    func setRight(_ right: CGFloat) {
        frame.origin.x = right - frame.size.width
    }
    
    func setBottom(_ bottom: CGFloat) {
        frame.origin.y = bottom - frame.size.height
    }
    
    func roundCorner(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func border(_ radius: CGFloat, color: UIColor, width: CGFloat) {
        layer.cornerRadius = radius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.masksToBounds = true
    }
    
    func layerGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame.size = frame.size
        gradient.colors = [GRVColor.gradationFirstColor.cgColor, GRVColor.gradationFourthColor.cgColor]
        gradient.locations = [0.0, 1.0]
        layer.addSublayer(gradient)
    }
}

extension Array {
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }
}

extension String {
    func getYoutubeFormattedDuration() -> String {
        let formattedDuration = replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with: ":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.count > 0 ? duration + ":" : duration
            if component.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        return duration
    }
    
    init(hms: (Int, Int, Int)) {
        let hour = hms.1 < 10 ? "0\(hms.1)" : "\(hms.1)"
        let sec = hms.2 < 10 ? "0\(hms.2)" : "\(hms.2)"
        self = "\(hms.0):\(hour):\(sec)"
    }
}

extension Int {
    func secToHMS() -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
}

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UIViewController {
    func presentWithFade(targetVC: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let transition = CATransition.init()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            self.view.window?.layer.add(transition, forKey: nil)
            targetVC.modalPresentationStyle = .overCurrentContext
            self.present(targetVC, animated: false, completion: nil)
        }
    }
    
    func dismissWithFade() {
        let transition = CATransition.init()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        view.window?.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }
}
