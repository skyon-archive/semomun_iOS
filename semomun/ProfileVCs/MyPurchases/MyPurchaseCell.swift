//
//  MyPurchaseCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/26.
//

import UIKit
import Combine
import Kingfisher

private typealias MyPurchaseCellNetworkUsecase = WorkbookFetchable

/// - Note: 만약 이대로 cell에서(혹은 셀 내의 ViewModel 등에서) 네트워크에 접근해야된다면 prefetch를 사용해보는 것도 방법일듯. [참고]( https://youbidan-project.tistory.com/148)
final class MyPurchaseCell: UITableViewCell {
    
    static let storyboardName = "Profile"
    static let identifier = "MyPurchaseCell"
    
    private let networkUsecase: MyPurchaseCellNetworkUsecase = NetworkUsecase(network: Network())
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var workbookImage: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBasicUI()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.workbookImage.image = nil
        self.date.text = nil
        self.title.text = nil
        self.cost.text = nil
    }
    
    func configure(using purchase: Purchase) {
        let dateComp = Calendar.current.dateComponents([.year, .month, .day], from: purchase.date)
        guard let year = dateComp.year, let month = dateComp.month, let day = dateComp.day else { return }
        self.date.text = String(format: "%d.%02d.%02d", year, month, day)
        guard let costStr = Int(purchase.cost).withComma else { return }
        self.cost.text = costStr + "원"
        self.networkUsecase.downloadWorkbook(wid: purchase.wid) { searchWorkbook in
            self.title.text = searchWorkbook.workbook.title
            let urlString = NetworkURL.bookcoverImageDirectory(.large) + searchWorkbook.workbook.bookcover
            guard let url = URL(string: urlString) else { return }
            self.workbookImage.kf.setImage(with: url)
        }
    }
}

extension MyPurchaseCell {
    private func configureBasicUI() {
        self.background.layer.cornerRadius = 10
        self.background.addShadow(direction: .bottom)
    }
}

