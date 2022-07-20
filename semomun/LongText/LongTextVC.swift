//
//  LongTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

final class LongTextVC: UIViewController {
    /* public */
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
    /* private */
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
        view.textContainerInset = .init(top: 24, left: 32, bottom: 24, right: 32)
        view.contentInsetAdjustmentBehavior = .never
        view.isEditable = false
        view.isSelectable = false
        return view
    }()
    private var networkUsecase: UserInfoSendable?
    private var syncUsecase: SyncUsecase?
    private lazy var marketingToggle: MainThemeSwitch = {
        let toggle = MainThemeSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    private lazy var marketingToggleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "수신 동의"
        label.textColor = .getSemomunColor(.darkGray)
        label.font = .heading5
        return label
    }()
    private lazy var marketingToggleTopConstraint: NSLayoutConstraint = {
        return self.marketingToggle.topAnchor.constraint(equalTo: self.textView.topAnchor)
    }()
    
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
    }
    
    /// 마케팅 수신 동의 화면을 위한 init
    convenience init(withMarketingToggle networkUsecase: (UserInfoSendable & SyncFetchable)) {
        self.init(resource: .receiveMarketingInfo)
        self.syncUsecase = SyncUsecase(networkUsecase: networkUsecase)
        self.networkUsecase = networkUsecase
        self.configureMarketingToggleLayout()
        self.configureMarketingToggleAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TextField의 마지막 줄 하단에 토글 위치
    // TextField의 내용물이 화면을 가득 채우지 않는다는 전제
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.marketingToggleTopConstraint.constant = self.textView.contentSize.height
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
    
    private func configureMarketingToggleLayout() {
        self.view.addSubview(self.marketingToggle)
        self.marketingToggle.addSubview(self.marketingToggleLabel)
        
        NSLayoutConstraint.activate([
            self.marketingToggle.widthAnchor.constraint(equalToConstant: 50),
            self.marketingToggle.heightAnchor.constraint(equalToConstant: 25),
            
            self.marketingToggleLabel.centerYAnchor.constraint(equalTo: self.marketingToggle.centerYAnchor),
            self.marketingToggleLabel.leadingAnchor.constraint(equalTo: self.marketingToggle.trailingAnchor, constant: 8),
            self.marketingToggleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
        self.marketingToggleTopConstraint.isActive = true
    }
    
    private func configureMarketingToggleAction() {
        self.syncUsecase?.syncUserDataFromDB { [weak self] result in
            switch result {
            case .success(var userInfo):
                self?.marketingToggle.isOn = userInfo.marketing
                self?.marketingToggle.setup { [weak self] isOn in
                    userInfo.marketing = isOn
                    self?.networkUsecase?.putUserInfoUpdate(userInfo: userInfo) { status in
                        guard status == .SUCCESS else {
                            self?.showAlertWithOK(title: "네트워크 없음", text: "네트워크 연결 상태를 확인해주세요")
                            // 네트워크 실패시 변경을 원상태로 복구
                            self?.marketingToggle.toggle()
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
