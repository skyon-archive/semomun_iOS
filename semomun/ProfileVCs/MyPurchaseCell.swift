//
//  MyPurchaseCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import UIKit

final class MyPurchaseCell: UITableViewCell {
    
    static let storyboardName = "Profile"
    static let identifier = "MyPurchaseCell"
    
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var workbookImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBasicUI()
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.workbookImage.image = nil
//        self.date.text = nil
//        self.title.text = nil
//        self.cost.text = nil
//    }
}

extension MyPurchaseCell {
    private func configureBasicUI() {
        self.bg.layer.cornerRadius = 10
        
        self.bg.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        self.bg.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.bg.layer.shadowOpacity = 0.2
        self.bg.layer.shadowRadius = 2.5
    }
}

