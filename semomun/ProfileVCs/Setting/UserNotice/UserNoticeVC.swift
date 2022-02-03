//
//  UserNoticeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import UIKit

typealias UserNoticeNetworkUsecase = UserNoticeFetchable

final class UserNoticeVC: UIViewController {
    private let noticeTableView = UITableView()
    private var noticeFetched: [UserNotice] = []
    private let backgroundShadowView = UIView()
    private let networkUsecase: UserNoticeNetworkUsecase? = NetworkUsecase(network: Network())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTableView()
        self.getData()
    }
    
    override func viewDidLayoutSubviews() {
        self.backgroundShadowView.addShadow(direction: .top)
    }
}

// MARK: Confiure layout
extension UserNoticeVC {
    private func configureUI() {
        self.navigationItem.title = "공지사항"
        self.navigationItem.backButtonTitle = "목록"
        self.view.backgroundColor = .white
        self.configureBackgroundLayout()
        self.configureTableViewLayout()
    }
    
    private func configureBackgroundLayout() {
        self.configureBackgroundColorView()
        self.configureBackgroundShadowView()
    }
    
    private func configureBackgroundColorView() {
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(named: SemomunColor.lightGrayBackgroundColor)
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgroundColorView)
        NSLayoutConstraint.activate([
            backgroundColorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            backgroundColorView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            backgroundColorView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureBackgroundShadowView() {
        self.backgroundShadowView.backgroundColor = .white
        self.backgroundShadowView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.backgroundShadowView)
        NSLayoutConstraint.activate([
            self.backgroundShadowView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundShadowView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundShadowView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundShadowView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func configureTableViewLayout() {
        self.view.addSubview(noticeTableView)
        self.noticeTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.noticeTableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.noticeTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.noticeTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.noticeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25)
        ])
    }
}


extension UserNoticeVC {
    private func configureTableView() {
        self.noticeTableView.register(UserNoticeCell.self, forCellReuseIdentifier: UserNoticeCell.identifier)
        self.noticeTableView.dataSource = self
        self.noticeTableView.delegate = self
    }
    private func getData() {
        self.networkUsecase?.getUserNotices { [weak self] status, userNotices in
            if status == .SUCCESS {
                self?.noticeFetched = userNotices
                self?.noticeTableView.reloadData()
            } else {
                self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크 연결을 확인해주세요") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension UserNoticeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noticeFetched.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserNoticeCell.identifier) as? UserNoticeCell else { return UITableViewCell() }
        cell.configure(using: self.noticeFetched[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserNoticeContentVC()
        vc.configureContent(using: self.noticeFetched[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserNoticeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
}
