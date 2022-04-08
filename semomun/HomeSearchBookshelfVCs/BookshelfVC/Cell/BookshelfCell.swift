//
//  BookshelfCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/28.
//

import UIKit

class BookshelfCell: UICollectionViewCell {
    static let identifier = "BookshelfCell"
    @IBOutlet weak var bookcoverFrameView: UIView!
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPercentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBookcoverShadow()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressView.setProgress(0, animated: false)
    }
    
    private func configureBookcoverShadow() {
        self.bookcoverFrameView.layer.shadowOpacity = 0.4
        self.bookcoverFrameView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bookcoverFrameView.layer.shadowOffset = CGSize(width: 1.5, height: 3.5)
        self.bookcoverFrameView.layer.shadowRadius = 3
    }
    
    func configure(with book: Preview_Core) {
        self.title.text = book.title
        if let imageData = book.image {
            self.bookcover.image = UIImage(data: imageData)
        }
        let percent = Float(book.progressCount)/Float(book.sids.count)
        self.progressView.setProgress(percent, animated: false)
        self.progressPercentLabel.text = "\(Int(percent*100))%"
    }
}
