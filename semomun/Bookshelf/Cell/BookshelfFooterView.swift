//
//  BookshelfFooterView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/04/08.
//

import UIKit

class BookshelfFooterView: UICollectionReusableView {
    static let identifier = "BookshelfFooterView"
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shadowView.layer.shadowOpacity = 0.25
        self.shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.shadowView.layer.shadowRadius = 5
    }
}
