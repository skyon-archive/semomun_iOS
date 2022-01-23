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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
        self.name.text = userInfo.name
    }

    @IBAction func changeAccountInfo(_ sender: Any) {
        let storyboard = UIStoryboard(name: ChangeUserinfoPopupVC.storyboardName, bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: ChangeUserinfoPopupVC.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
