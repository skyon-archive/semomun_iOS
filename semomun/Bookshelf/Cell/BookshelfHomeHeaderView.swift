//
//  BookshelfHomeHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/07.
//

import UIKit

protocol BookshelfHomeDelegate: AnyObject {
    func showAllRecentWorkbooks()
    func showAllRecentPurchaseWorkbooks()
    func showAllPracticeTests()
}

final class BookshelfHomeHeaderView: UICollectionReusableView {
    /* public */
    static let identifier = "BookshelfHomeHeaderView"
    /* private */
    @IBOutlet weak var titleLabel: UILabel!
    private weak var delegate: BookshelfHomeDelegate?
    private var section: Int = 0
    
    @IBAction func showAllCells(_ sender: Any) {
        switch section {
        case 0:
            self.delegate?.showAllRecentWorkbooks()
        case 1:
            self.delegate?.showAllRecentPurchaseWorkbooks()
        case 2:
            self.delegate?.showAllPracticeTests()
        default:
            assertionFailure("BookshelfHomeHeaderView section 개수가 이상합니다.")
        }
    }
    
    func configure(delegate: BookshelfHomeDelegate, section: Int) {
        self.section = section
        switch section {
        case 0:
            self.titleLabel.text = "최근에 푼 문제집"
        case 1:
            self.titleLabel.text = "최근에 구매한 문제집"
        case 2:
            self.titleLabel.text = "실전 모의고사"
        default:
            assertionFailure("BookshelfHomeHeaderView section 개수가 이상합니다.")
        }
    }
}
