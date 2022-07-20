//
//  LongTextPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

final class LongTextPopupVC: UIViewController {
    static let identifier = "LongTextPopupVC"
    enum Text: String {
        case personalInformationProcessingPolicy // 개인정보 처리방침
        case termsAndConditions // 서비스 이용약관
        case receiveMarketingInfo // 마케팅 수신동의
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    var text: Text = .personalInformationProcessingPolicy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .black)
        self.configureTextView()
        self.configureText()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension LongTextPopupVC {
    private func configureTextView() {
        self.textView.allowsEditingTextAttributes = false
        self.textView.enablesReturnKeyAutomatically = false
        self.textView.isSecureTextEntry = true
        self.textView.isSelectable = false
    }
    
    private func configureTextView(fileName: String) {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.textView.text = text
        } catch {
            self.showAlertWithOK(title: "파일로딩 실패", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    private func configureText() {
        switch self.text {
        case .personalInformationProcessingPolicy:
            self.titleLabel.text = "개인정보 처리방침"
        case .termsAndConditions:
            self.titleLabel.text = "서비스 이용약관"
        case .receiveMarketingInfo:
            self.titleLabel.text = "마케팅 수신동의"
        }
        
        self.configureTextView(fileName: text.rawValue)
    }
}
