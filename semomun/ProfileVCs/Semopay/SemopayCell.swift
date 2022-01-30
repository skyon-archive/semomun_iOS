//
//  SemopayCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/27.
//

import UIKit

final class SemopayCell: UITableViewCell {
    static let identifier = "SemopayCell"
    
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var workbookName: UILabel!
    @IBOutlet private weak var cost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension SemopayCell {
    func configureCell(using purchase: Purchase) {
        self.setCost(to: purchase.cost)
        self.setDate(using: purchase.date)
    }
    
    private func setDate(using date: Date) {
        let calendarDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = calendarDate.year, let month = calendarDate.month, let day = calendarDate.day else { return }
        self.date.text = String(format: "%d.%02d.%02d", year, month, day)
    }
    
    private func setCost(to cost: Double) {
        let costToString = String(Int(cost)) + "원"
        let attrString = NSMutableAttributedString(string: costToString)
        
        let costRange = NSRange(location: 0, length: costToString.count-1)
        let wonRange = NSRange(location: costToString.count-1, length: 1)
        
        let costColor: UIColor = cost < 0 ? .red : .blue
        let costAttribute = [NSAttributedString.Key.foregroundColor: costColor]
        
        attrString.addAttributes(costAttribute, range: costRange)
        
        self.cost.attributedText = attrString
    }
}

