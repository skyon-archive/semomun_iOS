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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeCornerRadius()
        self.removeBottomDivider()
    }
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
        func configureCellUI(row: Int, numberOfRowsInSection: Int) {
            if numberOfRowsInSection == 1 {
                self.makeCornerRadius(at: .all)
            } else {
                if row == numberOfRowsInSection - 1 {
                    self.makeCornerRadius(at: .bottom)
                } else {
                    self.addBottomDivider()
                    if row == 0 {
                        self.makeCornerRadius(at: .top)
                    }
                }
            }
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

// MARK: Divider configure
extension SemopayCell {
    static let dividerSublayerName = "SemopayDivider"
    private func addBottomDivider() {
        let dividerColor = UIColor(.divider)
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 20
        let dividerWidth = self.contentView.frame.size.width - 2 * dividerMargin
        let dividerYpos = self.contentView.frame.size.height - dividerHeight
        let border: CALayer = {
            let border = CALayer()
            border.name = Self.dividerSublayerName
            border.backgroundColor = dividerColor?.cgColor
            border.frame = CGRect(x: dividerMargin, y: dividerYpos, width: dividerWidth, height: dividerHeight)
            return border
        }()
        self.contentView.layer.addSublayer(border)
    }
    
    private func removeBottomDivider() {
        self.contentView.layer.sublayers?.removeAll(where: { $0.name == Self.dividerSublayerName})
    }
}

// MARK: Corner radius configure
extension SemopayCell {
    private enum CornerRadiusDirection {
        case top, bottom, all
    }
    
    private func makeCornerRadius(at direction: CornerRadiusDirection) {
        let cornerRadius: CGFloat = 10
        let roundingCorners: UIRectCorner
        switch direction {
        case .top:
            roundingCorners = [.topLeft, .topRight]
        case .bottom:
            roundingCorners = [.bottomLeft, .bottomRight]
        case .all:
            self.contentView.layer.cornerRadius = cornerRadius
            return
        }
        let path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.contentView.layer.mask = maskLayer
    }
    
    private func removeCornerRadius() {
        self.contentView.layer.mask = nil
        self.contentView.layer.cornerRadius = 0
    }
}
