//
//  BookshelfHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/06/29.
//

import UIKit

final class BookshelfHeaderView: UICollectionReusableView {
    /* public */
    static let identifier = "BookshelfHeaderView"
    /* private */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var sortSelector: UIButton!
    private weak var delegate: BookshelfOrderController?
    private var isWorkbookGroup: Bool = true
    private var currentOrder: BookshelfSortOrder = .purchase
    
    @IBAction func refresh(_ sender: Any) {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.delegate?.showWarning(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하세요")
            return
        }
        
        self.spinAnimation()
        if UserDefaultsManager.isLogined {
            if self.isWorkbookGroup {
                self.delegate?.reloadWorkbookGroups()
            } else {
                self.delegate?.syncWorkbookGroups()
            }
        }
    }
    
    func configure(title: String, isWorkbookGroup: Bool, delegate: BookshelfOrderController) {
        self.delegate = delegate
        self.isWorkbookGroup = isWorkbookGroup
        self.titleLabel.text = title
        
        if isWorkbookGroup {
            self.configureWorkbookGroupsMenu()
        } else {
            self.configureWorkbooksMenu()
        }
    }
    
    private func spinAnimation() {
        self.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.refreshButton.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
            self.refreshButton.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
            self.layoutIfNeeded()
        } completion: { _ in
            self.refreshButton.transform = CGAffineTransform.identity
        }
    }
    
    private func configureWorkbookGroupsMenu() {
        let purchaseAction = UIAction(title: BookshelfSortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .purchase)
        }
        let recentAction = UIAction(title: BookshelfSortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .recent)
        }
        let alphabetAction = UIAction(title: BookshelfSortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .alphabet)
        }
        if let order = UserDefaultsManager.workbookGroupsOrder {
            self.currentOrder = BookshelfSortOrder(rawValue: order) ?? .purchase
        }
        self.sortSelector.setTitle(self.currentOrder.rawValue, for: .normal)
        self.sortSelector.menu = UIMenu(title: "정렬 리스트", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.sortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func configureWorkbooksMenu() {
        let purchaseAction = UIAction(title: BookshelfSortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .purchase)
        }
        let recentAction = UIAction(title: BookshelfSortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .recent)
        }
        let alphabetAction = UIAction(title: BookshelfSortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .alphabet)
        }
        if let order = UserDefaultsManager.bookshelfOrder {
            self.currentOrder = BookshelfSortOrder(rawValue: order) ?? .purchase
        }
        self.sortSelector.setTitle(self.currentOrder.rawValue, for: .normal)
        self.sortSelector.menu = UIMenu(title: "정렬 리스트", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.sortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func changeSort(to order: BookshelfSortOrder) {
        self.currentOrder = order
        self.sortSelector.setTitle(order.rawValue, for: .normal)
        
        if isWorkbookGroup {
            UserDefaultsManager.workbookGroupsOrder = order.rawValue
        } else {
            UserDefaultsManager.bookshelfOrder = order.rawValue
        }
        
        if UserDefaultsManager.isLogined {
            if isWorkbookGroup {
                self.delegate?.reloadWorkbookGroups()
            } else {
                self.delegate?.reloadWorkbooks()
            }
        }
    }
}
