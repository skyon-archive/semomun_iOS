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
    private lazy var segmentedControl = SegmentedControlView(buttons: [
        SegmentedButtonInfo(title: "문제집", count: 0) {
            print("문제집")
        },
        SegmentedButtonInfo(title: "실전 모의고사", count: 5) {
            print("실전 모의고사")
        },
        SegmentedButtonInfo(title: "퇴근가능하기", count: 5) {
            print("퇴근")
        }
    ])
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
        self.configureSegmentedControlView()
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
    private func configureSegmentedControlView() {
        self.addSubview(self.segmentedControl)
        NSLayoutConstraint.activate([
            self.segmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            self.segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32)
        ])
    }
    
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
