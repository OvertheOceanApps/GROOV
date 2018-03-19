//
//  SettingsViewController.swift
//  groov
//
//  Created by KimFeeLGun on 2016. 7. 7..
//  Copyright © 2016년 PilGwonKim. All rights reserved.
//

import UIKit
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

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet var dismissBarButton: UIBarButtonItem!
    @IBOutlet var mainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.setNavigationBarBackgroundColor()
        self.initComponents()
    }
    
    func initComponents() {
        self.mainTableView.backgroundColor = GRVColor.backgroundColor
        self.dismissBarButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : GRVColor.mainTextColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)], for: .normal)
    }
}

// MARK: Functions
extension SettingsViewController {
    
    func clearCache() {
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache {
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(.success)
            warning.configureDropShadow()
            
            warning.configureTheme(backgroundColor: UIColor.init(netHex: 0x292b30), foregroundColor: UIColor.white)
            warning.configureContent(body: "이미지 캐시 삭제됨")
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
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
            warning.configureContent(body: "폴더/비디오 삭제됨")
            warning.button?.isHidden = true
            
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
            warningConfig.duration = .seconds(seconds: 0.5)
            
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    func goLibrariesVC() {
        let libraryVC = self.storyboard?.instantiateViewController(withIdentifier: StoryboardId.Library) as! LibraryViewController
        self.navigationController?.pushViewController(libraryVC, animated: true)
    }
    
    func sendMail() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["rlavlfrnjs12@gmail.com"])
        mailVC.setSubject("Service feedback for groov")
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailVC, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error Occurred", message: "Cannot send mail", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
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
extension SettingsViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 4
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
            titleLabel.text = "데이터"
        default:
            titleLabel.text = "앱 정보"
        }
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = GRVColor.mainTextColor
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SettingsCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.backgroundColor = GRVColor.backgroundColor
        cell.contentView.backgroundColor = GRVColor.backgroundColor
        
        switch indexPath.section {
        case 0: // Sections.Data
            cell.accessoryType = .none
            switch indexPath.row {
            case 0: // Sections.Data.RemoveCache
                cell.textLabel?.text = "이미지 캐시 지우기"
            default: // Sections.Data.RemoveRealm
                cell.textLabel?.text = "폴더/비디오 지우기"
            }
        default: // Sections.Info
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0: // Sections.Info.Version
                cell.textLabel?.text = "현재 버전 \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)"
                cell.accessoryType = .none
            case 1: // Sections.Info.SendMail
                cell.textLabel?.text = "문의 메일 보내기"
                cell.accessoryType = .disclosureIndicator
            case 2: // Sections.Info.Facebook
                cell.textLabel?.text = "페이스북 바로가기"
                cell.accessoryType = .disclosureIndicator
            default:
                cell.textLabel?.text = "오픈 소스 라이브러리"
                cell.accessoryType = .disclosureIndicator
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Sections.Data
            switch indexPath.row {
            case 0: // Sections.Data.RemoveCache
                self.clearCache()
            default: // Sections.Data.RemoveRealm
                self.clearRealm()
            }
        default: // Sections.Info
            switch indexPath.row {
            case 0: // Sections.Info.Version
                break
            case 1: // Sections.Info.SendMail
                self.sendMail()
            case 2: // Sections.Info.Facebook
                self.goFacebookPage()
            default:
                self.goLibrariesVC()
            }
        }
    }
}

// MARK: IBActions
extension SettingsViewController {
    
    @IBAction func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}




