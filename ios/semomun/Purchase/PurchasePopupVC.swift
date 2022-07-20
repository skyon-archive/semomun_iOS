//
//  PurchasePopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import LocalAuthentication

final class PurchasePopupVC: UIViewController {
    static let identifier = "PurchasePopupVC"
    static let storyboardName = "HomeSearchBookshelf"
    enum Status {
        case purchase, charge
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var usePriceLabel: UILabel!
    @IBOutlet weak var currentMoneyLabel: UILabel!
    @IBOutlet weak var necessaryLabel: UILabel!
    @IBOutlet weak var necessaryPriceLabel: UILabel!
    @IBOutlet weak var purchaseBT: UIButton!
    
    private var info: WorkbookOfDB?
    private var currentMoney: Int?
    private var type: Status?
    private var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureType()
        self.configureUI()
        self.configureAuthentication()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        guard let type = self.type else { return }
        switch type {
        case .purchase:
            self.authentication()
        case .charge:
            // MARK: 애플에서 제공하는 외부결제 팝업창 로직이 필요
            self.presentingViewController?.dismiss(animated: true)
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
    
    private func configureAuthentication() {
        self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    private func configureType() {
        guard let info = self.info,
              let currentMoney = self.currentMoney else { return }
        self.type = currentMoney >= info.price ? .purchase : .charge
    }
    
    private func configureUI() {
        guard let type = self.type,
              let info = self.info,
              let currentMoney = self.currentMoney else { return }
        
        self.titleLabel.text = info.title
        self.configurePriceLabel(price: info.price)
        self.currentMoneyLabel.text = "\(currentMoney.withComma)원"
        
        switch type {
        case .purchase:
            self.necessaryPriceLabel.text = "\(info.price.withComma)원"
        case .charge:
            self.necessaryLabel.textColor = UIColor.systemRed
            self.necessaryLabel.font = UIFont.heading5
            self.necessaryLabel.text = "부족한 세모페이"
            
            self.necessaryPriceLabel.textColor = UIColor.systemRed
            self.necessaryPriceLabel.font = UIFont.heading5
            let necessaryPrice = info.price - currentMoney
            self.necessaryPriceLabel.text = "\(necessaryPrice.withComma)원"
            
            self.purchaseBT.setTitle("세모페이 충전하기", for: .normal)
        }
    }
    
    private func configurePriceLabel(price: Int) {
        if price == 0 {
            self.usePriceLabel.isHidden = true
        } else {
            self.priceLabel.text = "\(price.withComma)원"
            self.purchaseBT.setTitle("\(price.withComma)원 결제하기", for: .normal)
        }
    }
}

extension PurchasePopupVC {
    private func authentication() {
        self.context = LAContext()
        self.context.localizedCancelTitle = "취소"
        var error: NSError?
        
        if self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            var reason: String = ""
            switch self.context.biometryType {
            case .faceID:
                reason = "구매를 진행하기 위해서 Face ID로 인증해주세요."
            case .touchID:
                reason = "구매를 진행하기 위해서 Touch ID로 인증해주세요."
            case .none:
                reason = "구매를 진행하기 위해서 비밀번호로 인증해주세요."
            default:
                break
            }
            self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                if success {
                    DispatchQueue.main.async { [weak self] in
                        self?.presentingViewController?.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: .purchaseComplete, object: nil)
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? "Faild to authenticate")
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let error = error as? LAError else { return }
                switch error.code {
                case .passcodeNotSet:
                    self?.presentingViewController?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .purchaseComplete, object: nil)
                    })
                default:
                    self?.showAlertWithOK(title: error.localizedDescription, text: "")
                }
            }
        }
    }
}
