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
    
    private var isLoginUI = false {
        didSet {
            if isLoginUI == true {
                self.configureUIForLogined()
            } else {
                self.configureUIForNotLogined()
            }
        }
    }
    
    private lazy var tableViewBeforeLogin: UIViewController = {
        let storyboard = UIStoryboard(controllerType: UnloginedProfileTableVC.self)
        guard let unloginedProfileTableVC = storyboard.instantiateViewController(withIdentifier: UnloginedProfileTableVC.identifier) as? UnloginedProfileTableVC else {
            return UnloginedProfileTableVC()
        }
        unloginedProfileTableVC.tableView.contentInset = .init(top: 27, left: 0, bottom: 27, right: 0)
        return unloginedProfileTableVC
    }()
    
    private lazy var tableViewAfterLogin: UIViewController = {
        let storyboard = UIStoryboard(controllerType: LoginedProfileTableVC.self)
        guard let loginedProfileTableVC = storyboard.instantiateViewController(withIdentifier: LoginedProfileTableVC.identifier) as? LoginedProfileTableVC else {
            return LoginedProfileTableVC()
        }
        loginedProfileTableVC.tableView.contentInset = .init(top: 27, left: 0, bottom: 27, right: 0)
        loginedProfileTableVC.configureNetworkUsecase(NetworkUsecase(network: Network()))
        return loginedProfileTableVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationTitleView.addShadow(direction: .bottom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.isLoginUI = UserDefaultsManager.isLogined
        self.configureUserInfoUI()
    }

    @IBAction func openChangeAccountInfoView(_ sender: Any) {
        let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
        guard let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier) as? ChangeUserInfoVC else { return }
        let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
        nextVC.configureVM(viewModel)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        let storyboard = UIStoryboard(controllerType: LoginStartVC.self)
        let nextVC = storyboard.instantiateViewController(withIdentifier: LoginStartVC.identifier)
        let navigationVC = UINavigationController(rootViewController: nextVC)
        navigationVC.navigationBar.tintColor = UIColor(named: "mainColor")
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true)
    }
}

extension ProfileVC {
    private func configureUIForLogined() {
        self.nameToCircleLeading.constant = 60
        self.changeUserInfoButton.isHidden = false
        self.loginButton.isHidden = true
        self.profileImage.isHidden = false
        self.configureTableView()
    }
    
    private func configureUIForNotLogined() {
        self.nameToCircleLeading.constant = 0
        self.changeUserInfoButton.isHidden = true
        self.loginButton.isHidden = false
        self.profileImage.isHidden = true
        self.configureTableView()
    }
    
    private func configureTableView() {
        let toRemove = self.isLoginUI ? tableViewBeforeLogin : tableViewAfterLogin
        toRemove.willMove(toParent: nil)
        toRemove.view.removeFromSuperview()
        toRemove.removeFromParent()
        
        let target = self.isLoginUI ? tableViewAfterLogin : tableViewBeforeLogin
        target.view.frame = self.containerView.bounds
        self.containerView.addSubview(target.view)
        self.addChild(target)
        target.didMove(toParent: self)
    }
    
    private func configureUserInfoUI() {
        if isLoginUI {
            guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
            self.name.text = userInfo.nickName
        } else {
            self.name.text = "로그인이 필요합니다"
        }
    }
}
