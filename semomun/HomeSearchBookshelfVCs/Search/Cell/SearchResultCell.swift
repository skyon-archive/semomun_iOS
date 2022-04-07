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
    private var networkUsecase: S3ImageFetchable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    func configureNetworkUsecase(to usecase: S3ImageFetchable?) {
        self.networkUsecase = usecase
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        self.configureImage(uuid: preview.bookcover)
    }
    
    private func configureImage(uuid: UUID) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            self.bookcover.image = cachedImage
        } else {
            self.networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, imageData in
                switch status {
                case .SUCCESS:
                    guard let imageData = imageData,
                          let image = UIImage(data: imageData) else { return }
                    DispatchQueue.main.async { [weak self] in
                        self?.bookcover.image = image
                        ImageCacheManager.shared.saveImage(uuid: uuid, image: image)
                    }
                default:
                    print("SearchResultCell: GET image fail")
                }
            })
        }
    }
}
