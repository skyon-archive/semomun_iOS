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
    @IBOutlet weak var progressPercentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
        self.resetUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    private func configureUI() {
        self.frameView.layer.shadowOpacity = 0.3
        self.frameView.layer.shadowColor = UIColor.lightGray.cgColor
        self.frameView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.frameView.layer.shadowRadius = 5
    }
    
    private func resetUI() {
        self.bookcover.image = nil
        self.title.text = nil
        self.authorAndPublisher.text = nil
        self.progressPercentLabel.text = nil
        self.progressView.isHidden = false
        self.progressPercentLabel.text = nil
    }
    
    func configure(with book: Preview_Core) {
        self.title.text = book.title
        if let imageData = book.image {
            DispatchQueue.main.async { [weak self] in
                self?.bookcover.image = UIImage(data: imageData)
            }
        }
        let author = book.author != "" ? (book.author ?? "저자 정보 없음") : "저자 정보 없음"
        let publisher = book.publisher != "" ? (book.publisher ?? "출판사 정보 없음") : "출판사 정보 없음"
        self.authorAndPublisher.text = "\(author) | \(publisher)"
        let percent = Int.random(in: (0...100))
        self.progressView.setProgress(Float(percent)/Float(100), animated: true)
        self.progressPercentLabel.text = "\(percent)%"
    }
    
    func configureShadow() {
        self.progressView.isHidden = true
    }
}
