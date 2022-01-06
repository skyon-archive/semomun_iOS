//
//  PersonalSettingViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import UIKit
import SwiftUI

protocol ReloadUserData: AnyObject {
    func loadData()
}

class PersonalSettingViewController: UIViewController {
    static let identifier = "PersonalSettingViewController"

    @IBOutlet weak var favoriteCategory: UILabel!
    @IBOutlet weak var graduationStatus: UILabel!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var major: UILabel!
    @IBOutlet weak var majorDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        self.loadData()
    }
    
    @IBAction func showSettingUserVC(_ sender: Any) {
        let view = SettingUserView(delegate: self)
        let vc = UIHostingController(rootView: view)
        vc.view.backgroundColor = .clear
        self.present(vc, animated: true, completion: nil)
    }
}

extension PersonalSettingViewController: ReloadUserData {
    func loadData() {
        let userInfo = CoreUsecase.fetchUserInfo()
        print(userInfo)
        self.favoriteCategory.text = userInfo?.favoriteCategory
        self.graduationStatus.text = userInfo?.graduationStatus
        self.schoolName.text = userInfo?.schoolName
        self.major.text = userInfo?.major
        self.majorDetail.text = userInfo?.majorDetail
    }
}
