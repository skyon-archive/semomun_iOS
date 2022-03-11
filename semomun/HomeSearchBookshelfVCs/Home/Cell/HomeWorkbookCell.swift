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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookcover.image = UIImage(.loadingBookcover)
    }
    
    func configureNetworkUsecase(to usecase: (S3ImageFetchable & WorkbookSearchable)?) {
        self.networkUsecase = usecase
    }
    
    func configure(with preview: PreviewOfDB) {
        self.title.text = preview.title
        self.fetchImage(uuid: preview.bookcover)
    }
    
    func configure(with info: BookshelfInfo) {
        self.networkUsecase?.getWorkbook(wid: info.wid, completion: { [weak self] workbook in
            self?.title.text = workbook.title
            self?.fetchImage(uuid: workbook.bookcover)
        })
    }
    
    private func fetchImage(uuid: UUID) {
        self.networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, data in
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .SUCCESS:
                    guard let data = data,
                          let image = UIImage(data: data) else { return }
                    self?.bookcover.image = image
                default:
                    print("HomeWorkbookCell: GET image fail")
                }
            }
        })
    }
}
