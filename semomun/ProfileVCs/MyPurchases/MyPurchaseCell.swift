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

/// - Note: 만약 이대로 cell에서(혹은 셀 내의 ViewModel 등에서) 네트워크에 접근해야된다면 prefetch를 사용해보는 것도 방법일듯. [참고]( https://youbidan-project.tistory.com/148)
final class MyPurchaseCell: UITableViewCell {
    
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
    
    func configure(purchase: Purchase, networkUsecase: MyPurchaseCellNetworkUsecase) {
        self.networkUsecase = networkUsecase
        self.dateLabel.text = purchase.date.yearMonthDayText
        let costStr = Int(purchase.cost).withComma ?? "0"
        self.costLabel.text = costStr + "원"
        
        self.networkUsecase?.getWorkbook(wid: purchase.wid) { [weak self] workbook in
            self?.titleLabel.text = workbook.title
            self?.getBookcoverImage(uuid: workbook.bookcover)
        }
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
