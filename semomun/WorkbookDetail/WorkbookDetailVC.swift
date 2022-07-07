//
//  WorkBookDetailViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import UIKit
import Combine

final class WorkbookDetailVC: UIViewController, StoryboardController {
    static let identifier = "WorkbookDetailVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "HomeSearchBookshelf", .phone: "HomeSearchBookshelf_phone"]
    // topView
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publishCompanyLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var purchaseWorkbookButton: UIButton!
    @IBOutlet weak var workbookTagsCollectionView: UICollectionView!
    // tableView
    @IBOutlet weak var selectAllSectionButton: UIButton!
    @IBOutlet weak var selectedCountLabel: UILabel!
    @IBOutlet weak var deleteSectionsButton: UIButton!
    @IBOutlet weak var editSectionsButton: UIButton!
    @IBOutlet weak var sectionListTableView: UITableView!
    // tableView layout
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    private var isCoreData: Bool = false
    private var viewModel: WorkbookDetailVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    private var navigationAnimation: Bool = true
    private var editingMode: Bool = false {
        didSet {
            if editingMode == true {
                self.selectAllSectionButton.setTitle("전체 선택", for: .normal)
                self.selectedCountLabel.isHidden = false
                self.editSectionsButton.setTitle("취소", for: .normal)
                self.deleteSectionsButton.isHidden = false
                
                NotificationCenter.default.post(name: .showSectionDeleteButton, object: nil)
            } else {
                self.updateDownloadbleCount()
                
                self.selectedCountLabel.isHidden = true
                self.editSectionsButton.setTitle("편집", for: .normal)
                self.deleteSectionsButton.isHidden = true
                
                NotificationCenter.default.post(name: .hideSectionDeleteButton, object: nil)
            }
        }
    }
    private var cellAccessable: Bool {
        return self.viewModel?.downloadQueue.isEmpty ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTags()
        self.configureSections()
        self.bindAll()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.editSectionsButton.isSelected = false
        self.fetchWorkbook()
        self.navigationAnimation = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.navigationAnimation else { return }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func purchaseWorkbook(_ sender: Any) {
        self.viewModel?.switchPurchase()
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        guard self.cellAccessable == true else { return }
        self.editingMode.toggle()
    }
    
    @IBAction func deleteSections(_ sender: Any) {
        guard self.cellAccessable == true else { return }
        self.viewModel?.deleteSelectedSections()
    }
    
    @IBAction func downloadAllSections(_ sender: Any) {
        guard self.cellAccessable == true else { return }
        if self.editingMode == true {
            self.viewModel?.selectAllSectionsForDelete()
        } else {
            self.viewModel?.downloadAllSections()
        }
    }
}

extension WorkbookDetailVC {
    func configureViewModel(to viewModel: WorkbookDetailVM) {
        self.viewModel = viewModel
    }
    
    func configureIsCoreData(to: Bool) {
        self.isCoreData = to
    }
    
    private func configureUI() {
        self.selectedCountLabel.isHidden = true
        self.deleteSectionsButton.isHidden = true
        // 구매 전 UI
        guard self.isCoreData == true else {
            self.selectAllSectionButton.isHidden = true
            self.editSectionsButton.isHidden = true
            self.tableViewTopConstraint.constant = 12
            return
        }
        // 구매 후 UI
        self.purchaseWorkbookButton.isHidden = true
    }
    
    private func configureTags() {
        self.workbookTagsCollectionView.delegate = self
        self.workbookTagsCollectionView.dataSource = self
        let tagCellNib = UINib(nibName: TagCell.identifier, bundle: nil)
        self.workbookTagsCollectionView.register(tagCellNib, forCellWithReuseIdentifier: TagCell.identifier)
    }
    
    private func configureSections() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
        self.sectionListTableView.separatorInset.left = 0
    }
    
    private func updateDownloadbleCount() {
        let downloadableCount = self.viewModel?.downloadableCount ?? 0
        let downloadButtonTitle = downloadableCount > 0 ? "모두 다운로드(\(downloadableCount)개)" : ""
        self.selectAllSectionButton.setTitle(downloadButtonTitle, for: .normal)
    }
    
    private func updateDeleteableCount() {
        let deleteableCount = self.viewModel?.selectedSectionsForDelete.count ?? 0
        self.selectedCountLabel.text = "\(deleteableCount)개 선택됨"
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .goToLogin, object: nil, queue: .main) { [weak self] _ in
            self?.showLoginVC()
        }
        NotificationCenter.default.addObserver(forName: .goToUpdateUserinfo, object: nil, queue: .main) { [weak self] _ in
            self?.showChangeUserinfoVC()
        }
        NotificationCenter.default.addObserver(forName: .goToCharge, object: nil, queue: .main) { [weak self] _ in
            self?.showChargeVC()
        }
        NotificationCenter.default.addObserver(forName: .purchaseComplete, object: nil, queue: .main) { [weak self] _ in
            self?.viewModel?.purchaseWorkbook()
        }
    }
    
    private func fetchWorkbook() {
        if self.isCoreData {
            self.viewModel?.configureWorkbookInfo(isCoreData: true)
            self.viewModel?.fetchSectionHeaders()
        } else {
            self.viewModel?.configureWorkbookInfo(isCoreData: false)
            self.viewModel?.fetchSectionDTOs()
        }
    }
    
    private func configureBookInfo(workbookInfo: WorkbookInfo) {
        self.sectionTitleLabel.text = workbookInfo.title
        self.authorLabel.text = workbookInfo.author
        self.publishCompanyLabel.text = workbookInfo.publisher
        self.purchaseWorkbookButton.setTitle("\(workbookInfo.price.withComma)원", for: .normal)
        
        if let imageData = workbookInfo.imageData {
            self.bookCoverImageView.image = UIImage(data: imageData)
        } else if let uuid = workbookInfo.bookcover {
            if let cachedImage = ImageCacheManager.shared.getImage(uuid: uuid) {
                self.bookCoverImageView.image = cachedImage
            } else {
                self.viewModel?.fetchBookcoverImage(bookcover: uuid)
            }
        }
    }
    
    private func showLoader() {
        self.view.addSubview(self.loadingView)
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.loadingView.start()
    }
    
    private func removeLoader() {
        self.loadingView.stop()
        self.loadingView.removeFromSuperview()
    }
}

// MARK: - Show VC
extension WorkbookDetailVC {
    private func showStudyVC(section: Section_Core, workbook: Preview_Core, sectionHeader: SectionHeader_Core) {
        guard let studyVC = UIStoryboard(name: StudyVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StudyVC.identifier) as? StudyVC else { return }
        
        let networkUsecase = NetworkUsecase(network: Network())
        let manager = SectionManager(section: section, sectionHeader: sectionHeader, workbook: workbook, networkUsecase: networkUsecase)
        
        studyVC.modalPresentationStyle = .fullScreen
        studyVC.configureManager(manager)
        
        self.present(studyVC, animated: true, completion: nil)
    }
    
    private func showPopupVC(type: WorkbookDetailVM.PopupType) {
        switch type {
        case .login, .updateUserinfo:
            let storyboard = UIStoryboard(name: PurchaseWarningPopupVC.storyboardName, bundle: nil)
            guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchaseWarningPopupVC.identifier) as? PurchaseWarningPopupVC else { return }
            popupVC.configureWarning(type: type == .login ? .login : .updateUserinfo)
            self.present(popupVC, animated: true, completion: nil)
        case .purchase:
            let storyboard = UIStoryboard(name: PurchasePopupVC.storyboardName, bundle: nil)
            guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchasePopupVC.identifier) as? PurchasePopupVC else { return }
            guard let info = self.viewModel?.workbookDTO,
                  let credit = self.viewModel?.credit else { return }
            popupVC.configureInfo(info: info)
            popupVC.configureCurrentMoney(money: credit)
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    private func showChangeUserinfoVC() {
        let storyboard = UIStoryboard(name: ChangeUserInfoVC.storyboardName, bundle: nil)
        guard let changeUserinfoVC = storyboard.instantiateViewController(withIdentifier: ChangeUserInfoVC.identifier) as? ChangeUserInfoVC else { return }
        let viewModel = ChangeUserInfoVM(networkUseCase: NetworkUsecase(network: Network()))
        changeUserinfoVC.configureVM(viewModel)
        self.navigationController?.pushViewController(changeUserinfoVC, animated: true)
    }
    
    private func showChargeVC() {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let waitingChargeVC = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(waitingChargeVC, animated: true)
    }
}

// MARK: - Binding
extension WorkbookDetailVC {
    private func bindAll() {
        self.bindWarning()
        self.bindWorkbookInfo()
        self.bindSectionHeaders()
        self.bindSectionDTOs()
        self.bindLoader()
        self.bindPopupType()
        self.bindBookcover()
        self.bindTags()
        self.bindGoToBookshelf()
        self.bindSelectedSectionsForDelete()
        self.bindDeleteFinished()
        self.bindDownloadQueue()
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text, completion: nil)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbookInfo() {
        self.viewModel?.$workbookInfo
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookInfo in
                guard let workbookInfo = workbookInfo else { return }
                self?.updateDownloadbleCount()
                self?.configureBookInfo(workbookInfo: workbookInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionHeaders() {
        self.viewModel?.$sectionHeaders
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.updateDownloadbleCount()
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionDTOs() {
        self.viewModel?.$sectionDTOs
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLoader() {
        self.viewModel?.$showLoader
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] showLoader in
                if showLoader {
                    self?.showLoader()
                } else {
                    self?.removeLoader()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPopupType() {
        self.viewModel?.$popupType
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] type in
                guard let type = type else { return }
                self?.showPopupVC(type: type)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindBookcover() {
        self.viewModel?.$bookcoverData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let data = data else { return }
                self?.bookCoverImageView.image = UIImage(data: data)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.workbookTagsCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindGoToBookshelf() {
        self.viewModel?.$goToBookshelf
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] goToBookshelf in
                guard goToBookshelf == true else { return }
                self?.navigationController?.popViewController(animated: true) {
                    NotificationCenter.default.post(name: .purchaseBook, object: nil)
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSelectedSectionsForDelete() {
        self.viewModel?.$selectedSectionsForDelete
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateDeleteableCount()
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindDeleteFinished() {
        self.viewModel?.$deleteFinished
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] deleteFinished in
                guard deleteFinished == true else { return }
                self?.editingMode = false
            })
            .store(in: &self.cancellables)
    }
    
    private func bindDownloadQueue() {
        self.viewModel?.$downloadQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] queue in
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - CollectionView
extension WorkbookDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.tags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else { return UICollectionViewCell() }
        guard let tag = self.viewModel?.tags[indexPath.item] else { return  cell }
        cell.configure(tag: tag)
        
        return cell
    }
}

extension WorkbookDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = self.viewModel?.tags[indexPath.item] else { return CGSize(width: 100, height: 32) }
        return CGSize(width: tag.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + 32, height: 32)
    }
}

// MARK: - TableView
extension WorkbookDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.count(isCoreData: self.isCoreData) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else {
            return UITableViewCell() }
        
        if self.isCoreData {
            guard let sectionHeader = self.viewModel?.sectionHeaders[indexPath.row] else { return cell }
            
            let isSelected = self.viewModel?.selectedSectionsForDelete.contains(indexPath.row) ?? false
            cell.configureDelegate(to: self)
            cell.configureCell(sectionHeader: sectionHeader, isEditing: self.editingMode, isSelected: isSelected, index: indexPath.row)
            
            if self.cellAccessable == false, self.viewModel?.downloadQueue.first == indexPath.row {
                cell.downloadSection()
            }
        } else {
            guard let sectionDTO = self.viewModel?.sectionDTOs[indexPath.row] else { return cell }
            cell.configureCell(sectionDTO: sectionDTO)
        }
        
        return cell
    }
}

extension WorkbookDetailVC: WorkbookCellController {
    func showSection(sectionHeader: SectionHeader_Core, section: Section_Core) {
        guard self.cellAccessable == true else { return }
        
        self.navigationAnimation = false
        guard let preview = self.viewModel?.previewCore else { return }
        self.viewModel?.updateRecentDate()
        self.showStudyVC(section: section, workbook: preview, sectionHeader: sectionHeader)
    }
    
    func showAlertDownloadSectionFail() {
        self.showAlertWithOK(title: "다운로드에 실패하였습니다", text: "네트워크 확인 후 다시 시도해주세요", completion: nil)
    }
    
    func showAlertDeletePopup(sectionTitle: String?, completion: @escaping (() -> Void)) {
        let title = sectionTitle != nil ? sectionTitle! : "섹션정보 삭제"
        self.showAlertWithCancelAndOK(title: title, text: "필기와 이미지 데이터가 제거됩니다.", completion: completion)
    }
    
    func downloadSuccess(index: Int) {
        self.viewModel?.downloadSuccess(index: index)
        self.updateDownloadbleCount()
    }
    
    func selectSection(index: Int) {
        self.viewModel?.selectSection(index: index)
    }
    
    func downloadStartInSection(index: Int) {
        self.viewModel?.downloadSection(index: index)
    }
}
