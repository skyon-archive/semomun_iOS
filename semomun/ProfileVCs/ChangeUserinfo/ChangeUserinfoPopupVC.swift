//
//  ChangeUserinfoPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import SwiftUI

class ChangeUserinfoPopupVC: UIViewController {

    static let storyboardName = "Profile"
    static let identifier = "ChangeUserinfoPopupVC"
    
    private enum PhoneAuthState {
        case confirmed, waiting
    }
    
    private var majorsFromNetwork: [Major] = []
    private var majors: [String] {
        return majorsFromNetwork.map(\.name)
    }
    private var majorDetails: [String] {
        return majorsFromNetwork.first(where: { $0.name == selectedMajor })?.details ?? []
    }
    private var selectedMajor = ""
    private var selectedDetailMajor = ""
    private var schoolSearchView: UIHostingController<LoginSchoolSearchView>?
    private var selectedGraduationStatus = ""
    private var selectedSchoolName: String = ""
    
    private let networkUseCase = NetworkUsecase(network: Network())
    
    @IBOutlet weak var bodyFrame: UIView!
    
    @IBOutlet weak var nicknameFrame: UIView!
    @IBOutlet weak var nickname: UITextField!
    
    
    @IBOutlet weak var phoneNumTF: UITextField!
    @IBOutlet weak var phoneNumFrame: UIView!
    @IBOutlet weak var authPhoneNumButton: UIButton!
    
    @IBOutlet weak var majorCollectionView: UICollectionView!
    @IBOutlet weak var majorDetailCollectionView: UICollectionView!
    
    @IBOutlet weak var schoolFinder: UIButton!
    @IBOutlet weak var graduationStatusSelector: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "계정 정보 변경하기"
        bodyFrame.layer.cornerRadius = 15
        
        self.bodyFrame.layer.shadowColor = UIColor.gray.cgColor
        self.bodyFrame.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.bodyFrame.layer.shadowOpacity = 0.4
        self.bodyFrame.layer.shadowRadius = 4
        
        nicknameFrame.layer.borderWidth = 1.5
        nicknameFrame.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        nicknameFrame.layer.cornerRadius = 5
        
        phoneNumFrame.layer.borderWidth = 1.5
        phoneNumFrame.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        phoneNumFrame.layer.cornerRadius = 5
        
        networkUseCase.getMajors { fetched in
            self.majorsFromNetwork = fetched ?? []
            if let userInfo = CoreUsecase.fetchUserInfo() {
                self.nickname.text = userInfo.nickName
                self.selectedMajor = userInfo.major ?? "문과 계열"
                self.selectedDetailMajor = userInfo.majorDetail ?? "인문"
                self.selectedGraduationStatus = userInfo.graduationStatus ?? "재학"
                self.schoolFinder.setTitle(userInfo.schoolName, for: .normal)
                self.selectedSchoolName = userInfo.schoolName ?? ""
                self.graduationStatusSelector.setTitle(userInfo.graduationStatus, for: .normal)
            }
            self.majorCollectionView.reloadData()
            self.majorDetailCollectionView.reloadData()
        }
        majorCollectionView.dataSource = self
        majorCollectionView.delegate = self
        majorDetailCollectionView.dataSource = self
        majorDetailCollectionView.delegate = self
        
        let menuItems: [UIAction] = SchoolSearchUseCase.SchoolType.allCases.map { schoolType in
            UIAction(title: schoolType.rawValue, image: nil, handler: { [weak self] _ in
                self?.schoolSearchView = UIHostingController(rootView: LoginSchoolSearchView(delegate: self, schoolType: schoolType))
                self?.schoolSearchView?.view.backgroundColor = .clear
                if let view = self?.schoolSearchView {
                    self?.present(view, animated: true, completion: nil)
                }
            })
        }
        self.schoolFinder.menu = UIMenu(title: "학교 선택", image: nil, identifier: nil, options: [], children: menuItems)
        self.schoolFinder.showsMenuAsPrimaryAction = true
        
        let graduationMenuItems = ["재학", "졸업"].map { graduationStat in UIAction(title: graduationStat, image: nil) { [weak self] _ in
            self?.selectedGraduationStatus = graduationStat
            self?.graduationStatusSelector.setTitle(graduationStat, for: .normal)
        }}
        self.graduationStatusSelector.menu = UIMenu(title: "대학 / 졸업 선택", options: [], children: graduationMenuItems)
        self.graduationStatusSelector.showsMenuAsPrimaryAction = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        guard majorDetails.contains(selectedDetailMajor) else {
            showAlertWithOK(title: "전공을 선택해주세요.", text: "")
            return
        }
        guard let userInfo = CoreUsecase.fetchUserInfo() else { return }
        userInfo.setValue(self.selectedSchoolName, forKey: "schoolName")
        userInfo.setValue(self.selectedMajor, forKey: "major")
        userInfo.setValue(self.selectedDetailMajor, forKey: "majorDetail")
        userInfo.setValue(self.selectedGraduationStatus, forKey: "graduationStatus")
        
        self.networkUseCase.putUserInfoUpdate(userInfo: userInfo) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .SUCCESS:
                    CoreDataManager.saveCoreData()
                    self?.navigationController?.popViewController(animated: true)
                case .INSPECTION: //TODO: 다른 메세지로 표시 필요
                    self?.showAlertWithOK(title: "일시적인 문제가 발생했습니다", text: "잠시 후 다시 시도해주세요.")
                default:
                    self?.showAlertWithOK(title: "정보 수정 실패", text: "네트워크 확인 후 다시 시도해주세요.")
                }
            }
        }
    }
    
}

extension ChangeUserinfoPopupVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == majorCollectionView {
            self.selectedMajor = majors[indexPath.item]
        } else {
            self.selectedDetailMajor = majorDetails[indexPath.item]
        }
        self.majorCollectionView.reloadData()
        self.majorDetailCollectionView.reloadData()
    }
}

extension ChangeUserinfoPopupVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == majorCollectionView {
            return majors.count
        } else {
            return majorDetails.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MajorCollectionViewCell.identifier, for: indexPath) as? MajorCollectionViewCell else { return UICollectionViewCell() }
        if collectionView == majorCollectionView {
            let majorName = majors[indexPath.item]
            let isSelected = majorName == selectedMajor
            cell.configureUI(major: majorName, isSelected: isSelected)
            return cell
        } else {
            let majorDetailName = majorDetails[indexPath.item]
            let isSelected = majorDetailName == selectedDetailMajor
            cell.configureUI(major: majorDetailName, isSelected: isSelected)
            return cell
        }
    }
}

extension ChangeUserinfoPopupVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == majorCollectionView {
            return CGSize(133, 39)
        } else {
            return CGSize(68, 39)
        }
    }
}

extension ChangeUserinfoPopupVC: SchoolSelectAction {
    func schoolSelected(_ name: String) {
        self.dismissKeyboard()
        self.schoolFinder.setTitle(name, for: .normal)
        self.selectedSchoolName = name
        self.schoolSearchView?.dismiss(animated: true, completion: nil)
    }
}
