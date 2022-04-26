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
    
    @IBOutlet weak var workbookInfoView: UIView!
    @IBOutlet weak var bookCoverImageViewFrameView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var purchaseWorkbookButton: UIButton!
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var workbookTagsCollectionView: UICollectionView!
    @IBOutlet weak var workbookInfosCollectionView: UICollectionView!
    @IBOutlet weak var sectionListTableView: UITableView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var editSectionsButton: UIButton!
    
    private var isCoreData: Bool = false
    private var viewModel: WorkbookDetailVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loader = self.makeLoaderWithoutPercentage()
    private var navigationAnimation: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTags()
        self.configureInfos()
        self.configureTableViewDelegate()
        self.bindAll()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchWorkbook()
        self.navigationAnimation = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard self.navigationAnimation else { return }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
        self.viewModel?.switchPurchase()
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        self.editSectionsButton.isSelected.toggle()
        self.sectionListTableView.reloadData()
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
        self.configureShadow()
        self.configureLoader()
        
        if self.isCoreData {
            self.purchaseWorkbookButton.isHidden = true
        } else {
            self.editSectionsButton.isHidden = true
        }
    }
    
    private func configureShadow() {
        self.bookCoverImageViewFrameView.layer.shadowOpacity = 0.25
        self.bookCoverImageViewFrameView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bookCoverImageViewFrameView.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.bookCoverImageViewFrameView.layer.shadowRadius = 5
        
        self.workbookInfoView.layer.shadowOpacity = 0.35
        self.workbookInfoView.layer.shadowColor = UIColor.lightGray.cgColor
        self.workbookInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.workbookInfoView.layer.shadowRadius = 7
    }
    
    private func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        self.loader.layer.zPosition = CGFloat.greatestFiniteMagnitude
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureTags() {
        self.workbookTagsCollectionView.delegate = self
        self.workbookTagsCollectionView.dataSource = self
    }
    
    private func configureInfos() {
        self.workbookInfosCollectionView.delegate = self
        self.workbookInfosCollectionView.dataSource = self
    }
    
    private func configureTableViewDelegate() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
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
        self.title = workbookInfo.title
        self.purchaseWorkbookButton.setTitle("\(workbookInfo.price.withComma)원 구매하기", for: .normal)
        
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
    
    private func configureSectionNumber() {
        guard let sectionCount = self.viewModel?.count(isCoreData: self.isCoreData) else { return }
        self.sectionNumberLabel.text = "총 \(sectionCount)단원"
    }
    
    private func startLoader() {
        self.loader.isHidden = false
        self.loader.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
}

// MARK: - Show VC
extension WorkbookDetailVC {
    private func showSolvingVC(section: Section_Core, preview: Preview_Core, sectionHeader: SectionHeader_Core) {
        guard let solvingVC = UIStoryboard(name: StudyVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: StudyVC.identifier) as? StudyVC else { return }
        solvingVC.modalPresentationStyle = .fullScreen
        solvingVC.sectionCore = section
        solvingVC.sectionHeaderCore = sectionHeader
        solvingVC.previewCore = preview
        
        self.present(solvingVC, animated: true, completion: nil)
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
        self.bindInfos()
        self.bindSectionHeaders()
        self.bindSectionDTOs()
        self.bindLoader()
        self.bindPopupType()
        self.bindBookcover()
        self.bindTags()
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
                self?.configureBookInfo(workbookInfo: workbookInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindInfos() {
        self.viewModel?.$workbookCellInfos
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.workbookInfosCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionHeaders() {
        self.viewModel?.$sectionHeaders
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.configureSectionNumber()
                self?.sectionListTableView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionDTOs() {
        self.viewModel?.$sectionDTOs
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.configureSectionNumber()
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
                    self?.startLoader()
                } else {
                    self?.stopLoader()
                    self?.navigationController?.popViewController(animated: true) {
                        NotificationCenter.default.post(name: .purchaseBook, object: nil)
                    }
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
}

// MARK: - CollectionView
extension WorkbookDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.workbookInfosCollectionView {
            return self.viewModel?.workbookCellInfos.count ?? 0
        } else {
            return self.viewModel?.tags.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.workbookInfosCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkbookInfoCell.identifier, for: indexPath) as? WorkbookInfoCell else { return UICollectionViewCell() }
            guard let info = self.viewModel?.workbookCellInfos[indexPath.item] else { return cell }
            cell.configure(title: info.title, text: info.text)
            if indexPath.item == 0 {
                cell.hideSeparator()
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkbookTagCell.identifier, for: indexPath) as? WorkbookTagCell else { return UICollectionViewCell() }
            guard let tag = self.viewModel?.tags[indexPath.item] else { return  cell }
            cell.configure(tag: tag)
            
            return cell
        }
    }
}

extension WorkbookDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.workbookInfosCollectionView {
            let superWidth = self.workbookInfosCollectionView.bounds.width
            return CGSize(width: superWidth/5, height: 68)
        } else {
            guard let tag = self.viewModel?.tags[indexPath.item] else { return CGSize(width: 100, height: 30) }
            return CGSize(width: "#\(tag)".size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]).width + 20, height: 30)
        }
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
            let isEditing = self.editSectionsButton.isSelected
            cell.configureDelegate(to: self)
            cell.configureCell(sectionHeader: sectionHeader, isEditing: isEditing)
        } else {
            guard let sectionDTO = self.viewModel?.sectionDTOs[indexPath.row] else { return cell }
            cell.configureCell(sectionDTO: sectionDTO)
        }
        
        return cell
    }
}

protocol WorkbookCellController: AnyObject {
    func showSection(sid: Int)
    func showAlertDownloadSectionFail()
    func showAlertDeletePopup(sectionTitle: String?, completion: @escaping (() -> Void))
}

extension WorkbookDetailVC: WorkbookCellController {
    func showSection(sid: Int) {
        self.navigationAnimation = false
        guard let preview = self.viewModel?.previewCore else { return }
        guard let sectionHeader = self.viewModel?.sectionHeaders.first(where: { Int($0.sid) == sid }) else { return }
        if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
            self.viewModel?.updateRecentDate()
            self.showSolvingVC(section: section, preview: preview, sectionHeader: sectionHeader)
        }
    }
    
    func showAlertDownloadSectionFail() {
        self.showAlertWithOK(title: "다운로드에 실패하였습니다", text: "네트워크 확인 후 다시 시도해주세요", completion: nil)
    }
    
    func showAlertDeletePopup(sectionTitle: String?, completion: @escaping (() -> Void)) {
        let title = sectionTitle != nil ? sectionTitle! : "섹션정보 삭제"
        self.showAlertWithCancelAndOK(title: title, text: "필기와 이미지 데이터가 제거됩니다.", completion: completion)
    }
}
