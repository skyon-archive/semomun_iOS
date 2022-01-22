//
//  MainViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/11.
//

import UIKit
import CoreData
import Combine

class MainViewController: UIViewController {
    static let identifier = "MainViewController"
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categorySelector: UIButton!
    @IBOutlet weak var subjects: UICollectionView!
    @IBOutlet weak var previews: UICollectionView!
    @IBOutlet weak var userInfo: UIButton!
    
    // Sidebar ViewController Properties
    var sideMenuViewController: SideMenuViewController!
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var sideMenuShadowView: UIView!
    var isExpanded: Bool = false
    let sideMenuRevealWidth: CGFloat = 329
    let paddingForRotation: CGFloat = 150
    // MainViewController Properties
    private var isUserInfoPopuped: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    private var previewManager: PreviewManager?
    private var viewModel: MainViewModel?
    // Views
    private lazy var userInfoView = UserInfoToggleView()
    private lazy var emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: SemomunImage.empty)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureManager()
        self.configureViewModel()
        self.bindAll()
        self.configureCollectionView()
        self.configureObserve()
        self.addCoreDataAlertObserver()
        self.previewManager?.fetchPreviews()
        self.previewManager?.fetchSubjects()
        self.configureSideBarViewController()
        self.viewModel?.getVersion()
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
        if !self.isUserInfoPopuped {
            self.showUserInfoView()
        } else {
            self.hideUserInfoView()
        }
    }
}

// MARK: - Configure MainViewController
extension MainViewController {
    private func bindAll() {
        self.bindVersion()
        self.bindNetworkError()
        self.bindLoader()
        self.bindDownloadSection()
    }
    
    private func bindVersion() {
        self.viewModel?.$updateToVersion
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] version in
                guard let version = version else { return }
                self?.showAlertWithOK(title: "업데이트 후 사용해주세요", text: "앱스토어의 \(version)를 다운받아주세요")
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNetworkError() {
        self.viewModel?.$networkWarning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning, text: "")
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLoader() {
        self.viewModel?.$createLoading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] create in
                if create {
                    guard let loader = self?.startLoading() else { return }
                    self?.viewModel?.savePages(loading: loader)
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindDownloadSection() {
        self.viewModel?.$downloadedSection
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] downloaded in
                if !downloaded {
                    self?.showAlertWithOK(title: "서버 데이터 오류", text: "문제집 데이터가 올바르지 않습니다.")
                    return
                }
                guard let targetIndex = self?.previewManager?.selectedPreviewIndex,
                      let preview = self?.previewManager?.preview(at: targetIndex) else { return }
                preview.setValue(true, forKey: "downloaded")
                CoreDataManager.saveCoreData()
                self?.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func configureManager() {
        self.previewManager = PreviewManager(delegate: self)
        self.categoryLabel.text = self.previewManager?.currentCategory
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        let useCase = MainUseCase(networkUseCase: networkUseCase)
        self.viewModel = MainViewModel(useCase: useCase)
    }
    
    private func configureCollectionView() {
        self.subjects.delegate = self
        self.previews.delegate = self
        self.addLongpressGesture(target: self.previews)
    }
    
    private func configureObserve() {
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
    
    private func configureCollectionViewTapGesture() {
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
}

// MARK: - CollectionView LongPress Action
extension MainViewController {
    private func addLongpressGesture(target: UIView) {
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
    private func showSearchWorkbookViewController() {
        guard let previewManager = self.previewManager else { return }
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: SearchWorkbookViewController.identifier) as? SearchWorkbookViewController else { return }
        let category = previewManager.currentCategory
        let network = Network()
        let networkUseCase = NetworkUsecase(network: network)
        nextVC.manager = SearchWorkbookManager(filter: previewManager.previews, category: category, networkUseCase: networkUseCase)
        self.present(nextVC, animated: true, completion: nil)
    }
    
    private func showSolvingVC(section: Section_Core, preview: Preview_Core) {
        guard let solvingVC = UIStoryboard(name: "Study", bundle: nil).instantiateViewController(withIdentifier: StudyVC.identifier) as? StudyVC else { return }
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
            cell.category.sizeToFit()
            cell.underLine.alpha = (indexPath.item == previewManager.currentIndex) ? 1 : 0
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            
            if indexPath.item == 0 {
                if let addImageData = UIImage(named: SemomunImage.addButton)?.pngData() {
                    cell.configureAddCell(image: UIImage(data: addImageData))
                }
                
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
        let preview = previewManager.preview(at: index)
        
        if previewManager.showSelectSectionView(index: index) {
            print("go to workbookDetailViewController")
            guard let workbookDetailViewController = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
            let viewModel = WorkbookViewModel(previewCore: preview)
            workbookDetailViewController.configureViewModel(to: viewModel)
            workbookDetailViewController.configureIsCoreData(to: true)
            self.navigationController?.pushViewController(workbookDetailViewController, animated: true)
            return
        }

        guard let sid = preview.sids.first else { return }

        // MARK: - Section: form CoreData
        if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
            self.showSolvingVC(section: section, preview: preview)
            return
        }

        // MARK: - Section: Download from DB
        self.previewManager?.selectPreview(to: index)
        self.viewModel?.selectSection(to: sid)
        self.viewModel?.getPages(sid: sid)
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
            if let subjectText = self.previewManager?.subject(at: indexPath.item) {
                let count = subjectText.count
                if count < 6 {
                    return CGSize(width: 80, height: 40)
                } else if count < 10 {
                    return CGSize(width: 120, height: 40)
                } else {
                    return CGSize(width: 160, height: 40)
                }
            } else {
                return CGSize(width: 80, height: 40)
            }
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
        self.isUserInfoPopuped = true
    }
    
    func hideUserInfoView() {
        if !isUserInfoPopuped { return }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.userInfoView.alpha = 0
            self?.userInfoView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { [weak self] _ in
            self?.userInfoView.removeFromSuperview()
        }
        self.isUserInfoPopuped = false
    }
}

extension MainViewController: UserInfoPushable {
    func showUserSetting() {
        let backItem = UIBarButtonItem()
        backItem.title = "뒤로가기"
        self.navigationItem.backBarButtonItem = backItem
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: PersonalSettingViewController.identifier) 
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func showSetting() {
        let backItem = UIBarButtonItem()
        backItem.title = "뒤로가기"
        self.navigationItem.backBarButtonItem = backItem
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SettingViewController.identifier)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
