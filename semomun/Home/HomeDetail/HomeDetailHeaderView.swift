//
//  HomeDetailHeaderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import UIKit

class HomeDetailHeaderView: UICollectionReusableView {
    static let identifier = "HomeDetailHeaderView"
    private let orderButton: DropdownOrderButton = DropdownOrderButton(order: .recentUpload)
    private lazy var tagList: UserTagListView = {
        let view = UserTagListView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureOrderButtonLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeDetailHeaderView {
    private func configureOrderButtonLayout() {
        self.addSubview(self.orderButton)
        NSLayoutConstraint.activate([
            self.orderButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.orderButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
        self.orderButton.configureBookshelfMenu(action: { [weak self] order in
            
        })
    }
}
