//
//  BookcoverCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/05.
//

import UIKit

class BookcoverCell: UICollectionViewCell {
    /* public */
    let bookcoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(.loadingBookcover)
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    /* private */
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadius = .cornerRadius12
        view.clipsToBounds = true
        
        return view
    }()
    private let bookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.darkGray)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    private let publishCompanyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .smallStyleParagraph
        label.textColor = .getSemomunColor(.lightGray)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    private var requestedUUID: UUID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureShadow()
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.requestedUUID = nil
        self.bookcoverImageView.image = UIImage(.loadingBookcover)
    }
    
    func configureReuse(bookTitle: String, publishCompany: String? = "출판사 없음") {
        self.bookTitleLabel.text = bookTitle
        self.publishCompanyLabel.text = publishCompany
        self.bookTitleLabel.sizeToFit()
    }
}

// MARK: Public
extension BookcoverCell {
    func configureImage(uuid: UUID, networkUsecase: S3ImageFetchable) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            self.bookcoverImageView.image = cachedImage
        } else {
            self.requestedUUID = uuid
            networkUsecase.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, imageData in
                switch status {
                case .SUCCESS:
                    guard let imageData = imageData,
                          let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async { [weak self] in
                        ImageCacheManager.shared.saveImage(uuid: uuid, image: image)
                        guard self?.requestedUUID == uuid else { return }
                        self?.bookcoverImageView.image = image
                    }
                default:
                    print("HomeWorkbookCell: GET image fail")
                }
            })
        }
    }
    
    func configureImage(data: Data?) {
        if let imageData = data {
            self.bookcoverImageView.image = UIImage(data: imageData)
        } else {
            self.bookcoverImageView.image = UIImage(.loadingBookcover)
        }
    }
}

// MARK: Private
extension BookcoverCell {
    private func configureShadow() {
        self.contentView.backgroundColor = UIColor.getSemomunColor(.white)
        self.contentView.addShadowToFrameView(cornerRadius: .cornerRadius12)
    }
    
    private func configureLayout() {
        self.contentView.addSubviews(self.borderView)
        self.borderView.addSubviews(self.bookcoverImageView, self.bookTitleLabel, self.publishCompanyLabel)
        
        NSLayoutConstraint.activate([
            self.borderView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.borderView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.borderView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.borderView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            
            self.bookcoverImageView.topAnchor.constraint(equalTo: self.borderView.topAnchor),
            self.bookcoverImageView.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor),
            self.bookcoverImageView.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor),
            self.bookcoverImageView.heightAnchor.constraint(equalTo: self.bookcoverImageView.widthAnchor, multiplier: 1.25),
            
            self.bookTitleLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor),
            self.bookTitleLabel.leadingAnchor.constraint(equalTo: self.borderView.leadingAnchor, constant: 8),
            self.bookTitleLabel.topAnchor.constraint(equalTo: self.bookcoverImageView.bottomAnchor, constant: 8),
            self.bookTitleLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.publishCompanyLabel.topAnchor, constant: -8),
            
            self.publishCompanyLabel.trailingAnchor.constraint(equalTo: self.borderView.trailingAnchor, constant: -8),
            self.publishCompanyLabel.bottomAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: -8),
            self.publishCompanyLabel.leadingAnchor.constraint(equalTo: self.bookTitleLabel.leadingAnchor)
        ])
    }
}
