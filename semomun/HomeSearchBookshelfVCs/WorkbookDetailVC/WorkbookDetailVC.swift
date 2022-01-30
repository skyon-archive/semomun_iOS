//
//  WorkBookDetailViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import UIKit
import Combine
import Kingfisher

final class WorkbookDetailVC: UIViewController {
    static let identifier = "WorkbookDetailVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var workbookInfoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var bookCoverImageViewFrameView: UIView!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var purchaseWorkbookButton: UIButton!
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var workbookTagsCollectionView: UICollectionView!
    @IBOutlet weak var sectionListTableView: UITableView!
    
    private var isCoreData: Bool = false
    private var viewModel: WorkbookViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loader = self.makeLoaderWithoutPercentage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureTags()
        self.configureTableViewDelegate()
        self.bindAll()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.fetchWorkbook()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func addWorkbook(_ sender: Any) {
        self.viewModel?.switchPurchase()
    }
}

extension WorkbookDetailVC {
    func configureViewModel(to viewModel: WorkbookViewModel) {
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
    
    private func configureTableViewDelegate() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .showSection, object: nil, queue: .main) { [weak self] notification in
            guard let sid = notification.userInfo?["sid"] as? Int else { return }
            guard let preview = self?.viewModel?.previewCore else { return }
            guard let sectionHeader = self?.viewModel?.sectionHeaders?.first(where: { Int($0.sid) == sid }) else { return }
            if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
                self?.showSolvingVC(section: section, preview: preview, sectionHeader: sectionHeader)
                return
            }
        }
        NotificationCenter.default.addObserver(forName: .downloadSectionFail, object: nil, queue: .main) { [weak self] notification in
            self?.showAlertWithOK(title: "다운로드에 실패하였습니다", text: "네트워크 확인 후 다시 시도해주세요", completion: nil)
        }
        NotificationCenter.default.addObserver(forName: .goToLogin, object: nil, queue: .main) { [weak self] _ in
            self?.showLoginVC()
        }
        NotificationCenter.default.addObserver(forName: .goToUpdateUserinfo, object: nil, queue: .main) { [weak self] _ in
            self?.showChangeUserinfoVC()
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
        self.titleLabel.text = workbookInfo.title
        self.authorLabel.text = workbookInfo.author
        self.publisherLabel.text = workbookInfo.publisher
        self.releaseDateLabel.text = workbookInfo.releaseDate
        if self.isCoreData {
            if let imageData = workbookInfo.image {
                self.bookCoverImageView.image = UIImage(data: imageData)
            } else {
                self.bookCoverImageView.image = UIImage(named: SemomunImage.warning)
            }
        } else {
            guard let bookcoverURL = workbookInfo.imageURL,
                  let url = URL(string: NetworkURL.bookcoverImageDirectory(.large) + bookcoverURL) else { return }
            self.bookCoverImageView.kf.setImage(with: url)
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
        
        let backgroundView = UIView()
        backgroundView.tag = 123
        backgroundView.backgroundColor = .gray.withAlphaComponent(0.8)
        backgroundView.frame = self.view.frame
        self.view.addSubview(backgroundView)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
        self.view.isUserInteractionEnabled = true
        if let backgroundView = self.view.viewWithTag(123) {
            backgroundView.removeFromSuperview()
        }
    }
}

// MARK: - Show VC
extension WorkbookDetailVC {
    private func showSolvingVC(section: Section_Core, preview: Preview_Core, sectionHeader: SectionHeader_Core) {
        guard let solvingVC = UIStoryboard(name: "Study", bundle: nil).instantiateViewController(withIdentifier: StudyVC.identifier) as? StudyVC else { return }
        solvingVC.modalPresentationStyle = .fullScreen
        solvingVC.sectionCore = section
        solvingVC.previewCore = preview
        solvingVC.sectionHeaderCore = sectionHeader
        self.present(solvingVC, animated: true, completion: nil)
    }
    
    private func showPopupVC(type: WorkbookViewModel.PopupType) {
        print(type)
        switch type {
        case .login, .updateUserinfo:
            let storyboard = UIStoryboard(name: PurchaseWarningPopupVC.storyboardName, bundle: nil)
            guard let popupVC = storyboard.instantiateViewController(withIdentifier: PurchaseWarningPopupVC.identifier) as? PurchaseWarningPopupVC else { return }
            popupVC.configureWarning(type: type == .login ? .login : .updateUserinfo)
            self.present(popupVC, animated: true, completion: nil)
        case .chargeMoney, .purchase:
//            let storyboard = UIStoryboard(name: PurchasePopupVC.storyboardName, bundle: nil)
            print("none")
        }
    }
    
    private func showChangeUserinfoVC() {
        let storyboard = UIStoryboard(name: ChangeUserinfoPopupVC.storyboardName, bundle: nil)
        let changeUserinfoVC = storyboard.instantiateViewController(withIdentifier: ChangeUserinfoPopupVC.identifier)
        self.navigationController?.pushViewController(changeUserinfoVC, animated: true)
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
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning, text: "", completion: nil)
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
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
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
}

// MARK: - CollectionView
extension WorkbookDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WorkbookTagCell.identifier, for: indexPath) as? WorkbookTagCell else { return UICollectionViewCell() }
        guard let tag = self.viewModel?.tag(idx: indexPath.item) else { return  cell }
        cell.configure(tag: tag)
        
        return cell
    }
}

extension WorkbookDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tag = self.viewModel?.tag(idx: indexPath.item) else { return CGSize(width: 100, height: 30) }
        return CGSize(width: "#\(tag)".size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)]).width + 20, height: 30)
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
            guard let sectionHeader = self.viewModel?.sectionHeader(idx: indexPath.row) else { return cell }
            cell.configureCell(sectionHeader: sectionHeader, idx: indexPath.row)
        } else {
            guard let sectionDTO = self.viewModel?.sectionDTO(idx: indexPath.row) else { return cell }
            cell.configureCell(sectionDTO: sectionDTO, idx: indexPath.row)
        }
        
        return cell
    }
}
