//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var navigationTitleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
    }
    

    

}
