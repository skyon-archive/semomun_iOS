//
//  SchoolSelectPopupVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/18.
//

import UIKit

protocol SchoolSelectDelegate: AnyObject {
    func selectSchool(to: String)
}

final class SchoolSelectPopupVC: UIViewController {
    static let identifier = "SchoolSelectPopupVC"
    
    @IBOutlet weak var schoolCategoryButton: UIButton!
    @IBOutlet weak var schoolList: UICollectionView!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    
    private weak var delegate: SchoolSelectDelegate?
    private var schoolSearchUsecase: SchoolSearchUseCase?
    private var schoolTotalList: [String] = [] {
        didSet {
            let text = self.schoolTextField.text ?? ""
            if text == "" {
                self.schoolListData = self.schoolTotalList
            } else {
                self.schoolListData = self.schoolTotalList.filter { $0.contains(text) }
            }
        }
    }
    private var schoolListData: [String] = [] {
        didSet {
            self.schoolName = nil
            self.schoolList.reloadData()
        }
    }
    private var schoolName: String? {
        didSet {
            if schoolName == nil {
                self.completeButton.isUserInteractionEnabled = false
                self.completeButton.backgroundColor = UIColor.getSemomunColor(.lightGray)
            } else {
                self.completeButton.isUserInteractionEnabled = true
                self.completeButton.backgroundColor = UIColor.getSemomunColor(.blueRegular)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureMenu()
        self.configureTextField()
        self.configureCollectionView()
        self.configureSchoolSearchUsecase()
        
        self.schoolSearchUsecase?.request(schoolKey: SchoolSearchUseCase.SchoolType.elementary.key, completion: { [weak self] list in
            self?.schoolTotalList = list
        })
    }
    
    func configureDelegate(_ delegate: SchoolSelectDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func complete(_ sender: Any) {
        guard let schoolName = schoolName else { return }
        self.delegate?.selectSchool(to: schoolName)
        self.dismiss(animated: true)
    }
}

extension SchoolSelectPopupVC {
    private func configureMenu() {
        let menuItems: [UIAction] = SchoolSearchUseCase.SchoolType.allCases.map { schoolType in
            UIAction(title: schoolType.rawValue, image: nil, handler: { [weak self] _ in
                self?.schoolCategoryButton.setTitle(schoolType.rawValue, for: .normal)
                self?.schoolSearchUsecase?.request(schoolKey: schoolType.key, completion: { [weak self] list in
                    self?.schoolTotalList = list
                })
            })
        }
        self.schoolCategoryButton.menu = UIMenu(title: "학교 구분", image: nil, identifier: nil, options: [], children: menuItems)
        self.schoolCategoryButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureTextField() {
        self.schoolTextField.delegate = self
        self.schoolTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    private func configureCollectionView() {
        self.schoolList.delegate = self
        self.schoolList.dataSource = self
    }
    
    private func configureSchoolSearchUsecase() {
        self.schoolSearchUsecase = SchoolSearchUseCase(networkUseCase: NetworkUsecase(network: Network()))
    }
}

extension SchoolSelectPopupVC: UITextFieldDelegate {
    @objc func textFieldDidChange() {
        guard let text = self.schoolTextField.text else { return }
        self.schoolListData = self.schoolTotalList.filter { $0.contains(text) }
    }
}

extension SchoolSelectPopupVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.schoolName = self.schoolListData[indexPath.item]
        self.dismissKeyboard()
        self.schoolList.reloadData()
    }
}

extension SchoolSelectPopupVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.schoolListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SchoolCell.identifier, for: indexPath) as? SchoolCell else { return .init() }
        cell.configure(name: self.schoolListData[indexPath.item], currentSchoolName: self.schoolName)
        return cell
    }
}

extension SchoolSelectPopupVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(collectionView.bounds.width, SchoolCell.cellHeight)
    }
}
