//
//  BookshelfCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/28.
//

import UIKit

class BookshelfCell: UICollectionViewCell {
    static let identifier = "BookshelfCell"
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authorAndPublisher: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(systemName: SemomunImage.loadingBookcover)
    }
    
    func configureTest(with book: TestBook) {
        self.bookcover.image = UIImage(named: SemomunImage.dummy_bookcover)
        self.title.text = book.title
        self.authorAndPublisher.text = "\(book.author) | \(book.publisher)"
    }
}
