//
//  SemopayCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/27.
//

import UIKit

final class SemopayCell: UITableViewCell {
    static let identifier = "SemopayCell"
    static let dividerSublayerName = "SemopayDivider"
    
    private let networkUsecase: WorkbookFetchable = NetworkUsecase(network: Network())
    
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
        self.contentView.layer.sublayers?.removeAll(where: { $0.name == Self.dividerSublayerName})
    }
}

extension SemopayCell {
    func configureCell(using purchase: SemopayHistory) {
        self.setTitle(using: purchase.wid)
        self.setCost(to: purchase.cost)
        self.setDate(using: purchase.date)
    }
    
    private func setTitle(using wid: Int?) {
        if let wid = wid {
            self.networkUsecase.downloadWorkbook(wid: wid) { [weak self] searchWorkbook in
                self?.historyTitle.text = searchWorkbook.workbook.title
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
        guard let red = UIColor(named: "costRed"), let blue = UIColor(named: "costBlue") else { return }
        let costToString = String(Int(cost)) + "원"
        let attrString = NSMutableAttributedString(string: costToString)
        
        let costRange = NSRange(location: 0, length: costToString.count-1)
        // let wonRange = NSRange(location: costToString.count-1, length: 1)
        
        let costColor: UIColor
        switch cost {
        case ..<0: costColor = red
        case 0: costColor = .lightGray
        default: costColor = blue
        }
        let costAttribute = [
            NSAttributedString.Key.foregroundColor: costColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
        attrString.addAttributes(costAttribute, range: costRange)
        
        self.cost.attributedText = attrString
    }
}

extension SemopayCell {
    func configureCellUI(at position: CellPosition) {
        switch position {
        case .oneAndOnly:
            self.makeCornerRadius(at: .all)
        case .top:
            self.makeCornerRadius(at: .top)
            self.addBottomDivider()
            self.clipShadow(at: .bottom)
        case .bottom:
            self.makeCornerRadius(at: .bottom)
            self.clipShadow(at: .top)
        case .middle:
            self.addBottomDivider()
            self.clipShadow(at: .both)
            self.changeShadowOffset(to: CGSize())
        }
    }
    
    enum CellPosition {
        case oneAndOnly, top, bottom, middle
    }
    
    private enum ShadowClipDirection {
        case top, bottom, both
    }
    
    private enum CornerRadiusDirection {
        case top, bottom, all
    }
    
    private func addBottomDivider() {
        guard let dividerColor = UIColor(named: "grayLineColor") else { return }
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 39
        let border = CALayer()
        border.name = Self.dividerSublayerName
        border.backgroundColor = dividerColor.cgColor
        border.frame = CGRect(x: dividerMargin, y: self.contentView.frame.size.height - dividerHeight, width: self.contentView.frame.size.width - 2*dividerMargin, height: dividerHeight)
        self.contentView.layer.addSublayer(border)
    }
    
    private func clipShadow(at direction: ShadowClipDirection) {
        let shadowRadius: CGFloat = 10
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        switch direction {
        case .top:
            layer.frame = .init(-shadowRadius, 0, self.layer.frame.width+2*shadowRadius, self.layer.frame.height+shadowRadius)
        case .bottom:
            layer.frame = .init(-shadowRadius, -shadowRadius, self.layer.frame.width+2*shadowRadius, self.layer.frame.height+shadowRadius)
        case .both:
            layer.frame = .init(-shadowRadius, 0, self.layer.frame.width+2*shadowRadius, self.layer.frame.height)
        }
        self.layer.mask = layer
    }
    
    private func makeCornerRadius(at direction: CornerRadiusDirection) {
        let cornerRadius: CGFloat = 10
        switch direction {
        case .top:
            let path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.contentView.layer.mask = maskLayer
        case .bottom:
            let path = UIBezierPath(roundedRect: self.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.contentView.layer.mask = maskLayer
        case .all:
            self.contentView.layer.cornerRadius = cornerRadius
        }
    }
}
