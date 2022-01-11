//
//  StartViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/11.
//

import UIKit

class StartViewController: UIViewController {
    static let identifier = "StartViewController"

    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    @IBAction func start(_ sender: Any) {
        self.goSelectFavoriteVC()
    }
}

extension StartViewController {
    private func configureUI() {
        self.startButton.cornerRadius = 5
    }
    
    private func goSelectFavoriteVC() {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SelectFavoriteViewController.identifier) else { return }
        
        self.title = ""
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
