//
//  HomeWorkbookCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import UIKit

class HomeWorkbookCell: UICollectionViewCell {
    static let identifier = "HomeWorkbookCell"
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    private var networkUsecase: (S3ImageFetchable & WorkbookSearchable)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    func configureNetworkUsecase(to usecase: (S3ImageFetchable & WorkbookSearchable)?) {
        self.networkUsecase = usecase
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        self.configureImage(uuid: preview.bookcover)
    }
    
    func configure(with info: BookshelfInfo) {
        self.networkUsecase?.getWorkbook(wid: info.wid, completion: { [weak self] workbook in
            self?.title.text = workbook.title
            self?.configureImage(uuid: workbook.bookcover)
        })
    }
    
    private func configureImage(uuid: UUID) {
        if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
            print("cached image: \(uuid)")
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
                    print("HomeWorkbookCell: GET image fail")
                }
            })
        }
    }
}
