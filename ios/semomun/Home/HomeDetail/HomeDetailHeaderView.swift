//
//  HomeDetailHeaderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import UIKit

final class HomeDetailHeaderView: UICollectionReusableView {
    /* public */
    static let identifier = "HomeDetailHeaderView"
    lazy var tagList: UserTagListView = {
        let view = UserTagListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    /* private */
    private let orderButton: DropdownOrderButton = DropdownOrderButton(order: .recentUpload)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureOrderButtonLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTagList(editAction: @escaping () -> Void) {
        self.tagList.configureEditButtonAction(action: editAction)
        self.addSubview(self.tagList)
        NSLayoutConstraint.activate([
            self.tagList.centerYAnchor.constraint(equalTo: self.orderButton.centerYAnchor),
            self.tagList.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            self.tagList.trailingAnchor.constraint(equalTo: self.orderButton.leadingAnchor, constant: -12)
        ])
    }
    
    func configureOrderButtonAction(action: @escaping (DropdownOrderButton.SearchOrder) -> Void) {
        self.orderButton.configureSearchMenu(action: action)
    }
}

extension HomeDetailHeaderView {
    private func configureOrderButtonLayout() {
        self.addSubview(self.orderButton)
        NSLayoutConstraint.activate([
            self.orderButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.orderButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
}
