//
//  LongTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class LongTextVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "LongTextVC"
    
    private var navigationBarTitle: String?
    private var text: String?
    private var isViewForMarketingAccept = false
    
    private let networkUsecase: MarketingConsentSendable = NetworkUsecase(network: Network())
    
    @IBOutlet weak var textViewBackground: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelAboutMarketingAccept: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureBackgroundUI()
        self.textView.textContainerInset = UIEdgeInsets(top: 67, left: 105, bottom: 67, right: 105)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.text = self.text
        self.navigationItem.title = self.navigationBarTitle
        if self.isViewForMarketingAccept {
            self.addViewsForMarketingAccept()
        }
    }
}

extension LongTextVC {
    func configureUI(navigationBarTitle: String, text: String, marketingInfo: Bool = false) {
        self.navigationBarTitle = navigationBarTitle
        self.text = text
        self.isViewForMarketingAccept = marketingInfo
    }
    
    private func configureBackgroundUI() {
        self.textViewBackground.layer.cornerRadius = 15
        self.textViewBackground.addShadow()
    }
    
    private func addViewsForMarketingAccept() {
        // 라벨 설정
        self.labelAboutMarketingAccept.isHidden = false
        self.view.bringSubviewToFront(labelAboutMarketingAccept)
        // 토글 설정
        let toggle = MainThemeSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setup { [weak self] isOn in
            self?.networkUsecase.postMarketingConsent(isConsent: isOn) { status in
                if status != .SUCCESS {
                    self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크를 확인해주세요")
                    toggle.toggleButton()
                }
            }
        }
        
        self.view.addSubview(toggle)
        NSLayoutConstraint.activate([
            toggle.leadingAnchor.constraint(equalTo: labelAboutMarketingAccept.trailingAnchor, constant: 12),
            toggle.centerYAnchor.constraint(equalTo: labelAboutMarketingAccept.centerYAnchor),
            toggle.widthAnchor.constraint(equalToConstant: 50),
            toggle.heightAnchor.constraint(equalToConstant: 25),
        ])
        self.view.bringSubviewToFront(toggle)
    }
    
}
