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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        let networkUsecase = NetworkUsecase(network: Network())
        networkUsecase.getImageFromS3(uuid: preview.bookcover, type: .bookcover) { [weak self] status, stringUrl in
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .SUCCESS:
                    guard let stringUrl = stringUrl,
                          let url = URL(string: stringUrl) else { return }
                    print(stringUrl)
                    self?.bookcover.kf.setImage(with: url)
                default:
                    print("get image Error")
                }
            }
        }
    }
}
