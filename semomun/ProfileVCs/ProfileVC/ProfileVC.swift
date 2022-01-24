//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var changeUserInfoButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var nameToCircleLeading: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    private var isLogin = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.logined) as? Bool ?? false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let isLoginNow = UserDefaultsManager.get(forKey: UserDefaultsManager.Keys.logined) as? Bool ?? false
        if self.isLogin != isLoginNow {
            self.isLogin = isLoginNow
            configureUI()
            configureTableView()
        }
    }

    @IBAction func changeAccountInfo(_ sender: Any) {
        let storyboard = UIStoryboard(name: ChangeUserinfoPopupVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserinfoPopupVC.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        let storyboard = UIStoryboard(name: LoginStartVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: LoginStartVC.identifier)
        let navigationVC = UINavigationController(rootViewController: nextVC)
        navigationVC.navigationBar.tintColor = UIColor(named: "mainColor")
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true)
    }
    
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(name: ProfileTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: ProfileTableVC.identifier)
    }()
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(name: BeforeLoginProfileTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: BeforeLoginProfileTableVC.identifier)
    }()
}

extension ProfileVC {
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
    
    func configureUI() {
        if isLogin {
            guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
            self.name.text = userInfo.name
            self.nameToCircleLeading.constant = 60
            self.changeUserInfoButton.isHidden = false
            self.loginButton.isHidden = true
            self.profileImage.isHidden = false
        } else {
            self.name.text = "로그인이 필요합니다"
            self.nameToCircleLeading.constant = 0
            self.name.frame = self.name.frame.offsetBy(dx: -41, dy: 0)
            self.changeUserInfoButton.isHidden = true
            self.loginButton.isHidden = false
            self.profileImage.isHidden = true
        }
    }
}
