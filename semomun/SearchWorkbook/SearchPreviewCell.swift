//
//  SearchPreviewCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import Kingfisher

class SearchedPreviewCell: UICollectionViewCell {
    static let identifier = "SearchedPreviewCell"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    
    func showImage(url: String) {
        guard let url = URL(string: url) else { return }
        print(url)
        self.imageView.kf.setImage(with: url)
    }
}
