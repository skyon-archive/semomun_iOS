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
    
    private var networkUsecase: SemopayCellNetworkUsecase = NetworkUsecase(network: Network())
    
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
        self.contentView.layer.cornerRadius = 0
        self.contentView.layer.mask = nil
        self.removeBottomDivider()
    }
}

// MARK: Cell 정보 configure
extension SemopayCell {
    func configureCell(using purchase: SemopayHistory) {
        self.setTitle(using: purchase.wid)
        self.setCost(to: purchase.cost)
        self.setDate(using: purchase.date)
    }
    
    enum CellPosition {
        case oneAndOnly, top, bottom, middle
    }
    
    func configureCellUI(at position: CellPosition) {
        switch position {
        case .oneAndOnly:
            self.makeCornerRadius(at: .all)
        case .top:
            self.makeCornerRadius(at: .top)
            self.clipShadow(at: .bottom)
            self.addBottomDivider()
        case .bottom:
            self.makeCornerRadius(at: .bottom)
            self.clipShadow(at: .top)
        case .middle:
            self.clipShadow(at: .both)
            self.changeShadowOffset(to: CGSize())
            self.addBottomDivider()
        }
    }
}

extension SemopayCell {
    private func setTitle(using wid: Int?) {
        if let wid = wid {
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
        let calendarDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = calendarDate.year, let month = calendarDate.month, let day = calendarDate.day else { return }
        self.date.text = String(format: "%d.%02d.%02d", year, month, day)
    }
    
    private func setCost(to cost: Double) {
        let costStr = Int(cost).withCommaAndSign() + "원"
        let attrString = NSMutableAttributedString(string: costStr)
        let costRange = NSRange(location: 0, length: costStr.count-1)
        let costAttribute = [
            NSAttributedString.Key.foregroundColor: color(of: cost),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
        attrString.addAttributes(costAttribute, range: costRange)
        self.cost.attributedText = attrString
    }
    
    private func color(of cost: Double) -> UIColor {
        guard let red = UIColor(named: "costRed"), let blue = UIColor(named: "costBlue") else {
            return .lightGray
        }
        switch cost {
        case ..<0: return red
        case 0: return .lightGray
        default: return blue
        }
    }
}

// MARK: Divider configure
extension SemopayCell {
    static let dividerSublayerName = "SemopayDivider"
    private func addBottomDivider() {
        guard let dividerColor = UIColor(named: "grayLineColor") else { return }
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
 
// MARK: Shadow configure
extension SemopayCell {
    private enum ShadowClipDirection {
        case top, bottom, both
    }
    
    private func clipShadow(at direction: ShadowClipDirection) {
        let shadowRadius: CGFloat = 10
        let cellLayerHeight = self.layer.frame.height
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        // 왼쪽부분 그림자는 항상 남음
        let x = -shadowRadius
        // 마찬가지로 좌우 그림자는 항상 남으므로 셀의 너비 + 양쪽 그림자의 넓이
        let w = self.layer.frame.width+2*shadowRadius
        let y, h: CGFloat
        switch direction {
        case .top:
            y = 0
            h = cellLayerHeight+shadowRadius
        case .bottom:
            y = -shadowRadius
            h = cellLayerHeight+shadowRadius
        case .both:
            y = 0
            h = cellLayerHeight
        }
        layer.frame = CGRect(x, y, w, h)
        self.layer.mask = layer
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
}
