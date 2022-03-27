//
//  SettingVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

final class SettingVC: UIViewController {
    static let identifier = "SettingVC"
    static let storyboardName = "Profile"
    static let storyboardName_phone = "Profile_phone"
    

    private var isLogin = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(name: LoginedSettingTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: LoginedSettingTableVC.identifier)
    }()
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(name: UnloginedSettingTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: UnloginedSettingTableVC.identifier)
    }()
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
        self.navigationItem.titleView?.backgroundColor = .white
        self.addTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.updateIfLoginStatusChanged()
    }
}

extension SettingVC {
    private func updateIfLoginStatusChanged() {
        let currentLogin = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        if self.isLogin != currentLogin {
            self.isLogin = currentLogin
            self.configureTableView()
        }
    }
    private func configureTableView() {
        self.removeTableView()
        self.addTableView()
    }
    
    private func removeTableView() {
        let toRemove = self.isLogin ? tableViewBeforeLogin : tableViewAfterLogin
        toRemove.willMove(toParent: nil)
        toRemove.view.removeFromSuperview()
        toRemove.removeFromParent()
    }
    
    private func addTableView() {
        let target = self.isLogin ? tableViewAfterLogin : tableViewBeforeLogin
        target.view.frame = self.containerView.bounds
        self.containerView.addSubview(target.view)
        self.addChild(target)
        target.didMove(toParent: self)
    }
}
