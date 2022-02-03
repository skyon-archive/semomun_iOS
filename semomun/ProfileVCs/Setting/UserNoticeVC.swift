//
//  UserNoticeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import UIKit

final class UserNoticeVC: UIViewController {
    private let noticeList = UITableView()
    private let backgroundFrame = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "공지사항"
        self.view.backgroundColor = .white
        
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
        
        self.noticeList.register(UserNoticeCell.self, forCellReuseIdentifier: UserNoticeCell.identifier)
        self.noticeList.dataSource = self
        self.noticeList.delegate = self
        
        self.view.addSubview(self.backgroundFrame)
        self.backgroundFrame.backgroundColor = .white
        self.backgroundFrame.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backgroundFrame.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.backgroundFrame.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundFrame.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundFrame.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        self.view.addSubview(noticeList)
        self.noticeList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.noticeList.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.noticeList.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.noticeList.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.noticeList.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        self.backgroundFrame.addShadow(direction: .top)
    }
}

extension UserNoticeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserNoticeCell.identifier) as? UserNoticeCell else { return UITableViewCell() }
        return cell
    }
}

extension UserNoticeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
}
