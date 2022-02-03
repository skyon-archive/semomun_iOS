//
//  SemopayCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/27.
//

import UIKit

typealias SemopayCellNetworkUsecase = WorkbookFetchable

final class SemopayCell: UITableViewCell {
    static let identifier = "SemopayCell"
    
    private var networkUsecase: SemopayCellNetworkUsecase?
    
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var historyTitle: UILabel!
    @IBOutlet private weak var cost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addShadow(direction: .bottom, shouldRasterize: true)
        self.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeCornerRadius()
        self.removeBottomDivider()
        self.undoClipShadow()
    }
}

// MARK: Cell 정보 configure
extension SemopayCell {
    func configureCell(using purchase: SemopayHistory) {
        self.setTitle(using: purchase.wid)
        self.setCost(to: purchase.cost)
        self.setDate(using: purchase.date)
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
                self.clipShadow(at: .bottom)
                self.addBottomDivider()
            } else if row == numberOfRowsInSection - 1 {
                self.makeCornerRadius(at: .bottom)
                self.clipShadow(at: .top)
            } else {
                self.clipShadow(at: .both)
                self.changeShadowOffset(to: CGSize())
                self.addBottomDivider()
            }
    }
}

extension SemopayCell {
    private func setTitle(using wid: Int?) {
        if let wid = wid {
            // TODO: 네트워크로만 연결 가능하게 하기.
            if let preview = CoreUsecase.fetchPreview(wid: wid) {
                self.historyTitle.text = preview.title
            } else {
                self.networkUsecase?.downloadWorkbook(wid: wid) { [weak self] searchWorkbook in
                    self?.historyTitle.text = searchWorkbook.workbook.title
                }
            }
        } else {
            self.historyTitle.text = "세모페이 충전"
        }
    }
    
    private func setDate(using date: Date) {
        self.date.text = date.yearMonthDayText
    }
    
    private func setCost(to cost: Double) {
        var costStr = Int(cost).withCommaAndSign ?? "0"
        costStr += "원"
        let attrString = NSMutableAttributedString(string: costStr)
        let costRange = NSRange(location: 0, length: costStr.count-1)
        let costAttribute = [
            NSAttributedString.Key.foregroundColor: color(of: cost),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
        attrString.addAttributes(costAttribute, range: costRange)
        self.cost.attributedText = attrString
    }
    
    private func color(of cost: Double) -> UIColor {
        guard let red = UIColor(named: SemomunColor.costRed), let blue = UIColor(named: SemomunColor.costBlue) else {
            return .lightGray
        }
        if cost.isZero {
            return .lightGray
        } else if cost.isLess(than: 0) {
            return red
        } else {
            return blue
        }
    }
}

// MARK: Divider configure
extension SemopayCell {
    static let dividerSublayerName = "SemopayDivider"
    private func addBottomDivider() {
        guard let dividerColor = UIColor(named: SemomunColor.grayLineColor) else { return }
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 39
        let dividerWidth = self.contentView.frame.size.width - 2 * dividerMargin
        let dividerYpos = self.contentView.frame.size.height - dividerHeight
        let border: CALayer = {
            let border = CALayer()
            border.name = Self.dividerSublayerName
            border.backgroundColor = dividerColor.cgColor
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
