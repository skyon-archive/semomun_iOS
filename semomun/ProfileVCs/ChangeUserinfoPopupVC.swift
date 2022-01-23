//
//  ChangeUserinfoPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class ChangeUserinfoPopupVC: UIViewController {

    static let storyboardName = "Profile"
    static let identifier = "ChangeUserinfoPopupVC"
    
    private var majorsFromNetwork: [[String: [String]]] = []
    
    @IBOutlet weak var bodyFrame: UIView!
    @IBOutlet weak var nicknameFrame: UIView!
    @IBOutlet weak var nickname: UITextField!
    
    @IBOutlet weak var major: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "계정 정보 변경하기"
        bodyFrame.layer.cornerRadius = 15
        nicknameFrame.layer.borderWidth = 1.5
        nicknameFrame.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        nicknameFrame.layer.cornerRadius = 5
        majors = NetworkUsecase(network: Network()).getMajors { fetched in
            self.majorsFromNetwork = fetched ?? []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension ChangeUserinfoPopupVC: UITableViewDelegate {
    
}

extension ChangeUserinfoPopupVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
