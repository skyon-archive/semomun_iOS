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
    @IBOutlet weak var currentMoneyLabel: UILabel!
    @IBOutlet weak var afterMoneyLabel: UILabel!
    @IBOutlet weak var moneyStatusLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
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
        self.configureTitle(to: info.title)
        self.configureMoneyUI(currentMoney: currentMoney, info: info)
        
        switch type {
        case .purchase:
            self.configureActionTitle(to: "구매하고 문제 풀기")
            self.moneyStatusLabel.text = "구매 후 세모페이 잔액"
            self.warningLabel.isHidden = true
        case .charge:
            self.configureActionTitle(to: "세모페이 충전하기")
        }
    }
    
    private func configureTitle(to title: String) {
        let fullTitle = "\(title)\n구매하시겠습니까?"
        let fontSize = UIFont.systemFont(ofSize: 18, weight: .heavy)
        let attrTitle = NSMutableAttributedString(string: fullTitle)
        attrTitle.addAttribute(.font, value: fontSize, range: (title as NSString).range(of: title))
        self.titleLabel.attributedText = attrTitle
    }
    
    private func configureMoneyUI(currentMoney: Int, info: WorkbookOfDB) {
        self.priceLabel.text = "\(info.price.withComma)원"
        self.currentMoneyLabel.text = "\(currentMoney.withComma)원"
        let afterMoney = Int((currentMoney - info.price).magnitude)
        self.afterMoneyLabel.text = "\(afterMoney.withComma)원"
    }
    
    private func configureActionTitle(to title: String) {
        self.purchaseBT.setTitle(title, for: .normal)
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
