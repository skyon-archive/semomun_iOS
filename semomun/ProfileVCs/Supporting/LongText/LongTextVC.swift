//
//  LongTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class LongTextVC: UIViewController, StoryboardController {
    static let identifier = "LongTextVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "Profile", .phone: "Profile_phone"]
    
    private var networkUsecase: UserInfoSendable? = NetworkUsecase(network: Network())
    private lazy var syncUsecase: SyncUsecase? = SyncUsecase(networkUsecase: NetworkUsecase(network: Network()))
    
    @IBOutlet weak var textViewBackground: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelAboutMarketingAccept: UILabel!
    
    @IBOutlet weak var textViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var marketingAcceptBottomSpacing: NSLayoutConstraint!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CoreDataManager.saveCoreData()
    }
}

extension LongTextVC {
    func configureUI(navigationBarTitle: String, text: String, isPopup: Bool, marketingInfo: Bool = false) {
        self.loadViewIfNeeded()
        self.configureBasicUI(navigationBarTitle: navigationBarTitle, text: text)
        if isPopup {
            self.configureUIForPopup()
        } else {
            self.textViewBackground.addShadow(direction: .top)
        }
        if marketingInfo {
            self.addViewsForMarketingAccept()
        }
    }
    
    private func configureBasicUI(navigationBarTitle: String, text: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        } else {
            self.textView.textContainerInset = UIEdgeInsets(top: 67, left: 105, bottom: 67, right: 105)
        }
        
        self.isModalInPresentation = true
        self.textView.text = text
        self.navigationItem.title = navigationBarTitle
    }
    
    private func configureUIForPopup() {
        self.textViewBackground.isHidden = true
        self.textViewLeadingConstraint.constant = 0
        self.textViewTopConstraint.constant = 0
        
        // 우측 상단 닫기 버튼 생성
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let closeImage = UIImage(.xmark, withConfiguration: imageConfig)
        let closePopupButton = UIBarButtonItem(image: closeImage, style: .done, target: self, action: #selector(closePopup))
        closePopupButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = closePopupButton
    }
    
    @objc private func closePopup() {
        self.dismiss(animated: true)
    }
    
    private func addViewsForMarketingAccept() {
        // 라벨 설정
        if self.view.frame.width == 1024 { // 12인치의 경우 수정
            self.marketingAcceptBottomSpacing.constant = 600
        }
        self.labelAboutMarketingAccept.isHidden = false
        self.view.bringSubviewToFront(labelAboutMarketingAccept)
        
        // 토글 설정
        let toggle = MainThemeSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toggle)
        NSLayoutConstraint.activate([
            toggle.leadingAnchor.constraint(equalTo: labelAboutMarketingAccept.trailingAnchor, constant: 12),
            toggle.centerYAnchor.constraint(equalTo: labelAboutMarketingAccept.centerYAnchor),
            toggle.widthAnchor.constraint(equalToConstant: 50),
            toggle.heightAnchor.constraint(equalToConstant: 25),
        ])
        self.view.bringSubviewToFront(toggle)
        
        self.syncUsecase?.syncUserDataFromDB { [weak self] result in
            switch result {
            case .success(var userInfo):
                toggle.isOn = userInfo.marketing
                toggle.setup { [weak self] isOn in
                    userInfo.marketing = isOn
                    self?.networkUsecase?.putUserInfoUpdate(userInfo: userInfo) { status in
                        guard status == .SUCCESS else {
                            self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크 연결 상태를 확인해주세요")
                            
                            // 네트워크 실패시 변경을 원상태로 복구
                            toggle.toggle()
                            userInfo.marketing.toggle()
                            
                            return
                        }
                    }
                }
            case .failure:
                self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크 연결 상태를 확인해주세요") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
