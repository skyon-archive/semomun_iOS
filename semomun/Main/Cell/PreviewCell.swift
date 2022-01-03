//
//  PreviewCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/10/16.
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
    private lazy var statusImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .clear
        imgView.tintColor = UIColor(named: SemomunColor.mainColor)
        imgView.clipsToBounds = true
        return imgView
    }()
    
    override func awakeFromNib() {
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageShadowView)
        imageShadowView.addSubview(imageView)
        self.configureLayout()
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
        self.statusImageView.backgroundColor = .clear
        self.statusImageView.image = nil
    }
    
    func configureLayout() {
        self.statusImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.statusImageView)
        
        NSLayoutConstraint.activate([
            self.statusImageView.widthAnchor.constraint(equalToConstant: 30),
            self.statusImageView.heightAnchor.constraint(equalToConstant: 30),
            self.statusImageView.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -5),
            self.statusImageView.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: -5)
        ])
        self.statusImageView.layer.cornerRadius = 15
    }
    
    func configure(with preview: Preview_Core) {
        self.title.text = preview.title
        if let imageData = preview.image {
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = UIImage(data: imageData)
            }
        }
        self.showShadow()
        self.configureStatus(preview: preview)
    }
    
    func configureAddCell(image: UIImage?) {
        self.title.text = " "
        self.imageView.image = image
        self.disappearShadow()
    }
    
    private func configureStatus(preview: Preview_Core) {
        if preview.terminated {
            self.statusImageView.backgroundColor = .white
            self.statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            return
        }
        
        if !preview.downloaded {
            self.statusImageView.backgroundColor = .white
            self.statusImageView.image = UIImage(systemName: "arrow.down.circle.fill")
            return
        }
    }
    
    private func disappearShadow() {
        imageShadowView.layer.shadowColor = UIColor.clear.cgColor
    }
    
    private func showShadow() {
        imageShadowView.layer.shadowColor = UIColor.gray.cgColor
    }
}
