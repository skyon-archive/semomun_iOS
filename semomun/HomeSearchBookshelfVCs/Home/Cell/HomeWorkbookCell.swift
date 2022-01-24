//
//  HomeWorkbookCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import UIKit
import Kingfisher

class HomeWorkbookCell: UICollectionViewCell {
    static let identifier = "HomeWorkbookCell"
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(systemName: SemomunImage.loadingBookcover)
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        let stringUrl = NetworkURL.bookcoverImageDirectory(.large) + preview.bookcover
        guard let url = URL(string: stringUrl) else { return }
        self.bookcover.kf.setImage(with: url)
    }
}
