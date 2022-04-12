//
//  HomeAdCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import UIKit

class HomeAdCell: UICollectionViewCell {
    static let identifier = "HomeAdCell"
    @IBOutlet weak var imageView: UIImageView!
    private var url: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(.loadingBookcover)
    }
    
    @IBAction func showAd(_ sender: Any) {
        if let url = self.url {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func configureContent(imageURL: URL, url: URL) {
        self.url = url
        self.imageView.kf.setImage(with: imageURL)
    }
}
