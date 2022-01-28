//
//  BookshelfCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/28.
//

import UIKit

class BookshelfCell: UICollectionViewCell {
    static let identifier = "BookshelfCell"
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var authorAndPublisher: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressPersentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(systemName: SemomunImage.loadingBookcover)
    }
    
    private func configureUI() {
        self.frameView.layer.shadowOpacity = 0.3
        self.frameView.layer.shadowColor = UIColor.lightGray.cgColor
        self.frameView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.frameView.layer.shadowRadius = 5
    }
    
    func configureTest(with book: TestBook) {
        self.bookcover.image = UIImage(named: SemomunImage.dummy_bookcover)
        self.title.text = book.title
        self.authorAndPublisher.text = "\(book.author) | \(book.publisher)"
        let percent = Int.random(in: (0...100))
        self.progressView.setProgress(Float(percent)/Float(100), animated: true)
        self.progressPersentLabel.text = "\(percent)%"
    }
}
