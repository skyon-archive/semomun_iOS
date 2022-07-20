//
//  UserNoticeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/03.
//

import UIKit

final class UserNoticeVC: UIViewController {
    private let noticeTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.separatorInset = .zero
        view.contentInset = .init(top: 24, left: 0, bottom: 24, right: 0)
        return view
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.white)
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private var noticeFetched: [UserNotice] = []
    private let networkUsecase: NoticeFetchable
    
    init(networkUsecase: NoticeFetchable) {
        self.networkUsecase = networkUsecase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureLayout()
        self.configureTableView()
        self.fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: Configure
extension UserNoticeVC {
    private func configureUI() {
        self.navigationItem.title = "공지사항"
        self.view.backgroundColor = .getSemomunColor(.background)
    }
    
    private func configureLayout() {
        self.view.addSubviews(self.backgroundView, self.noticeTableView)
        NSLayoutConstraint.activate([
            self.backgroundView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.noticeTableView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.noticeTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            self.noticeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.noticeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func configureTableView() {
        self.noticeTableView.register(UserNoticeCell.self, forCellReuseIdentifier: UserNoticeCell.identifier)
        self.noticeTableView.dataSource = self
        self.noticeTableView.delegate = self
    }
}


extension UserNoticeVC {
    private func fetch() {
        self.networkUsecase.getNotices { [weak self] status, userNotices in
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
        let notice = self.noticeFetched[indexPath.row]
        cell.prepareForReuse(using: notice)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notice = self.noticeFetched[indexPath.row]
        let vc = UserNoticeContentVC(userNotice: notice)
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserNoticeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
}
