//
//  SettingVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/23.
//

import UIKit

final class SettingVC: UIViewController, StoryboardController {
    static let identifier = "SettingVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Profile", .phone: "Profile_phone"]

    private var isLogin = UserDefaultsManager.isLogined
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(controllerType: LoginedSettingTableVC.self)
        return storyboard.instantiateViewController(withIdentifier: LoginedSettingTableVC.identifier)
    }()
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(controllerType: UnloginedSettingTableVC.self)
        return storyboard.instantiateViewController(withIdentifier: UnloginedSettingTableVC.identifier)
    }()
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
        self.navigationItem.titleView?.backgroundColor = .white
        self.addTableView()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.updateIfLoginStatusChanged()
    }
}

extension SettingVC {
    private func updateIfLoginStatusChanged() {
        let currentLogin = UserDefaultsManager.isLogined
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
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .tokenExpired, object: nil, queue: .main) { [weak self] _ in
            self?.showAlertWithOK(title: "세션이 만료되었습니다.", text: "다시 로그인 해주시기 바랍니다.") {
                LogoutUsecase.logout()
                NotificationCenter.default.post(name: .showLoginStartVC, object: nil)
            }
        }
    }
}
