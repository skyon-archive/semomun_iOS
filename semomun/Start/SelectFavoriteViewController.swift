//
//  SelectFavoriteViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import UIKit

class SelectFavoriteViewController: UIViewController {
    static let identifier = "SelectFavoriteViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goMain(_ sender: Any) {
        self.saveUserDefaults()
        self.goMainVC()
    }
}

extension SelectFavoriteViewController {
    private func saveUserDefaults() {
        UserDefaults.standard.setValue("수능모의고사", forKey: "currentCategory")
        UserDefaults.standard.setValue(true, forKey: "logined")
    }
    
    private func goMainVC() {
        guard let mainViewController = self.storyboard?.instantiateViewController(identifier: MainViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.tintColor = UIColor(named: SemomunColor.mainColor)
        
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}
