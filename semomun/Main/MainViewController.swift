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
    private var previewManager: PreviewManager?
    
    // Sidebar ViewController Properties
    var sideMenuViewController: SideMenuViewController!
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var sideMenuShadowView: UIView!
    var revealSideMenuOnTop: Bool = true
    var isExpanded: Bool = false
    var sideMenuRevealWidth: CGFloat = 329
    let paddingForRotation: CGFloat = 150
    var isPopuped: Bool = false
    private lazy var userInfoView = UserInfoToggleView()
    private var networkUseCase: NetworkUsecase?
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: SemomunImage.empty)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNetwork()
        self.configureAddImage()
        self.configureManager()
        self.configureCollectionView()
        self.configureObserve()
        self.addCoreDataAlertObserver()
        self.previewManager?.fetchPreviews()
        self.previewManager?.fetchSubjects()
        self.configureSideBarViewController()
        self.getVersion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.reloadData()
        self.userInfoView.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureShadowTapGesture()
        self.configureCollectionViewTapGesture()
        self.checkEmptyImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func showSidebar(_ sender: Any) {
        self.sideMenuState()
        self.hideUserInfoView()
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        if !self.isPopuped {
            self.showUserInfoView()
        } else {
            self.hideUserInfoView()
        }
    }
}

// MARK: - Configure MainViewController
extension MainViewController {
    private func configureNetwork() {
        let network = Network()
        self.networkUseCase = NetworkUsecase(network: network)
    }
    
    func configureManager() {
        guard let networkUseCase = self.networkUseCase else { return }
        self.previewManager = PreviewManager(delegate: self, networkUseCase: networkUseCase)
        self.categoryLabel.text = self.previewManager?.currentCategory
    }
    
    func configureCollectionView() {
        self.subjects.delegate = self
        self.previews.delegate = self
        self.addLongpressGesture(target: self.previews)
    }
    
    func configureObserve() {
        NotificationCenter.default.addObserver(forName: .downloadPreview, object: nil, queue: .main) { [weak self] notification in
            guard let targetSubject = notification.userInfo?["subject"] as? String else { return }
            self?.previewManager?.checkSubject(with: targetSubject)
            self?.previewManager?.fetchPreviews()
            self?.reloadData()
            self?.checkEmptyImage()
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .main) { [weak self] _ in
            self?.userInfoView.refresh()
        }
    }
    
    func configureAddImage() {
        guard let addImage = UIImage(named: SemomunImage.addButton) else {
            print("Error: addImage not corrent")
            return
        }
        addImageData = addImage.pngData()
    }
    
    func configureCollectionViewTapGesture() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.previews.addGestureRecognizer(tapGesture)
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        self.hideUserInfoView()
        if let indexPath = self.previews?.indexPathForItem(at: sender.location(in: self.previews)) {
            self.didSelectItemAt(indexPath: indexPath)
        }
    }
    
    private func checkEmptyImage() {
        guard let count = self.previewManager?.previewsCount else { return }
        self.emptyImageView.removeFromSuperview()
        if count == 0 {
            DispatchQueue.main.async { [weak self] in
                self?.createEmptyImage()
            }
        }
    }
    
    private func createEmptyImage() {
        guard let targetCell = self.previews.cellForItem(at: IndexPath(item: 0, section: 0)) as? PreviewCell else { return }
        self.view.insertSubview(self.emptyImageView, at: 4)
        self.emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.emptyImageView.widthAnchor.constraint(equalToConstant: 428),
            self.emptyImageView.heightAnchor.constraint(equalToConstant: 299),
            self.emptyImageView.leadingAnchor.constraint(equalTo: targetCell.imageView.centerXAnchor),
            self.emptyImageView.topAnchor.constraint(equalTo: targetCell.imageView.bottomAnchor)
        ])
    }
    
    private func getVersion() {
        self.networkUseCase?.getAppstoreVersion { status, versionDTO in
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .SUCCESS:
                    print("get version success")
                    guard let versionDTO = versionDTO else { return }
                    if !versionDTO.results.isEmpty, let version = versionDTO.results.first?.version {
                        self?.checkVersion(with: version)
                    }
                    print("version is empty list")
                case .ERROR:
                    self?.showAlertWithOK(title: "네트워크 비정상", text: "")
                default:
                    return
                }
            }
        }
    }
    
    private func checkVersion(with appstoreVersion: String) {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            print("Error: can't read version")
            return
        }
        print(version, appstoreVersion)
        if version != appstoreVersion {
            self.showAlertWithOK(title: "업데이트 후 사용해주세요", text: "앱스토어의 \(appstoreVersion)를 다운받아주세요")
        }
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
                self.previewManager?.showDeleteAlert(at: indexPath.item-1)
            }
        }
    }
}

// MARK: - Logic
extension MainViewController {
    func showSearchWorkbookViewController() {
        guard let previewManager = self.previewManager else { return }
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SearchWorkbookViewController.identifier) as? SearchWorkbookViewController else { return }
        let category = previewManager.currentCategory
        guard let networkUseCase = self.networkUseCase else { return }
        nextVC.manager = SearchWorkbookManager(filter: previewManager.previews, category: category, networkUseCase: networkUseCase)
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
        guard let previewManager = self.previewManager else { return 0 }
        if collectionView == subjects {
            return previewManager.subjectsCount
        } else {
            return previewManager.previewsCount+1
        }
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let previewManager = self.previewManager else { return UICollectionViewCell() }
        if collectionView == subjects {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            
            cell.category.text = previewManager.subject(at: indexPath.item)
            cell.underLine.alpha = (indexPath.item == previewManager.currentIndex) ? 1 : 0
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            
            if indexPath.item == 0 {
                cell.configureAddCell(image: UIImage(data: self.addImageData))
                
                return cell
            }
            else {
                let preview = previewManager.preview(at: indexPath.item-1)
                print("\(indexPath.item): \(preview)")
                cell.configure(with: preview)
                
                return cell
            }
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.hideUserInfoView()
        // MARK: - category
        if collectionView == subjects {
            self.previewManager?.selectSubject(idx: indexPath.item)
            self.previewManager?.fetchPreviews()
            self.reloadData()
            return
        }
        
        self.didSelectItemAt(indexPath: indexPath)
    }
    
    func didSelectItemAt(indexPath: IndexPath) {
        guard let previewManager = self.previewManager else { return }
        // MARK: - preview cell: searchPreview
        if indexPath.item == 0 {
            showSearchWorkbookViewController()
            return
        }
        
        // MARK: - preview cell: selectSectionView
        let index = indexPath.item-1
        if previewManager.showSelectSectionView(index: index) {
            print("goToSelectSectionViewController")
            return
        }
        
        let preview = previewManager.preview(at: index)
        guard let sid = preview.sids.first else { return }
        
        // MARK: - Section: form CoreData
        if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
            self.showSolvingVC(section: section, preview: preview)
            return
        }
        // 여기에 else로 넣을까? return을 빼고
        // MARK: - Section: Download from DB
        self.networkUseCase?.downloadPages(sid: sid) { views in
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
                
                DispatchQueue.main.async { [weak self] in
                    loading.terminate()
                    preview.setValue(true, forKey: "downloaded")
                    CoreDataManager.saveCoreData()
                    self?.reloadData()
                }
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
        self.emptyImageView.removeFromSuperview()
        self.categoryLabel.text = category
        self.previewManager?.updateCategory(to: category)
        DispatchQueue.main.async { [weak self] in self?.hideSideBar() }
        self.checkEmptyImage()
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
            self.previewManager?.delete(at: idx)
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
        self.isPopuped = true
    }
    
    func hideUserInfoView() {
        if !isPopuped { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.userInfoView.alpha = 0
            self?.userInfoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { [weak self] _ in
            self?.userInfoView.removeFromSuperview()
        }
        self.isPopuped = false
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
        let backItem = UIBarButtonItem()
        backItem.title = "뒤로가기"
        self.navigationItem.backBarButtonItem = backItem
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SettingViewController.identifier) else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
