//
//  GRAlertViewController.swift
//  groov
//
//  Created by PilGwonKim on 2018. 3. 18..
//  Copyright © 2018년 PilGwonKim. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

protocol GRAlertViewControllerDelegate: class {
    func alertViewAddButtonTouched(title: String)
}

class GRAlertViewController: BaseViewController {
    private let backgroundView: UIView = UIView()
    private let alertView: UIView = UIView()
    private let folderImageView: UIImageView = UIImageView()
    private let descriptionLabel: UILabel = UILabel()
    private let titleTextField: UITextField = UITextField()
    private let textFieldBottomLine: UIView = UIView()
    private let cancelButton: UIButton = UIButton(type: .system)
    private let addButton: UIButton = UIButton(type: .system)
    private let buttonTopLine: UIView = UIView()
    private let buttonSeparatorLine: UIView = UIView()
    
    private var alertViewTop: Constraint?
    
    weak var delegate: GRAlertViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        view.addSubview(backgroundView)
        view.addSubview(alertView)
        
        alertView.addSubview(folderImageView)
        alertView.addSubview(descriptionLabel)
        alertView.addSubview(titleTextField)
        alertView.addSubview(textFieldBottomLine)
        alertView.addSubview(cancelButton)
        alertView.addSubview(addButton)
        alertView.addSubview(buttonTopLine)
        alertView.addSubview(buttonSeparatorLine)
    }
        
    override func layout() {
        super.layout()
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints {
            alertViewTop = $0.top.equalToSuperview().inset(200).constraint
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(250)
        }
        
        folderImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(35)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(45)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(folderImageView.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(268)
            $0.height.equalTo(20)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(230)
            $0.height.equalTo(25)
        }
        
        textFieldBottomLine.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(titleTextField)
            $0.height.equalTo(1)
        }

        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(45)
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(45)
        }
        
        buttonTopLine.snp.makeConstraints {
            $0.bottom.equalTo(cancelButton.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        buttonSeparatorLine.snp.makeConstraints {
            $0.leading.equalTo(cancelButton.snp.trailing)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(cancelButton)
            $0.width.equalTo(1)
        }
    }
        
    override func style() {
        super.style()
        
        view.backgroundColor = .clear
        
        backgroundView.alpha = 0.5
        backgroundView.backgroundColor = UIColor.black
        
        alertView.backgroundColor = GRVColor.backgroundColor
        
        folderImageView.image = Asset.addFolderThumbnail.image
        folderImageView.contentMode = .scaleAspectFit
        folderImageView.clipsToBounds = true
        
        descriptionLabel.text = L10n.addPlaylist
        descriptionLabel.textColor = UIColor(patternImage: Asset.loadingGradationMiddle.image)
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textAlignment = .center
        
        titleTextField.textColor = UIColor.white
        titleTextField.placeHolderColor = GRVColor.alertViewSeparatorColor
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        titleTextField.placeholder = L10n.folderTitleTextFieldPlaceHolder
        titleTextField.autocapitalizationType = .none
        titleTextField.autocorrectionType = .no
        titleTextField.smartDashesType = .no
        titleTextField.smartInsertDeleteType = .no
        titleTextField.smartQuotesType = .no
        titleTextField.spellCheckingType = .no
        titleTextField.returnKeyType = .done
        
        textFieldBottomLine.backgroundColor = GRVColor.alertViewSeparatorColor
        
        cancelButton.setTitle(L10n.cancel, for: .normal)
        cancelButton.setTitleColor(GRVColor.alertViewSeparatorColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        addButton.setTitle(L10n.add, for: .normal)
        addButton.setTitleColor(UIColor(patternImage: Asset.loadingGradationShort.image), for: .normal)
        addButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        buttonTopLine.backgroundColor = UIColor.black
        
        buttonSeparatorLine.backgroundColor = UIColor.black
    }
        
    override func behavior() {
        super.behavior()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        cancelButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.dismissWithFade()
            }
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if let text = self.titleTextField.text, text != "" {
                    self.titleTextField.resignFirstResponder()
                    self.delegate?.alertViewAddButtonTouched(title: text)
                    self.dismissWithFade()
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            alertViewTop?.update(inset: (keyboardSize.origin.y - alertView.height) / 2)
            view.layoutIfNeeded()
        }
    }
}
