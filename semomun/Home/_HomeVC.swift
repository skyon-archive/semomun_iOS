//
//  _HomeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit
import Combine

struct HomeVCSectionInfo {
    let title: String
    let onTapAction: ((IndexPath) -> ())?
    let getCellData: (IndexPath) -> (title: String, publishCompany: String?, imageUUID: UUID?, imageData: Data?)
    let numberOfCell: () -> Int
}

class _HomeVC: UIViewController {
    enum SectionDataType {
        case workbook, workbookGroup, bookshelf
    }
    enum SectionType: Int, CaseIterable {
        case bestseller
        case recent
        case tag
        case workbookGroup
        //        case popularTag1
        //        case popularTag2
    }
    private var viewModel: HomeVM?
    private var sectionViews: [SectionType: HomeVCSectionView] = [:]
    private var cancellables: Set<AnyCancellable> = []
    private lazy var sectionInfo: [SectionType: HomeVCSectionInfo] = {
        let defaultCellData: (String, String?, UUID?, Data?) = ("", nil, nil, nil)
        
        func fetchWorkbook(wid: Int, networkUsecase: NetworkUsecase) async -> WorkbookOfDB? {
            await withCheckedContinuation { continuation in
                networkUsecase.getWorkbook(wid: wid) { [weak self] workbook in
                    continuation.resume(with: .success(workbook))
                }
            }
        }
        
        return [
            .bestseller: .init(
                title: "베스트셀러",
                onTapAction: {
                    guard let wid = self.viewModel?.bestSellers[$0.item].wid else { return }
                    self.searchWorkbook(wid: wid)
                },
                getCellData: {
                    guard let preview = self.viewModel?.bestSellers[$0.item] else { return defaultCellData }
                    return (preview.title, preview.publishCompany, preview.bookcover, nil)
                },
                numberOfCell: {
                    return self.viewModel?.bestSellers.count ?? 0
                }
            ),
            .recent: .init(
                title: "최근에 푼 문제집",
                onTapAction: {
                    guard let wid = self.viewModel?.bestSellers[$0.item].wid else { return }
                    self.searchWorkbook(wid: wid)
                },
                getCellData: {
                    guard let info = self.viewModel?.recentEntered[$0.item] else { return defaultCellData }
                    return defaultCellData
                },
                numberOfCell: {
                    return self.viewModel?.recentEntered.count ?? 0
                }
            ),
            .tag: .init(
                title: "나의 태그",
                onTapAction: {
                    guard let wid = self.viewModel?.bestSellers[$0.item].wid else { return }
                    self.searchWorkbook(wid: wid)
                },
                getCellData: {
                    guard let preview = self.viewModel?.workbooksWithTags[$0.item] else { return defaultCellData }
                    return (preview.title, preview.publishCompany, preview.bookcover, nil)
                },
                numberOfCell: {
                    return self.viewModel?.workbooksWithTags.count ?? 0
                }
            ),
            .workbookGroup: .init(
                title: "실전 모의고사",
                onTapAction: {
                    guard let wid = self.viewModel?.bestSellers[$0.item].wid else { return }
                    self.searchWorkbook(wid: wid)
                },
                getCellData: { _ in
                    return defaultCellData
                },
                numberOfCell: {
                    return self.viewModel?.workbookGroups.count ?? 0
                }
            )
        ]
    }()
    
    private let headerView: HomeHeaderView = {
        let view = HomeHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    private let roundedBackground: UIView = {
        let roundedBackground = UIView()
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.configureTopCorner(radius: .cornerRadius24)
        roundedBackground.backgroundColor = UIColor.getSemomunColor(.white)
        
        return roundedBackground
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.getSemomunColor(.background)
        self.configureHomeHeaderView()
        
        self.configureScrollViewLayout()
        self.configureScrollViewBackground()
        self.configureStackViewLayout()
        
        self.configureStackViewContent()
        
        self.configureViewModel()
        self.bindAll()
    }
}

extension _HomeVC {
    private func configureHomeHeaderView() {
        self.view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    private func configureScrollViewLayout() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func configureScrollViewBackground() {
        // 위쪽 모서리가 둥근 흰색 배경 추가
        self.scrollView.addSubview(self.roundedBackground)
        
        NSLayoutConstraint.activate([
            self.roundedBackground.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.roundedBackground.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.roundedBackground.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.roundedBackground.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.roundedBackground.widthAnchor),
        ])
    }
    
    private func configureStackViewLayout() {
        self.roundedBackground.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor, constant: 32),
            self.stackView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor, constant: 32),
        ])
    }
    
    private func configureStackViewContent() {
        SectionType.allCases.forEach { sectionType in
            let sectionView = HomeVCSectionView()
            self.stackView.addArrangedSubview(sectionView)
            sectionView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
            guard let sectionInfo = self.sectionInfo[sectionType] else { return }
            sectionView.configureContent(title: sectionInfo.title, collectionViewTag: sectionType.rawValue, delegate: self, seeAllAction: { })
            self.sectionViews[sectionType] = sectionView
        }
    }
    
    private func configureViewModel() {
        let networkUsecase = NetworkUsecase(network: Network())
        self.viewModel = HomeVM(networkUsecase: networkUsecase)
    }
    
    private func searchWorkbook(wid: Int) {
        if UserDefaultsManager.isLogined, let book = CoreUsecase.fetchPreview(wid: wid) {
            self.showWorkbookDetailVC(book: book)
        } else {
            self.viewModel?.fetchWorkbook(wid: wid)
        }
    }
    
    private func searchWorkbookGroup(info: WorkbookGroupPreviewOfDB) {
        if UserDefaultsManager.isLogined, let coreInfo = CoreUsecase.fetchWorkbookGroup(wgid: info.wgid) {
            self.showWorkbookGroupDetailVC(coreInfo: coreInfo)
        } else {
            self.showWorkbookGroupDetailVC(dtoInfo: info)
        }
    }
}

// MARK: 새로운 VC 이동 관련
extension _HomeVC {
    private func showWorkbookDetailVC(workbook: WorkbookOfDB) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(workbookDTO: workbook, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: false)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showSearchTagVC() {
        let storyboard = UIStoryboard(name: SearchTagVC.storyboardName, bundle: nil)
        guard let searchTagVC = storyboard.instantiateViewController(withIdentifier: SearchTagVC.identifier) as? SearchTagVC else { return }
        
        self.present(searchTagVC, animated: true, completion: nil)
    }
    
    private func showWorkbookGroupDetailVC(dtoInfo: WorkbookGroupPreviewOfDB) {
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        let viewModel = WorkbookGroupDetailVM(dtoInfo: dtoInfo, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
    
    private func showWorkbookGroupDetailVC(coreInfo: WorkbookGroup_Core) {
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        let viewModel = WorkbookGroupDetailVM(coreInfo: coreInfo, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
}

extension _HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: collectionView.tag),
              let sectionInfo = self.sectionInfo[sectionType] else {
            return 0
        }
        
        return sectionInfo.numberOfCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookcoverCell.identifier, for: indexPath) as? BookcoverCell else { return .init() }
        
        guard let sectionType = SectionType(rawValue: collectionView.tag),
              let sectionInfo = self.sectionInfo[sectionType],
              let networkUsecase = self.viewModel?.networkUsecase else {
            return cell
        }
        
        let cellData = sectionInfo.getCellData(indexPath)
        cell.configureReuse(bookTitle: cellData.title, publishCompany: cellData.publishCompany)
        if let uuid = cellData.imageUUID {
            cell.configureImage(uuid: uuid, networkUsecase: networkUsecase)
        } else if let data = cellData.imageData {
            cell.configureImage(data: data)
        }
        
        return cell
    }
}

extension _HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UICollectionView.bookcoverCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UICollectionView.gutterWidth
    }
}

// MARK: - Binding
extension _HomeVC {
    private func bindAll() {
        self.bindTags()
        self.bindAds()
        self.bindBestSellers()
        self.bindRecent()
        self.bindWorkbookDTO()
        self.bindOfflineStatus()
        self.bindLogined()
        self.bindVersion()
        self.bindWarning()
        self.bindPopup()
        self.bindMigrationLoading()
        self.bindPracticeTests()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                //                self?.configureTags(with: tags.map(\.name))
            })
            .store(in: &self.cancellables)
        
        self.viewModel?.$workbooksWithTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.sectionViews[.tag]?.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindAds() {
        self.viewModel?.$banners
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] banners in
                //                guard banners.isEmpty == false else { return }
                //                self?.configureBannerAdsStartIndex()
                //                self?.bannerAds.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindBestSellers() {
        self.viewModel?.$bestSellers
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.sectionViews[.bestseller]?.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindRecent() {
        self.viewModel?.$recentEntered
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.sectionViews[.recent]?.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbookDTO() {
        self.viewModel?.$workbookDTO
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookDTO in
                guard let workbookDTO = workbookDTO else { return }
                self?.showWorkbookDetailVC(workbook: workbookDTO)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindOfflineStatus() {
        self.viewModel?.$offlineStatus
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] offline in
                //                if offline {
                //                    self?.showOfflineAlert()
                //                } else {
                //                    self?.warningOfflineView.removeFromSuperview()
                //                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLogined() {
        self.viewModel?.$logined
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] logined in
                //                if logined == false {
                //                    self?.configureLoginTextView()
                //                } else {
                //                    self?.noLoginedLabel1.removeFromSuperview()
                //                    self?.noLoginedLabel2.removeFromSuperview()
                //                    self?.recentEnteredHeight.constant = UIDevice.current.userInterfaceIdiom == .phone ? 200 : 232
                //                    self?.recentPurchasedHeight.constant = UIDevice.current.userInterfaceIdiom == .phone ? 200 : 232
                //                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindVersion() {
        self.viewModel?.$updateToVersion
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] version in
                guard let version = version else { return }
                self?.showAlertWithOK(title: "업데이트 후 사용해주세요", text: "앱스토어의 \(version) 버전을 다운받아주세요") {
                    if let url = URL(string: NetworkURL.appstore),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            exit(0)
                        }
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPopup() {
        self.viewModel?.$popupURL
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] url in
                guard let url = url else { return }
                let noticeVC = NoticePopupVC(url: url)
                self?.present(noticeVC, animated: true)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindMigrationLoading() {
        self.viewModel?.$isMigration
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    //                    self?.showLoader()
                } else {
                    //                    self?.removeLoader()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPracticeTests() {
        self.viewModel?.$workbookGroups
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.sectionViews[.workbookGroup]?.reloadData()
            })
            .store(in: &self.cancellables)
    }
}


class HomeHeaderView: UIView {
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        // 임시 코드
        view.image = UIImage(.cloudDownloadOutline)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 48),
            view.heightAnchor.constraint(equalToConstant: 38.99),
        ])
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.text = "세모문"
        label.textColor = UIColor.getSemomunColor(.blueRegular)
        
        return label
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading5
        label.text = "반가워요:)\n오늘도 함께 공부해봐요"
        label.numberOfLines = 2
        label.textAlignment = .right
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        self.addSubviews(self.logoImageView, self.titleLabel, self.greetingLabel)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 66),
            
            self.logoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.logoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.logoImageView.trailingAnchor, constant: 12),
            
            self.greetingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.greetingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
}

class HomeVCSectionView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading2
        label.textColor = UIColor.getSemomunColor(.black)
        
        return label
    }()
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .heading5
        button.setTitleColor(UIColor.getSemomunColor(.orangeRegular), for: .normal)
        button.setTitle("모두 보기", for: .normal)
        
        return button
    }()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(BookcoverCell.self, forCellWithReuseIdentifier: BookcoverCell.identifier)
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContent(title: String, collectionViewTag: Int, delegate: (UICollectionViewDelegate & UICollectionViewDataSource), seeAllAction: @escaping () -> Void) {
        self.titleLabel.text = title
        self.collectionView.tag = collectionViewTag
        self.collectionView.dataSource = delegate
        self.collectionView.delegate = delegate
        self.seeAllButton.addAction(UIAction { _ in seeAllAction() }, for: .touchUpInside)
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    private func configureLayout() {
        self.addSubviews(self.titleLabel, self.seeAllButton, self.collectionView)
        
        NSLayoutConstraint.activate([
            // 29는 섹션 타이틀 높이, 16은 타이틀에서 UICollectionView까지의 거리
            self.heightAnchor.constraint(equalToConstant: 29+16+UICollectionView.bookcoverCellSize.height),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            self.seeAllButton.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            self.seeAllButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            
            self.collectionView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 16),
            self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
    }
}
