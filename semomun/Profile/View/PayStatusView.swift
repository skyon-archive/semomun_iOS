//
//  PayStatusView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/14.
//

import UIKit

final class PayStatusView: UIView {
    /* public */
    class BottomButton: UIButton {
        init(title: String, action: @escaping () -> Void) {
            super.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.setTitle(title, for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = .heading5
            self.widthAnchor.constraint(equalToConstant: 166).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class Divider: UIView {
        convenience init() {
            self.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundColor = UIColor.getSemomunColor(.black)
            self.layer.opacity = 0.19
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: 1),
                self.heightAnchor.constraint(equalToConstant: 26)
            ])
        }
    }
    /* private */
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "세모페이 잔액"
        label.font = .heading4
        label.textColor = UIColor.getSemomunColor(.black)
        return label
    }()
    private let bottomStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.getSemomunColor(.orangeRegular)
        view.heightAnchor.constraint(equalToConstant: 42).isActive = true
        view.alignment = .center
        return view
    }()
    private let payLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading1
        label.textColor = UIColor.getSemomunColor(.blueRegular)
        label.text = "-원"
        return label
    }()
    
    convenience init() {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.cornerRadius = .cornerRadius16
        self.layer.cornerCurve = .continuous
        self.clipsToBounds = true
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 500),
            self.heightAnchor.constraint(equalToConstant: 112)
        ])
        self.configureLayout()
        self.configureButton()
    }
    
    func updateRemainingPay(to pay: Int) {
        self.payLabel.text = "\(pay)원"
    }
}

extension PayStatusView {
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.bottomStackView, self.payLabel)
        
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            self.payLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.payLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
    }
    private func configureButton() {
        [
            BottomButton(title: "충전", action: {}),
            Divider(),
            BottomButton(title: "사용 내역", action: {}),
            Divider(),
            BottomButton(title: "충전 수단", action: {})
        ].forEach {
            self.bottomStackView.addArrangedSubview($0)
        }
    }
}
