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
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyPurchasesCell {
    private func configureImage(uuid: UUID, networkUsecase: S3ImageFetchable) {
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
