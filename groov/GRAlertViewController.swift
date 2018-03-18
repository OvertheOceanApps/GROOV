//
//  GRAlertViewController.swift
//  groov
//
//  Created by PilGwonKim on 2018. 3. 18..
//  Copyright © 2018년 PilGwonKim. All rights reserved.
//

import UIKit

protocol GRAlertViewControllerDelegate {
    func alertViewAddButtonTouched(title: String)
}

class GRAlertViewController: UIViewController {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var alertView: UIView!
    @IBOutlet var alertViewTop: NSLayoutConstraint!
    
    var delegate: GRAlertViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleTextField.becomeFirstResponder()
    }
    
    func initViews() {
        // patternize views
        self.descriptionLabel.textColor = UIColor.init(patternImage: #imageLiteral(resourceName: "loading_gradation_middle"))
        self.addButton.setTitleColor(UIColor.init(patternImage: #imageLiteral(resourceName: "loading_gradation_short")), for: .normal)
        
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
}

// MARK: Notification Center
extension GRAlertViewController {
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            alertViewTop.constant = (keyboardSize.origin.y - alertView.height) / 2
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: IBActions
extension GRAlertViewController {
    
    @IBAction func cancelButtonClicked() {
        self.dismissWithFade()
    }
    
    @IBAction func addButtonClicked() {
        if let text = self.titleTextField.text {
            if text != "" {
                self.titleTextField.resignFirstResponder()
                delegate.alertViewAddButtonTouched(title: text)
                self.dismissWithFade()
            }
        }
    }
}
