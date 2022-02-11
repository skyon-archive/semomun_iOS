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
    private var addUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = UIImage(.loadingBookcover)
    }
    
    @IBAction func showAd(_ sender: Any) {
        if let addUrl = self.addUrl,
           let url = URL(string: addUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func configureTest(url: String) {
        self.addUrl = url
        self.imageView.image = UIImage(.dummy_ad)
    }
}
