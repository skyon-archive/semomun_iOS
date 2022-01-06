//
//  SettingViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2021/12/28.
//

import UIKit

class SettingViewController: UIViewController {
    static let identifier = "SettingViewController"
    
    @IBOutlet weak var versionNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "설정"
        self.versionNum.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    @IBAction func userLogout(_ sender: Any) {
        self.showAlertWithClosure(title: "로그아웃 하시겠습니끼?", text: "") { [weak self] _ in
            self?.logout()
        }
    }
    
    @IBAction func openCustomerService(_ sender: Any) {
        if let url = URL(string: NetworkUsecase.URL.customerService) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func openTermsAndCondition(_ sender: Any) {
        guard let filepath = Bundle.main.path(forResource: "termsAndConditions", ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.popupTextViewController(title: "서비스이용약관", text: text)
        } catch {
            self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    @IBAction func openPersonalInformationPolicy(_ sender: Any) {
        guard let filepath = Bundle.main.path(forResource: "personalInformationProcessingPolicy", ofType: "txt") else { return }
        do {
            let text = try String(contentsOfFile: filepath)
            self.popupTextViewController(title: "개인정보 처리방침", text: text)
        } catch {
            self.showAlertWithOK(title: "에러", text: "파일로딩에 실패하였습니다.")
        }
    }
    
    @IBAction func errorReport(_ sender: Any) {
        if let url = URL(string: NetworkUsecase.URL.errorReport) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension SettingViewController {
    private func popupTextViewController(title: String, text: String) {
        let vc = LongTextPopupViewController(title: title, text: text)
        present(vc, animated: true, completion: nil)
    }
    
    private func logout() {
        CoreUsecase.deleteAllCoreData()
        KeychainItem.deleteUserIdentifierFromKeychain()
        print("keychain delete complete")
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("userDefaults delete complete")
        
        self.showAlertOKWithClosure(title: "로그아웃 되었습니다", text: "") { [weak self] _ in
            self?.goToStartViewController()
        }
    }
    
    private func goToStartViewController() {
        guard let startVC = self.storyboard?.instantiateViewController(withIdentifier: StartViewController.identifier) else { return }
        let navigationController = UINavigationController(rootViewController: startVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
}
