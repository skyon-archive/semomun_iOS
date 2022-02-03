//
//  UserNoticeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import UIKit

typealias UserNoticeNetworkUsecase = UserNoticeFetchable

final class UserNoticeVC: UIViewController {
    private let noticeList = UITableView()
    private let backgroundFrame = UIView()
    private let networkUsecase: UserNoticeNetworkUsecase? = NetworkUsecase(network: Network())
    private var notices: [UserNotice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "공지사항"
        self.navigationItem.backButtonTitle = "목록"
        self.view.backgroundColor = .white
        self.configureBackgroundLayout()
        self.configureTableViewLayout()
        self.configureTableView()
        self.networkUsecase?.getUserNotices { [weak self] status, userNotices in
            if status == .SUCCESS {
                self?.notices = userNotices
            } else {
                self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크 연결을 확인해주세요") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.backgroundFrame.addShadow(direction: .top)
    }
}

extension UserNoticeVC {
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
        self.backgroundFrame.backgroundColor = .white
        self.backgroundFrame.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.backgroundFrame)
        NSLayoutConstraint.activate([
            self.backgroundFrame.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundFrame.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundFrame.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundFrame.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func configureTableViewLayout() {
        self.view.addSubview(noticeList)
        self.noticeList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.noticeList.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.noticeList.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.noticeList.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.noticeList.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 25)
        ])
    }
}

extension UserNoticeVC {
    private func configureTableView() {
        self.noticeList.register(UserNoticeCell.self, forCellReuseIdentifier: UserNoticeCell.identifier)
        self.noticeList.dataSource = self
        self.noticeList.delegate = self
    }
}

extension UserNoticeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserNoticeCell.identifier) as? UserNoticeCell else { return UITableViewCell() }
        cell.configure(using: self.notices[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserNoticeContentVC()
        vc.configureContent(using: self.notices[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserNoticeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
}
