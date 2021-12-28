//
//  MainViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/11.
//

import UIKit
import CoreData
import SwiftUI

class MainViewController: UIViewController {
    static let identifier = "MainViewController"
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categorySelector: UIButton!
    @IBOutlet weak var subjects: UICollectionView!
    @IBOutlet weak var previews: UICollectionView!
    @IBOutlet weak var userInfo: UIButton!
    
    private var addImageData: Data!
    private var previewManager: PreviewManager!
    
    // Sidebar ViewController Properties
    var sideMenuViewController: SideMenuViewController!
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var sideMenuShadowView: UIView!
    var revealSideMenuOnTop: Bool = true
    var isExpanded: Bool = false
    var sideMenuRevealWidth: CGFloat = 260
    let paddingForRotation: CGFloat = 150
    private lazy var userInfoView = UserInfoToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAddImage()
        self.configureManager()
        self.configureCollectionView()
        self.configureObserve()
        self.addCoreDataAlertObserver()
        self.previewManager.fetchPreviews()
        self.previewManager.fetchSubjects()
        print(Bundle.main.infoDictionary?["API_ACCESS_KEY1"] as? String ?? "no_access_key")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.reloadData()
        self.userInfoView.configureUserName()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureSideBarViewController()
        self.configureTapGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func showSidebar(_ sender: Any) {
        self.sideMenuState()
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        sender.isSelected.toggle()
        print(sender)
        if sender.isSelected {
            self.showUserInfoView()
        } else {
            self.hideUserInfoView()
        }
    }
}

// MARK: - Configure MainViewController
extension MainViewController {
    func configureManager() {
        self.previewManager = PreviewManager(delegate: self)
        self.categoryLabel.text = self.previewManager.currentCategory
    }
    
    func configureCollectionView() {
        self.subjects.delegate = self
        self.previews.delegate = self
        self.addLongpressGesture(target: self.previews)
    }
    
    func configureObserve() {
        NotificationCenter.default.addObserver(forName: ShowDetailOfWorkbookViewController.refresh, object: nil, queue: .main) { notification in
            guard let targetSubject = notification.userInfo?["subject"] as? String else { return }
            self.previewManager.checkSubject(with: targetSubject)
            self.previewManager.fetchPreviews()
            self.reloadData()
        }
    }
    
    func configureAddImage() {
        guard let addImage = UIImage(named: "addButton") else {
            print("Error: addImage not corrent")
            return
        }
        addImageData = addImage.pngData()
    }
}

// MARK: - CollectionView LongPress Action
extension MainViewController {
    func addLongpressGesture(target: UIView) {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        target.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.minimumPressDuration = 0.7
    }
    
    @objc func longPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: previews)
            guard let indexPath = previews.indexPathForItem(at: touchPoint) else { return }
            if indexPath.item-1 >= 0 {
                self.previewManager.showDeleteAlert(at: indexPath.item-1)
            }
        }
    }
}

// MARK: - Logic
extension MainViewController {
    func showSearchWorkbookViewController() {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SearchWorkbookViewController.identifier) as? SearchWorkbookViewController else { return }
        let category = self.previewManager.currentCategory
        nextVC.manager = SearchWorkbookManager(filter: previewManager.previews, category: category)
        self.present(nextVC, animated: true, completion: nil)
    }
    
    func showSolvingVC(section: Section_Core, preview: Preview_Core) {
        guard let solvingVC = self.storyboard?.instantiateViewController(withIdentifier: SolvingViewController.identifier) as? SolvingViewController else { return }
        solvingVC.modalPresentationStyle = .fullScreen
        solvingVC.sectionCore = section
        solvingVC.previewCore = preview
        self.present(solvingVC, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == subjects {
            return self.previewManager.subjectsCount
        } else {
            return self.previewManager.previewsCount+1
        }
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subjects {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            
            cell.category.text = self.previewManager.subject(at: indexPath.item)
            cell.underLine.alpha = (indexPath.item == self.previewManager.currentIndex) ? 1 : 0
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            
            if indexPath.item == 0 {
                cell.configureAddCell(image: UIImage(data: self.addImageData))
                
                return cell
            }
            else {
                let preview = self.previewManager.preview(at: indexPath.item-1)
                print("\(indexPath.item): \(preview)")
                cell.configure(with: preview)
                
                return cell
            }
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - category
        if collectionView == subjects {
            self.previewManager.selectSubject(idx: indexPath.item)
            self.previewManager.fetchPreviews()
            self.reloadData()
            return
        }
        
        // MARK: - preview cell: searchPreview
        if indexPath.item == 0 {
            showSearchWorkbookViewController()
            return
        }
        
        // MARK: - preview cell: selectSectionView
        let index = indexPath.item-1
        if self.previewManager.showSelectSectionView(index: index) {
            print("goToSelectSectionViewController")
            return
        }
        
        let preview = self.previewManager.preview(at: index)
        guard let sid = preview.sids.first else { return }
        
        // MARK: - Section: form CoreData
        if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
            self.showSolvingVC(section: section, preview: preview)
            return
        }
        // 여기에 else로 넣을까? return을 빼고
        // MARK: - Section: Download from DB
        NetworkUsecase.downloadPages(sid: sid) { views in
            print("NETWORK RESULT")
            print(views)
            // save to coreData
            let loading = self.startLoading()
            CoreUsecase.savePages(sid: sid, pages: views, loading: loading) { section in
                if section == nil {
                    loading.terminate()
                    self.showAlertWithOK(title: "서버 데이터 오류", text: "문제집 데이터가 올바르지 않습니다.")
                    return
                }
                
                loading.terminate()
                preview.setValue(true, forKey: "downloaded")
                CoreDataManager.saveCoreData()
                self.reloadData()
                return
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == previews {
            let width = (previews.frame.width)/4
            let height = previews.frame.height/3
            
            return CGSize(width: width, height: height)
        }
        else {
            return CGSize(width: 70, height: 40)
        }
    }
}

// MARK: - Protocol: SideMenuViewControllerDelegate
extension MainViewController: SideMenuViewControllerDelegate {
    func selectCategory(to category: String) {
        self.categoryLabel.text = category
        self.previewManager.updateCategory(to: category)
        DispatchQueue.main.async { [weak self] in self?.sideMenuState() }
    }
}

// MARK: - Protocol: PreviewDatasource
extension MainViewController: PreviewDatasource {
    func reloadData() {
        self.subjects.reloadData()
        self.previews.reloadData()
    }
    
    func deleteAlert(title: String, idx: Int) {
        let alert = UIAlertController(title: title,
                                      message: "삭제하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        let delete = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.previewManager.delete(at: idx)
        })
        
        alert.addAction(cancle)
        alert.addAction(delete)
        present(alert,animated: true,completion: nil)
    }
}

extension MainViewController {
    func showUserInfoView() {
        self.userInfoView.configureDelegate(delegate: self)
        self.userInfoView.alpha = 0
        self.userInfoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.view.addSubview(self.userInfoView)
        self.userInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.userInfoView.widthAnchor.constraint(equalToConstant: 250),
            self.userInfoView.heightAnchor.constraint(equalToConstant: 160),
            self.userInfoView.trailingAnchor.constraint(equalTo: self.userInfo.trailingAnchor),
            self.userInfoView.topAnchor.constraint(equalTo: self.userInfo.bottomAnchor, constant: 20)
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.userInfoView.alpha = 1
            self?.userInfoView.transform = CGAffineTransform.identity
        }
    }
    
    func hideUserInfoView() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.userInfoView.alpha = 0
            self?.userInfoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { [weak self] _ in
            self?.userInfoView.removeFromSuperview()
        }
    }
}

extension MainViewController: UserInfoPushable {
    func showUserSetting() {
        let backItem = UIBarButtonItem()
        backItem.title = "뒤로가기"
        self.navigationItem.backBarButtonItem = backItem
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: PersonalSettingViewController.identifier) else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func showSetting() {
        print("showSetting")
        
    }
}
