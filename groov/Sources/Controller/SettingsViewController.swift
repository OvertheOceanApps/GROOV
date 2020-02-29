//
//  SettingsViewController.swift
//  groov
//
//  Created by KimFeeLGun on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import MessageUI
import Kingfisher
import RealmSwift
import SwiftMessages

struct Sections {
    struct Data {
        static let RemoveCache = "kDataRemoveCache"
        static let RemoveRealm = "kDataRemoveRealm"
    }
    
    struct Info {
        static let Version = "kInfoVersion"
        static let License = "kInfoLicense"
        static let SendMail = "kInfoSendMail"
        static let Facebook = "kInfoFacebook"
    }
}

class SettingsViewController: BaseViewController {
    private let dismissBarButton: UIBarButtonItem = UIBarButtonItem(title: L10n.close, style: .plain, target: nil, action: nil)
    private let mainTableView: UITableView = UITableView()

    private let cellIdentifier = "SettingsCellIdentifier"
    
    override func addSubviews() {
        super.addSubviews()
        
        navigationItem.rightBarButtonItem = dismissBarButton
        
        view.addSubview(mainTableView)
        
        mainTableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
        
    override func layout() {
        super.layout()
        
        mainTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
        
    override func style() {
        super.style()
        
        navigationItem.title = L10n.settings
        setNavigationBarBackgroundColor()
        
        let dismissAttributes = [
            NSAttributedString.Key.foregroundColor: GRVColor.mainTextColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
        ]
        dismissBarButton.setTitleTextAttributes(dismissAttributes, for: .normal)
        dismissBarButton.setTitleTextAttributes(dismissAttributes, for: .highlighted)
        
        mainTableView.backgroundColor = GRVColor.backgroundColor
    }
        
    override func behavior() {
        super.behavior()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        dismissBarButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: Functions
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func clearCache() {
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache {
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(.success)
            warning.configureDropShadow()
            
            warning.configureTheme(backgroundColor: UIColor.init(netHex: 0x292b30), foregroundColor: UIColor.white)
            warning.configureContent(title: "", body: L10n.imageCacheRemoved)
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: .statusBar)
            warningConfig.duration = .seconds(seconds: 0.5)
            
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    func clearRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "clear_realm"), object: nil)
            
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(.success)
            warning.configureDropShadow()
            
            warning.configureTheme(backgroundColor: UIColor.init(netHex: 0x292b30), foregroundColor: UIColor.white)
            warning.configureContent(title: "", body: L10n.folderVideoRemoved)
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: .statusBar)
            warningConfig.duration = .seconds(seconds: 0.5)
            
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    func sendMail() {
        let mailVC = MFMailComposeViewController()
        mailVC.modalPresentationStyle = .fullScreen
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["rlavlfrnjs12@gmail.com"])
        mailVC.setSubject("Service feedback for groov")
        
        if MFMailComposeViewController.canSendMail() {
            present(mailVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error Occurred", message: "Cannot send mail", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func goFacebookPage() {
        let facebookURL = URL(string: "https://www.facebook.com/AppGroov")!
        UIApplication.shared.open(facebookURL, options: [:], completionHandler: nil)
    }
}

// MARK: Table View Datasource, Delegate
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 45))
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 30, width: tableView.width-40, height: 15))
        switch section {
        case 0:
            titleLabel.text = L10n.data
        default:
            titleLabel.text = L10n.appInfo
        }
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = GRVColor.mainTextColor
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsTableViewCell
        
        cell.backgroundColor = GRVColor.backgroundColor
        
        switch indexPath.section {
        case 0: // Sections.Data
            cell.accessoryType = .none
            switch indexPath.row {
            case 0: // Sections.Data.RemoveCache
                cell.titleLabel.text = L10n.removeImageCache
            case 1: // Sections.Data.RemoveRealm
                cell.titleLabel.text = L10n.removeFolderVideo
            default: break
            }
        case 1: // Sections.Info
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0: // Sections.Info.Version
                cell.titleLabel.text = L10n.currentVersion + " " + (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
                cell.accessoryType = .none
            case 1: // Sections.Info.SendMail
                cell.titleLabel.text = L10n.sendMail
                cell.accessoryType = .disclosureIndicator
            case 2: // Sections.Info.Facebook
                cell.titleLabel.text = L10n.visitFacebook
                cell.accessoryType = .disclosureIndicator
            default: break
            }
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Sections.Data
            switch indexPath.row {
            case 0: // Sections.Data.RemoveCache
                clearCache()
            case 1: // Sections.Data.RemoveRealm
                clearRealm()
            default: break
            }
        default: // Sections.Info
            switch indexPath.row {
            case 0: // Sections.Info.Version
                break
            case 1: // Sections.Info.SendMail
                sendMail()
            case 2: // Sections.Info.Facebook
                goFacebookPage()
            default: break
            }
        }
    }
}
