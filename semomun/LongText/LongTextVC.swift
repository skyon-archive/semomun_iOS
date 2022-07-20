//
//  LongTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class LongTextVC: UIViewController {
    enum Resource: String {
        case termsAndConditions
        case personalInformationProcessingPolicy
        case receiveMarketingInfo
        case termsOfElectronicTransaction
        
        var title: String {
            switch self {
            case .termsAndConditions:
                return "이용약관"
            case .personalInformationProcessingPolicy:
                return "개인정보 처리 방침"
            case .receiveMarketingInfo:
                return "마케팅 수신 동의"
            case .termsOfElectronicTransaction:
                return "전자금융거래 이용약관"
            }
        }
    }
    
    private var networkUsecase: UserInfoSendable? = NetworkUsecase(network: Network())
    private lazy var syncUsecase: SyncUsecase? = SyncUsecase(networkUsecase: NetworkUsecase(network: Network()))
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.white)
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .regularStyleParagraph
        view.textColor = .getSemomunColor(.darkGray)
        view.textContainerInset = .init(top: 32, left: 24, bottom: 32, right: 24)
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    @IBOutlet weak var labelAboutMarketingAccept: UILabel!
    @IBOutlet weak var marketingAcceptBottomSpacing: NSLayoutConstraint!
    
    init(resource: Resource) {
        super.init(nibName: nil, bundle: nil)
        self.configureLayout()
        
        guard let filepath = Bundle.main.path(forResource: resource.rawValue, ofType: "txt"),
              let text = try? String(contentsOfFile: filepath) else {
            return
        }
        
        self.view.backgroundColor = .getSemomunColor(.background)
        self.textView.text = text
        self.navigationItem.title = resource.title
        
        if resource == .receiveMarketingInfo {
            self.addViewsForMarketingAccept()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LongTextVC {
    private func configureLayout() {
        self.view.addSubview(self.backgroundView)
        self.backgroundView.addSubview(self.textView)
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.textView.topAnchor.constraint(equalTo: self.backgroundView.topAnchor),
            self.textView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor),
            self.textView.bottomAnchor.constraint(equalTo: self.backgroundView.bottomAnchor),
            self.textView.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor)
        ])
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
                        CoreDataManager.saveCoreData()
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
