//
//  SearchResultHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/12.
//

import UIKit

protocol SearchOrderDelegate: AnyObject {
    func changeOrder(to: DropdownOrderButton.SearchOrder)
    func changeType(to: SearchVC.SearchType)
}

final class SearchResultHeaderView: UICollectionReusableView {
    /* public */
    static let identifier = "SearchResultHeaderView"
    /* private */
    private lazy var orderButton = DropdownOrderButton(order: .recentUpload)
    private weak var delegate: SearchOrderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.configureOrderButton()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    func configure(delegate: SearchOrderDelegate) {
        self.delegate = delegate
    }
}

extension SearchResultHeaderView {
    private func configureOrderButton() {
        self.addSubview(self.orderButton)
        NSLayoutConstraint.activate([
            self.orderButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.orderButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
        self.orderButton.configureSearchMenu(action: { [weak self] order in
            self?.delegate?.changeOrder(to: order)
        })
    }
}
