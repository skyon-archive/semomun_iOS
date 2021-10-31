//
//  PreviewCell.swift
//  Semomoon
//
//  Created by qwer on 2021/10/16.
//

import UIKit

class PreviewCell: UICollectionViewCell {
    static let identifier = "PreviewCell"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
    }
}
