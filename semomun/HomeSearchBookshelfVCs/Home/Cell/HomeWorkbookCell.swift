//
//  HomeWorkbookCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/24.
//

import UIKit
import Kingfisher

class HomeWorkbookCell: UICollectionViewCell {
    static let identifier = "HomeWorkbookCell"
    @IBOutlet weak var bookcover: UIImageView!
    @IBOutlet weak var title: UILabel!
    private var networkUsecase: S3ImageFetchable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        self.networkUsecase?.getImageURLFromS3(uuid: preview.bookcover, type: .bookcover) { [weak self] status, stringUrl in
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .SUCCESS:
                    guard let stringUrl = stringUrl,
                          let url = URL(string: stringUrl) else { return }
                    self?.bookcover.kf.setImage(with: url)
                default:
                    print("get image Error")
                }
            }
        }
    }
}
