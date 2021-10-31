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
    
    let imageShadowView: UIView = {
        let aView = UIView()
        aView.layer.shadowOffset = CGSize(width: 5, height: 5)
        aView.layer.shadowOpacity = 0.7
        aView.layer.shadowRadius = 5
        
        aView.layer.shadowColor = UIColor.gray.cgColor
        aView.translatesAutoresizingMaskIntoConstraints = false
        return aView
    }()
    
    override func awakeFromNib() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    func disappearShadow() {
        imageShadowView.layer.shadowColor = UIColor.clear.cgColor
    }
    
    func showShadow() {
        imageShadowView.layer.shadowColor = UIColor.gray.cgColor
    }
}
