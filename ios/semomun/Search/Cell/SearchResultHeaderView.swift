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
    private lazy var segmentedControl = SegmentedControlWithCountView(buttons: [
        SegmentedCountButtonInfo(title: "문제집", count: 0) { [weak self] in
            self?.delegate?.changeType(to: .workbook)
        },
        SegmentedCountButtonInfo(title: "실전 모의고사", count: 0) { [weak self] in
            self?.delegate?.changeType(to: .workbookGroup)
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
    
    func configure(delegate: SearchOrderDelegate, workbookCount: Int, workbookGroupCount: Int, currentType: SearchVC.SearchType, order: DropdownOrderButton.SearchOrder) {
        self.delegate = delegate
        self.orderButton.changeOrder(to: order)
        self.segmentedControl.updateCount(index: 0, to: workbookCount)
        self.segmentedControl.updateCount(index: 1, to: workbookGroupCount)
        if currentType == .workbook {
            self.segmentedControl.selectIndex(to: 0)
        } else {
            self.segmentedControl.selectIndex(to: 1)
        }
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
