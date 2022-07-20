//
//  PayStatusView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/14.
//

import UIKit

final class PayStatusView: UIView {
    /* private */
    private class BottomButton: UIButton {
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
    private class Divider: UIView {
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
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = .cornerRadius16
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
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
        self.layer.cornerRadius = .cornerRadius16
        self.backgroundColor = .getSemomunColor(.white)
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 500),
            self.heightAnchor.constraint(equalToConstant: 112)
        ])
        self.configureLayout()
        self.configureButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addShadowToFrameView(cornerRadius: .cornerRadius16)
    }
    
    func updateRemainingPay(to pay: Int?) {
        if let pay = pay {
            self.payLabel.text = "\(pay.withComma)원"
        } else {
            self.payLabel.text = "-원"
        }
    }
}

extension PayStatusView {
    private func configureLayout() {
        self.addSubview(self.borderView)
        self.borderView.addSubviews(self.titleLabel, self.bottomStackView, self.payLabel)
        
        NSLayoutConstraint.activate([
            self.borderView.topAnchor.constraint(equalTo: self.topAnchor),
            self.borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 16),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 16),
            
            self.bottomStackView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor),
            self.bottomStackView.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor),
            self.bottomStackView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor),
            
            self.payLabel.topAnchor.constraint(equalTo: self.borderView.topAnchor, constant: 16),
            self.payLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -16)
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
