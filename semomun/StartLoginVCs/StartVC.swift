//
//  StartVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class StartVC: UIViewController {
    static let identifier = "StartVC"
    static let storyboardName = "StartLogin"

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func start(_ sender: Any) {
        self.goSelectFavoriteVC()
    }
}

extension StartVC {
    private func configureUI() {
        self.startButton.clipsToBounds = true
        self.startButton.cornerRadius = 10
    }
    
    private func goSelectFavoriteVC() {
        let nextVC = UIStoryboard(name: StartSettingVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StartSettingVC.identifier)
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
