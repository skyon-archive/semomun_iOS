//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class ProfileVC: UIViewController {
    
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeUserInfoButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    /// 유저 닉네임과 프로필 사진간 수평 거리
    @IBOutlet weak var nameToCircleLeading: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    private var isLogin = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
    
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(name: UnloginedProfileTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: UnloginedProfileTableVC.identifier)
    }()
    
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(name: LoginedProfileTableVC.storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: LoginedProfileTableVC.identifier)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.updateIfLoginStatusChanged()
    }

    @IBAction func openChangeAccountInfoView(_ sender: Any) {
        let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier)
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
    
    private func configureUI() {
        self.nameToCircleLeading.constant = isLogin ? 60 : 0
        self.changeUserInfoButton.isHidden = !isLogin
        self.loginButton.isHidden = isLogin
        self.profileImage.isHidden = !isLogin
        if isLogin {
            guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
            self.name.text = userInfo.name
        } else {
            self.name.text = "로그인이 필요합니다"
            self.name.frame = self.name.frame.offsetBy(dx: -41, dy: 0)
        }
    }
    
    private func updateIfLoginStatusChanged() {
        guard let isLoginNow = UserDefaultsManager.get(forKey: .logined) as? Bool else { return }
        if self.isLogin != isLoginNow {
            self.isLogin = isLoginNow
            self.configureUI()
            self.configureTableView()
        }
    }
}
