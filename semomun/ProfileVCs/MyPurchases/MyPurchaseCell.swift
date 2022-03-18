//
//  MyPurchaseCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import UIKit
import Combine
import Kingfisher

typealias MyPurchaseCellNetworkUsecase = (WorkbookSearchable & S3ImageFetchable)

final class MyPurchaseCell: UITableViewCell  {
    
    static let storyboardName = "Profile"
    static let identifier = "MyPurchaseCell"
    
    private var networkUsecase: MyPurchaseCellNetworkUsecase?
    
    @IBOutlet weak var backgroundFrameView: UIView!
    @IBOutlet weak var workbookImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBasicUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.workbookImage.image = nil
        self.dateLabel.text = nil
        self.titleLabel.text = nil
        self.costLabel.text = nil
    }
    
    func configure(item: PurchasedItem, networkUsecase: MyPurchaseCellNetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.titleLabel.text = item.title
        self.dateLabel.text = item.createdDate.yearMonthDayText
        let costStr = Int(item.transaction.amount).withComma
        self.costLabel.text = costStr + "원"
        self.getBookcoverImage(uuid: item.descriptionImageID)
    }
    
    private func getBookcoverImage(uuid: UUID) {
        self.networkUsecase?.getImageFromS3(uuid: uuid, type: .bookcover, completion: { [weak self] status, data in
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .SUCCESS:
                    guard let data = data,
                          let image = UIImage(data: data) else { return }
                    self?.workbookImage.image = image
                default:
                    self?.workbookImage.image = UIImage(.warning)
                }
            }
        })
    }
}

extension MyPurchaseCell {
    private func configureBasicUI() {
        self.backgroundFrameView.layer.cornerRadius = 10
        self.backgroundFrameView.addAccessibleShadow(direction: .bottom)
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
    }
}
