//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class ProfileVC: UIViewController {
    lazy var profileView: ProfileView = {
        let view = ProfileView(isLogined: true)
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
