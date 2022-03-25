//
//  SemopayCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/27.
//

import UIKit

typealias SemopayCellNetworkUsecase = WorkbookSearchable

final class SemopayCell: UITableViewCell {
    static let identifier = "SemopayCell"
    
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var historyTitle: UILabel!
    @IBOutlet private weak var cost: UILabel!
}

// MARK: Cell 정보 configure
extension SemopayCell {
    func configureCell(using purchase: PurchasedItem) {
        self.setTitle(using: purchase)
        self.setCostLabel(transaction: purchase.transaction)
        self.setDate(using: purchase.createdDate)
    }
}

extension SemopayCell {
    private func setTitle(using purchase: PurchasedItem) {
        self.historyTitle.text = self.isPurchaseCharge(purchase) ? "세모페이 충전" : purchase.title
    }
    
    private func setCostLabel(transaction: Transaction) {
        let costColor = self.getCostLabelColor(transaction: transaction)
        let cost = self.getCostLabelNumberPart(transaction: transaction)
        
        let costRange = NSRange(location: 0, length: cost.count)
        let costWithWon = cost + "원"
        
        let attrCostString = NSMutableAttributedString(string: costWithWon)
        let costAttr = [
            NSAttributedString.Key.foregroundColor: costColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        attrCostString.addAttributes(costAttr, range: costRange)
        self.cost.attributedText = attrCostString
    }
    
    private func setDate(using date: Date) {
        self.date.text = date.yearMonthDayText
    }
    
    private func isPurchaseCharge(_ purchase: PurchasedItem) -> Bool {
        if case .charge = purchase.transaction {
            return true
        } else {
            return false
        }
    }
    
    private func getCostLabelNumberPart(transaction: Transaction) -> String {
        switch transaction {
        case .charge(let text):
            return "+\(text)"
        case .purchase(let text):
            return "-\(text)"
        case .free:
            return "0"
        }
    }
    
    private func getCostLabelColor(transaction: Transaction) -> UIColor {
        guard let red = UIColor(.costRed), let blue = UIColor(.costBlue) else {
            return .lightGray
        }
        switch transaction {
        case .charge(_):
            return blue
        case .purchase(_), .free:
            return red
        }
    }
}
