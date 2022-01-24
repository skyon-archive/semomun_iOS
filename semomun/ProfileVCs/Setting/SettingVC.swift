//
//  SettingVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

class SettingVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SettingVC"

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let currentLogin = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.logined) as? Bool ?? false
        if self.isLogin != currentLogin {
            self.isLogin = currentLogin
            configureTableView()
        }
    }
    
    private func configureTableView() {
        let toRemove = self.isLogin ? tableViewBeforeLogin : tableViewAfterLogin
        toRemove.willMove(toParent: nil)
        toRemove.view.removeFromSuperview()
        toRemove.removeFromParent()
        
        let target = self.isLogin ? tableViewAfterLogin : tableViewBeforeLogin
        target.view.frame = self.containerView.bounds
        self.containerView.addSubview(target.view)
        self.addChild(target)
        target.didMove(toParent: self)
    }
    
    private var isLogin = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.logined) as? Bool ?? false
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(name: SettingTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: SettingTableVC.identifier)
    }()
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(name: BeforeLoginSettingTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: BeforeLoginSettingTableVC.identifier)
    }()
}
