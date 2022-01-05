//
//  PersonalSettingNameViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/18.
//

import UIKit

class PersonalSettingNameViewController: UIViewController {
    static let identifier = "PersonalSettingNameViewController"
    weak var delegate: ReloadUserData?
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    private var userInfo: UserCoreData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureUserInfo()
        self.configureName(to: self.userInfo?.name ?? "")
        self.configurePhone(to: self.userInfo?.phoneNumber ?? "")
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateUserInfo(_ sender: Any) {
        self.dismissKeyboard()
        guard let userInfo = self.userInfo,
              let newName = self.nameField.text,
              let newPhone = self.phoneField.text else {
                  self.showAlertWithOK(title: "에러", text: "입력된 값을 확인해주시기 바랍니다.")
                  return
              }
        
        userInfo.setValue(newName, forKey: "name")
        userInfo.setValue(newPhone, forKey: "phoneNumber")
        
        NetworkUsecase.postUserInfoUpdate(userInfo: userInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    CoreDataManager.saveCoreData()
                    self?.showAlertWithOK(title: "정보 수정 완료", text: "")
                    self?.delegate?.loadData()
                case .INSPECTION:
                    self?.showAlertWithOK(title: "서버 점검중", text: "추후 다시 시도하시기 바랍니다.")
                default:
                    self?.showAlertWithOK(title: "정보 수정 실패", text: "네트워크 확인 후 다시 시도해주세요.")
                }
            }
        }
    }
}

extension PersonalSettingNameViewController {
    private func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 16
    }
    
    private func configureUserInfo() {
        self.userInfo = CoreUsecase.fetchUserInfo()
    }
    
    private func configureName(to name: String) {
        self.nameField.text = name
    }
    
    private func configurePhone(to phone: String) {
        self.phoneField.text = phone
    }
}
