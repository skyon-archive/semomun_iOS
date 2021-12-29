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
    @IBOutlet weak var nameFrameView: UIView!
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureName(to: CoreUsecase.fetchUserInfo()?.name ?? "홍길동")
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateName(_ sender: Any) {
        guard let newName = self.nameField.text else {
            self.showAlertWithOK(title: "에러", text: "입력된 값을 확인해주시기 바랍니다.")
            return
        }
        let userInfo = CoreUsecase.fetchUserInfo()
        userInfo?.setValue(newName, forKey: "name")
        NetworkUsecase.postRename(to: newName, token: KeychainItem.currentUserIdentifier) { [weak self] status in
            guard let status = status else {
                self?.showAlertWithOK(title: "네트워크 에러", text: "다시 시도하시기 바랍니다.")
                return
            }
            if status {
                CoreDataManager.saveCoreData()
                self?.showAlertWithOK(title: "성공", text: "새로운 이름이 반영되었습니다.")
                self?.delegate?.loadData()
            } else {
                self?.showAlertWithOK(title: "네트워크 에러", text: "다시 시도하시기 바랍니다.")
            }
        }
        
    }
}

extension PersonalSettingNameViewController {
    func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 25
        self.setShadow(to: self.nameFrameView)
    }
    
    func setShadow(to view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
        view.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    func configureName(to name: String) {
        self.nameField.text = name
    }
}
