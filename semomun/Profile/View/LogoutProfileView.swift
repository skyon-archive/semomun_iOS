//
//  LogoutProfileView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/19.
//

import UIKit

final class LogoutProfileView: UIView {
    /* public */
    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
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
        let image = UIImage(.profileGray)
        view.image = image
        view.widthAnchor.constraint(equalToConstant: 48).isActive = true
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return view
    }()
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.font = .heading2
        label.textColor = .getSemomunColor(.lightGray)
        label.text = "로그인이 필요합니다"
        return label
    }()
    private lazy var loginButton: ButtonWithImage = {
        return ButtonWithImage(image: .loginOutline, title: "로그인 / 회원가입", color: .orangeRegular, action: { [weak self] in
            self?.delegate?.login()
        })
    }()
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private weak var delegate: LogoutProfileViewDelegate?
    
    init(delegate: LogoutProfileViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.backgroundColor = UIColor.getSemomunColor(.background)
        self.configureLayout()
        self.configureStackViewContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogoutProfileView {
    private func configureLayout() {
        self.addSubviews(self.contentView, self.profileImageView, self.loginLabel, self.loginButton, self.scrollView)
        self.scrollView.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 96),
            self.contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            
            self.profileImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 24),
            self.profileImageView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            
            self.loginLabel.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            self.loginLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 12),
            
            self.loginButton.centerYAnchor.constraint(equalTo: self.profileImageView.centerYAnchor),
            self.loginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            
            self.scrollView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.widthAnchor),
            
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 24),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -32),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 32),
        ])
    }
    
    private func configureStackViewContent() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "버전 정보 없음"
        
        [
            ProfileDisclosureRow(text: "공지사항", action: { [weak self] in
                self?.delegate?.showNotice()
            }),
            ProfileDisclosureRow(text: "고객센터", action: { [weak self] in
                self?.delegate?.showServiceCenter()
            }),
            ProfileDisclosureRow(text: "오류 신고", action: { [weak self] in
                self?.delegate?.showErrorReport()
            }),
            ProfileDisclosureRow(text: "회원탈퇴", action: { [weak self] in
                self?.delegate?.resignAccount()
            }),
            ProfileSectionRow(text: "앱정보 및 이용약관"),
            ProfileRowWithSubtitle(title: "버전정보", subtitle: version),
            ProfileDisclosureRow(text: "이용약관", action: { [weak self] in
                self?.delegate?.showLongText(type: .termsAndCondition)
            }),
            ProfileDisclosureRow(text: "개인정보 처리 방침", action: { [weak self] in
                self?.delegate?.showLongText(type: .privacyPolicy)
            }),
            ProfileDisclosureRow(text: "마케팅 수신 동의", action: { [weak self] in
                self?.delegate?.showLongText(type: .marketingAgree)
            }),
            ProfileDisclosureRow(text: "전자금융거래 이용약관", action: { [weak self] in
                self?.delegate?.showLongText(type: .termsOfTransaction)
            })
        ].forEach { view in
            self.stackView.addArrangedSubview(view)
            self.stackView.addArrangedSubview(ProfileRowDivider())
            view.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        }
    }
}

