//
//  TestSubjectCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/08.
//

import UIKit

final class TestSubjectCell: UICollectionViewCell {
    /* public */
    static let identifer = "TestSubjectCell"
    static let cellSize: CGSize = CGSize(146, 240)
    /* private */
    private var networkUsecase: S3ImageFetchable?
    private var requestedUUID: UUID?
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureNetworkUsecase(to usecase: S3ImageFetchable?) {
        self.networkUsecase = usecase
    }
    
    func configure(coreInfo info: Preview_Core) {
        self.titleLabel.text = "\(info.subject ?? "")(\(info.area ?? ""))"
        self.priceLabel.text = ""
        self.configureImage(data: info.image)
    }
    
    func configure(dtoInfo info: WorkbookOfDB) {
        self.titleLabel.text = "\(info.subject)(\(info.area))"
        self.priceLabel.text = "\(info.price.withComma)원"
        self.configureImage(uuid: info.bookcover)
    }
    
    private func configureImage(uuid: UUID) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            self.bookcover.image = cachedImage
        } else {
            self.requestedUUID = uuid
            self.networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, imageData in
                switch status {
                case .SUCCESS:
                    guard let imageData = imageData,
                          let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async { [weak self] in
                        ImageCacheManager.shared.saveImage(uuid: uuid, image: image)
                        guard self?.requestedUUID == uuid else { return }
                        self?.bookcover.image = image
                    }
                default:
                    print("HomeWorkbookCell: GET image fail")
                }
            })
        }
    }
    
    private func configureImage(data: Data?) {
        if let imageData = data {
            self.bookcover.image = UIImage(data: imageData)
        } else {
            self.bookcover.image = UIImage(.dummy_bookcover)
        }
    }
}
