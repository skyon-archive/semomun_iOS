//
//  ProfileView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/14.
//

import UIKit

final class ProfileView: UIView {
    /* public */
    class ButtonWithImage: UIButton {
        init(image: SemomunImage, title: String) {
            super.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.setImageWithSVGTintColor(image: .init(image), color: .black)
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = .heading5
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    let payStatusView = PayStatusView()
    let changeUserInfoButton = ButtonWithImage(image: .pencilAltOutline, title: "개인정보 수정")
    let logoutButton = ButtonWithImage(image: .logoutOutline, title: "로그아웃")
    let tableView: UITableView = {
        let view = UITableView()
        view.register(ProfileTableCell.self, forCellReuseIdentifier: ProfileTableCell.identifier)
        return view
    }()
    /* private */
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        let image = UIImage(.profile)
        view.image = image
        view.widthAnchor.constraint(equalToConstant: 48).isActive = true
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return view
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.textColor = UIColor.getSemomunColor(.black)
        return label
    }()
    
    init(isLogined: Bool) {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUsername(to username: String) {
        self.usernameLabel.text = username
    }
}

extension ProfileView {
    private func configureLayout() {
        self.addSubviews(self.contentView, self.payStatusView, self.profileImageView, self.usernameLabel, self.changeUserInfoButton, self.logoutButton, self.tableView)
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 176),
            self.contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            
            self.payStatusView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 24),
            self.payStatusView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            
            self.profileImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 24),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            
            self.usernameLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12),
            self.usernameLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            
            self.changeUserInfoButton.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 14),
            self.changeUserInfoButton.leadingAnchor.constraint(equalTo: self.profileImageView.leadingAnchor),
            
            self.logoutButton.topAnchor.constraint(equalTo: self.changeUserInfoButton.bottomAnchor, constant: 8),
            self.logoutButton.leadingAnchor.constraint(equalTo: self.profileImageView.leadingAnchor),
            
            self.tableView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 24),
            self.tableView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -32),
            self.tableView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32),
        ])
    }
}
