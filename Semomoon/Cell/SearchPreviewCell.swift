//
//  SearchPreviewCell.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import UIKit

class SearchedPreviewCell: UICollectionViewCell {
    static let identifier = "SearchedPreviewCell"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    func showImage(url: String) {
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            self.imageView.image = cachedImage
            return
        }
        
        DispatchQueue.global().async {
            NetworkUsecase.downloadImage(url: url) { data in
                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else { return }
                    ImageCache.shared.setObject(image, forKey: cacheKey)
                    self.imageView.image = image
                }
            }
        }
    }
}
