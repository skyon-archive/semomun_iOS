//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class ProfileVC: UIViewController {
    lazy var profileView: ProfileView = {
        let view = ProfileView(isLogined: true, delegate: self)
        return view
    }()
    override func loadView() {
        self.view = self.profileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.profileView.updateUsername(to: "asd")
    }
}

extension ProfileVC: ProfileViewDelegate {
    func showChangeUserInfo() {
        
    }
    
    func logout() {
        
    }
    
    func showPayHistory() {
        
    }
    
    func showNotice() {
        
    }
    
    func showServiceCenter() {
        
    }
    
    func showErrorReport() {
        
    }
    
    func resignAccount() {
        
    }
    
    func showTermsAndCondition() {
        
    }
    
    func showPrivacyPolicy() {
        
    }
    
    func showMarketingAgree() {
        
    }
    
    func showTermsOfTransaction() {
        
    }
}
