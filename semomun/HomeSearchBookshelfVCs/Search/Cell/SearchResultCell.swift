//
//  SearchResultCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/27.
//

import UIKit

class SearchResultCell: UICollectionViewCell {
    static let identifier = "SearchResultCell"
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        let stringUrl = NetworkURL.bookcoverImageDirectory(.large) + preview.bookcover
        guard let url = URL(string: stringUrl) else { return }
        self.bookcover.kf.setImage(with: url)
    }
}
