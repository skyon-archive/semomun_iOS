//
//  MyPurchasesCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/19.
//

import UIKit

class MyPurchasesCell: UICollectionViewCell {
    /* private */
    private var requestedUUID: UUID?
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 83).isActive = true
        view.heightAnchor.constraint(equalToConstant: 115).isActive = true
        return view
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getSemomunColor(.lightGray)
        label.font = .regularStyleParagraph
        return label
    }()
    private let purchaseCompleteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getSemomunColor(.lightGray)
        label.font = .regularStyleParagraph
        label.text = "결제완료"
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getSemomunColor(.darkGray)
        label.font = .largeStyleParagraph
        return label
    }()
    private let costLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getSemomunColor(.darkGray)
        label.font = .heading3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Configure
extension MyPurchasesCell {
    private func configureLayout() {
        self.contentView.addSubviews(self.imageView, self.dateLabel, self.purchaseCompleteLabel, self.titleLabel, self.costLabel)
        NSLayoutConstraint.activate([
            self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            
            self.dateLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            self.dateLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 12),
            
            self.purchaseCompleteLabel.centerYAnchor.constraint(equalTo: self.dateLabel.centerYAnchor),
            self.purchaseCompleteLabel.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 8),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 8),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.dateLabel.leadingAnchor),
            
            self.costLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
            self.costLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor)
        ])
    }
}

// MARK: Update
extension MyPurchasesCell {
    private func configureContent(_ purchasedItem: PurchasedItem, networkUsecase: S3ImageFetchable) {
        self.updateImage(uuid: purchasedItem.descriptionImageID, networkUsecase: networkUsecase)
        self.dateLabel.text = purchasedItem.createdDate.yearMonthDayText
        self.titleLabel.text = purchasedItem.title
        self.costLabel.text = purchasedItem.transaction.amount.withComma + "원"
    }
    
    private func updateImage(uuid: UUID, networkUsecase: S3ImageFetchable) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            self.imageView.image = cachedImage
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
                        self?.imageView.image = image
                    }
                default:
                    print("HomeWorkbookCell: GET image fail")
                }
            })
        }
    }
}
