//
//  StartVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class StartVC: UIViewController {
    static let identifier = "StartVC"
    static let storyboardName = "StartLogin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func start(_ sender: Any) {
        self.goStartSettingVC()
    }
}

extension StartVC {
    private func goStartSettingVC() {
        let nextVC = UIStoryboard(name: StartSettingVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StartSettingVC.identifier)
        
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
