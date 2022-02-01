//
//  PurchasePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class PurchasePopupVC: UIViewController {
    static let identifier = "PurchasePopupVC"
    static let storyboardName = "HomeSearchBookshelf"
    enum Status {
        case purchase, charge
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currentMoneyLabel: UILabel!
    @IBOutlet weak var afterMoneyLabel: UILabel!
    @IBOutlet weak var moneyStatusLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var purchaseBT: UIButton!
    
    private var info: WorkbookOfDB?
    private var currentMoney: Int?
    private var type: Status?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureType()
        self.configureUI()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        guard let type = self.type else { return }
        switch type {
        case .purchase:
            // 생체인식 popup 필요
            self.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .purchaseComplete, object: nil)
            })
        case .charge:
            self.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .goToCharge, object: nil)
            })
        }
    }
}

extension PurchasePopupVC {
    func configureInfo(info: WorkbookOfDB) {
        self.info = info
    }
    
    func configureCurrentMoney(money: Int) {
        self.currentMoney = money
    }
    
    private func configureType() {
        guard let info = self.info,
              let currentMoney = self.currentMoney else { return }
        self.type = (currentMoney - info.price) >= 0 ? .purchase : .charge
//        self.type = .charge
    }
    
    private func configureUI() {
        guard let type = self.type,
              let info = self.info,
              let currentMoney = self.currentMoney else { return }
        self.configureTitle(to: info.title)
        self.configureMoneyUI(currentMoney: currentMoney, info: info)
        
        switch type {
        case .purchase:
            self.configureActionTitle(to: "구매하기")
            self.moneyStatusLabel.text = "결제 후 세모페이 잔액"
            self.warningLabel.isHidden = true
        case .charge:
            self.configureActionTitle(to: "세모페이 충전하기")
        }
    }
    
    private func configureTitle(to title: String) {
        self.titleLabel.text = title
    }
    
    private func configureMoneyUI(currentMoney: Int, info: WorkbookOfDB) {
        self.priceLabel.text = "\(info.price)원"
        self.currentMoneyLabel.text = "\(currentMoney)원"
        let afterMoney = (currentMoney - info.price).magnitude
        self.afterMoneyLabel.text = "\(afterMoney)원"
    }
    
    private func configureActionTitle(to title: String) {
        self.purchaseBT.setTitle(title, for: .normal)
    }
}
