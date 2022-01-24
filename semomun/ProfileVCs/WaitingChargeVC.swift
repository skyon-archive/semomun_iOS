//
//  WaitingChargeVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class WaitingChargeVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "WaitingChargeVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func chargeComplete(_ sender: Any) {
        
    }
}