//
//  SearchPreviewCell.swift
//  Semomoon
//
//  Created by qwer on 2021/10/03.
//

import UIKit
import Kingfisher

class SearchedPreviewCell: UICollectionViewCell {
    static let identifier = "SearchedPreviewCell"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    func showImage(url: String) {
        guard let url = URL(string: url) else { return }
        self.imageView.kf.setImage(with: url)
    }
}
