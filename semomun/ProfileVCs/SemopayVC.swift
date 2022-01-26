//
//  SemopayVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class SemopayVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SemopayVC"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
