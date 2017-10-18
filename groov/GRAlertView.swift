//
//  GRAlertView.swift
//  groov
//
//  Created by PilGwonKim_MBPR on 2017. 4. 10..
//  Copyright © 2017년 PilGwonKim. All rights reserved.
//

import UIKit

protocol GRAlertViewDelegate {
    func alertViewAddButtonClicked(title: String)
}

class GRAlertView: UIView {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    
    var delegate: GRAlertViewDelegate!
    var backgroundView: UIControl!
    
    func initViews() {
        if let currentWindow = UIApplication.shared.keyWindow {
            self.backgroundView = UIControl(frame: CGRect(x: 0, y: 0, width: currentWindow.width, height: currentWindow.height))
            self.backgroundView.backgroundColor = UIColor.black
            self.backgroundView.alpha = 0.5
            self.backgroundView.addTarget(self, action: #selector(hide), for: .touchUpInside)
        }
        
        self.descriptionLabel.textColor = UIColor.init(patternImage: #imageLiteral(resourceName: "loading_gradation_middle"))
        self.addButton.setTitleColor(UIColor.init(patternImage: #imageLiteral(resourceName: "loading_gradation_short")), for: .normal)
    }
    
    func show() {
        self.removeFromSuperview()
        self.backgroundView.removeFromSuperview()
        
        self.alpha = 0
        self.backgroundView.alpha = 0
        
        if let currentWindow = UIApplication.shared.keyWindow {
            currentWindow.addSubview(self.backgroundView)
            self.center = currentWindow.center
            currentWindow.addSubview(self)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.titleTextField.becomeFirstResponder()
                self.backgroundView.alpha = 1
            }, completion: { (flag) in
            })
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
            })
        }
    }
    
    @objc func hide() {
        self.titleTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.backgroundView.alpha = 0
        }) { (flag) in
            self.titleTextField.text = ""
            self.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
        }
    }
    
    @IBAction func cancelButtonClicked() {
        self.hide()
    }
    
    @IBAction func addButtonClicked() {
        if let text = self.titleTextField.text {
            if text != "" {
                delegate.alertViewAddButtonClicked(title: text)
                self.hide()
            }
        }
    }
}
