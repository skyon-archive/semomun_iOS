//
//  ProfileVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class ProfileVC: UIViewController {
    lazy var profileView: ProfileView = {
        let view = ProfileView(isLogined: true)
        return view
    }()
    override func loadView() {
        self.view = self.profileView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.profileView.updateUsername(to: "asd")
        self.profileView.tableView.delegate = self
        self.profileView.tableView.dataSource = self
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if UserDefaultsManager.isLogined {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserDefaultsManager.isLogined {
            return [1, 4, 5][section]
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableCell.identifier, for: indexPath) as? ProfileTableCell else { return .init() }
        if UserDefaultsManager.isLogined {
            let content = [
                ["구매 내역"],
                ["공지사항", "고객센터", "오류 신고", "회원탈퇴"],
                ["버전정보", "이용약관", "개인정보 처리 방침", "마케팅 수신 동의", "전자금융거래 이용약관"]
            ]
            cell.changeText(to: content[indexPath.section][indexPath.item])
        } else {
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if UserDefaultsManager.isLogined {
            return [nil, " ", "앱정보 및 이용약관"][section]
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UserDefaultsManager.isLogined {
            return 66
        } else {
            return 0
        }
    }
    
    @IBAction func login(_ sender: Any) {
        NotificationCenter.default.post(name: .showLoginStartVC, object: nil)
    }
}

final class ProfileTableCell: UITableViewCell {
    static let identifier = "ProfileTableCell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeText(to text: String) {
        var configuration = self.defaultContentConfiguration()
        configuration.text = text
        configuration.textProperties.font = .largeStyleParagraph
        self.contentConfiguration = configuration
    }
}
