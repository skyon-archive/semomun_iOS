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
    
    private var networkUsecase: SemopayCellNetworkUsecase?
    
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var historyTitle: UILabel!
    @IBOutlet private weak var cost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addAccessibleShadow(direction: .bottom)
        self.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeCornerRadius()
        self.removeBottomDivider()
        self.removeClipOfAccessibleShadow()
    }
}

// MARK: Cell 정보 configure
extension SemopayCell {
    func configureCell(using purchase: PayHistory) {
        if self.isPurchaseCharge(purchase) {
            self.setTitleLabelForPayCharge()
        } else {
            self.setTitleLabelForWorkbook(workbook: purchase.item.workbook)
        }
        
        self.setCostLabel(transaction: purchase.transaction)
        self.setDate(using: purchase.createdDate)
    }
    
    func configureNetworkUsecase(_ networkUsecase: SemopayCellNetworkUsecase) {
        self.networkUsecase = networkUsecase
    }
}

extension SemopayCell {
        func configureCellUI(row: Int, numberOfRowsInSection: Int) {
            if numberOfRowsInSection == 1 {
                self.makeCornerRadius(at: .all)
            } else if row == 0 {
                self.makeCornerRadius(at: .top)
                self.clipAccessibleShadow(at: .bottom)
                self.addBottomDivider()
            } else if row == numberOfRowsInSection - 1 {
                self.makeCornerRadius(at: .bottom)
                self.clipAccessibleShadow(at: .top)
            } else {
                self.clipAccessibleShadow(at: .both)
                self.changeShadowOffset(to: CGSize())
                self.addBottomDivider()
            }
    }
}

extension SemopayCell {
    private func isPurchaseCharge(_ purchase: PayHistory) -> Bool {
        if case .charge = purchase.transaction {
            return true
        } else {
            return false
        }
    }
    
    private func setTitleLabelForPayCharge() {
        self.historyTitle.text = "세모페이 충전"
    }
    
    private func setTitleLabelForWorkbook(workbook: PurchasedWorkbook) {
        self.historyTitle.text = workbook.title
    }
    
    private func setDate(using date: Date) {
        self.date.text = date.yearMonthDayText
    }
    
    private func setCostLabel(transaction: Transaction) {
        let labelColor = self.getCostLabelColor(transaction: transaction)
        let costLabelNumberPart = self.getCostLabelNumberPart(transaction: transaction)
        
        let numberPartRange = NSRange(location: 0, length: costLabelNumberPart.count)
        let costLabel = costLabelNumberPart + "원"
        
        let attrString = NSMutableAttributedString(string: costLabel)
        let numberPartAttribute = [
            NSAttributedString.Key.foregroundColor: labelColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        attrString.addAttributes(numberPartAttribute, range: numberPartRange)
        self.cost.attributedText = attrString
    }
    
    private func getCostLabelNumberPart(transaction: Transaction) -> String {
        switch transaction {
        case .charge(let text), .purchase(let text):
            return text.withCommaAndSign
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
        case .purchase(_):
            return red
        case .free:
            return .lightGray
        }
    }
}

// MARK: Divider configure
extension SemopayCell {
    static let dividerSublayerName = "SemopayDivider"
    private func addBottomDivider() {
        let dividerColor = UIColor(.divider)
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 39
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
