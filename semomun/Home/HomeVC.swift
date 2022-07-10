//
//  HomeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit
import Combine

/// - Note: HomeSectionView들의 태그값은 UIStackView내에서의 순서와 같다(zero-based)
class HomeVC: UIViewController {
    /* private */
    /// 고정된 섹션 종류. 각 case의 rawValue는 대응되는 collectionview의 태그값과 같다.
    private enum FixedSectionType: Int, CaseIterable {
        case bestseller
        case recent
        case tag
        case workbookGroup
    }
    private var fixedSectionViews: [FixedSectionType: HomeSectionView] = [:]
    /// FixedSection 뒤로 이어지는 인기 태그 관련 섹션들의 배열
    private var popularTagSectionViews: [HomeSectionView] = []
    private var viewModel: HomeVM?
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var warningOfflineView: WarningOfflineStatusView = {
        let view = WarningOfflineStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private var cancellables: Set<AnyCancellable> = []
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
    private let bannerAdCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(HomeAdCell.self, forCellWithReuseIdentifier: HomeAdCell.identifier)
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: UICollectionView.gridPadding, bottom: 0, right: 0)
        
        return view
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
        // 레이아웃 설정
        self.configureHomeHeaderViewLayout()
        self.configureScrollViewLayout()
        self.configureScrollViewBackgroundLayout()
        self.configureBannerAdLayout()
        self.configureStackViewLayout()
        // VM 설정
        self.configureViewModel()
        self.bindAll()
        self.viewModel?.checkLogined()
        self.viewModel?.checkVersion()
        self.viewModel?.checkMigration()
        
        self.configureBannerAd()
        self.configureStackViewContent()
        self.configureAddObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.checkVersion()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.fixedSectionViews.values.forEach {
                    $0.collectionView.collectionViewLayout.invalidateLayout()
                }
                self?.popularTagSectionViews.forEach {
                    $0.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        )
    }
}

// MARK: Configure AutoLayout
extension HomeVC {
    private func configureHomeHeaderViewLayout() {
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
    
    private func configureScrollViewBackgroundLayout() {
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
    
    private func configureBannerAdLayout() {
        self.roundedBackground.addSubview(self.bannerAdCollectionView)
        
        NSLayoutConstraint.activate([
            self.bannerAdCollectionView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor, constant: 32),
            self.bannerAdCollectionView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor, constant: 0),
            self.bannerAdCollectionView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor, constant: 0),
            self.bannerAdCollectionView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func configureStackViewLayout() {
        self.roundedBackground.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.bannerAdCollectionView.bottomAnchor, constant: 40),
            self.stackView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor, constant: -32),
            self.stackView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor, constant: 0),
        ])
    }
}

// MARK: Configure StackView
extension HomeVC {
    private func configureStackViewContent() {
        self.configureFixedSection()
        self.configurePopularTagSection()
    }
    
    private func configureFixedSection() {
        FixedSectionType.allCases.forEach { sectionType in
            let sectionView = HomeSectionView(hasTagList: sectionType == .tag)
            self.addSectionToStackView(sectionView)
            
            // 나의 태그 섹션인 경우 태그 수정 버튼 액션 추가
            if sectionType == .tag {
                sectionView.tagList.configureEditButtonAction { [weak self] in
                    self?.showSearchTagVC()
                }
            }
            
            let sectionTitle: String
            switch sectionType {
                case .bestseller: sectionTitle = "베스트셀러"
                case .recent: sectionTitle = "최근에 푼 문제집"
                case .tag: sectionTitle = "나의 태그"
                case .workbookGroup: sectionTitle = "실전 모의고사"
            }
            
            // MARK: 모두 보기 관련 로직 없음
            sectionView.configureContent(
                collectionViewTag: sectionType.rawValue,
                delegate: self,
                seeAllAction: { },
                title: sectionTitle
            )
            
            self.fixedSectionViews[sectionType] = sectionView
        }
    }
    
    /// - Warning: ViewModel이 필요한 메소드
    private func configurePopularTagSection() {
        guard let viewModel = self.viewModel else { return }
        self.popularTagSectionViews = (0..<viewModel.popularTagSectionCount).map { idx in
            let sectionView = HomeSectionView(hasTagList: false)
            self.addSectionToStackView(sectionView)
            
            // 인기 태그 섹션의 태그값 = 상단에 있는 고정 섹션들의 개수 + 인기태그들 사이에서 섹션이 가지는 인덱스
            let tag = FixedSectionType.allCases.count + idx
            sectionView.configureContent(
                collectionViewTag: tag,
                delegate: self,
                seeAllAction: { }
            )
            
            return sectionView
        }
    }
    
    /// UIStackView 내에 HomeVCSectionView를 레이아웃에 맞게 추가
    private func addSectionToStackView(_ sectionView: HomeSectionView) {
        self.stackView.addArrangedSubview(sectionView)
        sectionView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
    }
}

extension HomeVC {
    private func configureBannerAd() {
        self.bannerAdCollectionView.delegate = self
        self.bannerAdCollectionView.dataSource = self
    }
    
    private func configureViewModel() {
        let networkUsecase = NetworkUsecase(network: Network())
        self.viewModel = HomeVM(networkUsecase: networkUsecase)
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .main) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        }
        NotificationCenter.default.addObserver(forName: .goToBookShelf, object: nil, queue: .main) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        }
        NotificationCenter.default.addObserver(forName: .tokenExpired, object: nil, queue: .main) { [weak self] _ in
            self?.showAlertWithOK(title: "세션이 만료되었습니다.", text: "다시 로그인 해주시기 바랍니다.") {
                LogoutUsecase.logout()
                NotificationCenter.default.post(name: .logout, object: nil)
            }
        }
    }
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView != self.bannerAdCollectionView else {
            return self.viewModel?.banners.count ?? 0
        }
        
        if let sectionType = FixedSectionType(rawValue: collectionView.tag) { // 고정 섹션
            switch sectionType {
            case .bestseller:
                return self.viewModel?.bestSellers.count ?? 0
            case .recent:
                return self.viewModel?.recentEntered.count ?? 0
            case .tag:
                return self.viewModel?.workbooksWithTags.count ?? 0
            case .workbookGroup:
                return self.viewModel?.workbookGroups.count ?? 0
            }
        } else { // 인기 태그 섹션들
            let tagSectionIndex = collectionView.tag - FixedSectionType.allCases.count
            let tagContent = self.viewModel?.popularTagContents[safe: tagSectionIndex]
            return tagContent?.content.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 광고 배너
        guard collectionView != self.bannerAdCollectionView else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAdCell.identifier, for: indexPath) as? HomeAdCell else { return UICollectionViewCell() }
            guard let count = self.viewModel?.banners.count else { return cell }
            guard let banner = self.viewModel?.banners[indexPath.item % count] else { return cell }
            
            cell.configureContent(imageURL: banner.image, url: banner.url)
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBookcoverCell.identifier, for: indexPath) as? HomeBookcoverCell else { return .init() }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return cell }
        
        if let sectionType = FixedSectionType(rawValue: collectionView.tag) { // 고정 섹션
            switch sectionType {
            case .bestseller:
                guard let preview = self.viewModel?.bestSellers[indexPath.item] else { return cell }
                cell.configure(with: preview, networkUsecase: networkUsecase)
            case .recent:
                guard let info = self.viewModel?.recentEntered[indexPath.item] else { return cell }
                cell.configure(with: info, networkUsecase: networkUsecase)
            case .tag:
                guard let preview = self.viewModel?.workbooksWithTags[indexPath.item] else { return cell }
                cell.configure(with: preview, networkUsecase: networkUsecase)
            case .workbookGroup:
                guard let info = self.viewModel?.workbookGroups[indexPath.item] else { return cell }
                cell.configure(with: info, networkUsecase: networkUsecase)
            }
        } else { // 인기 태그 섹션들
            let tagSectionIndex = collectionView.tag - FixedSectionType.allCases.count
            guard let tagContent = self.viewModel?.popularTagContents[safe: tagSectionIndex] else { return cell }
            let content = tagContent.content[indexPath.item]
            cell.configure(with: content, networkUsecase: networkUsecase)
        }
        
        return cell
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 광고 배너
        guard collectionView != self.bannerAdCollectionView else { return }
        
        if let sectionType = FixedSectionType(rawValue: collectionView.tag) { // 고정 섹션
            switch sectionType {
            case .bestseller:
                guard let wid = self.viewModel?.bestSellers[indexPath.item].wid else { return }
                self.searchWorkbook(wid: wid)
            case .tag:
                guard let wid = self.viewModel?.workbooksWithTags[indexPath.item].wid else { return }
                self.searchWorkbook(wid: wid)
            case .recent:
                guard let wid = self.viewModel?.recentEntered[indexPath.item].wid else { return }
                self.searchWorkbook(wid: wid)
            case .workbookGroup:
                guard let info = self.viewModel?.workbookGroups[indexPath.item] else { return }
                self.searchWorkbookGroup(info: info)
            }
        } else { // 인기 태그 섹션들
            let popularTagSectionIndex = collectionView.tag - FixedSectionType.allCases.count
            guard let wid = self.viewModel?.popularTagContents[popularTagSectionIndex].content[indexPath.item].wid else { return }
            self.searchWorkbook(wid: wid)
        }
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

// MARK: Navigation 관련
extension HomeVC {
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

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.bannerAdCollectionView {
            // BookcoverCell 두개 크기
            return .init((UICollectionView.bookcoverCellSize.width*2)+UICollectionView.gutterWidth, 64)
        } else {
            return UICollectionView.bookcoverCellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UICollectionView.gutterWidth
    }
}

// MARK: Loading/Alert
extension HomeVC {
    private func showLoader() {
        self.view.addSubview(self.loadingView)
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
    
    private func showOfflineAlert() {
        self.view.addSubview(self.warningOfflineView)
        NSLayoutConstraint.activate([
            self.warningOfflineView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.warningOfflineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.warningOfflineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.warningOfflineView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

// MARK: - Binding
extension HomeVC {
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
        self.bindPopularTagContent()
    }
    
    private func bindAds() {
        self.viewModel?.$banners
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] banners in
                self?.bannerAdCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                let tagSectionView = self?.fixedSectionViews[.tag]
                tagSectionView?.tagList.updateTagList(tagNames: tags.map(\.name))
            })
            .store(in: &self.cancellables)
        
        self.viewModel?.$workbooksWithTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.fixedSectionViews[.tag]?.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindBestSellers() {
        self.viewModel?.$bestSellers
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.fixedSectionViews[.bestseller]?.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindRecent() {
        self.viewModel?.$recentEntered
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.fixedSectionViews[.recent]?.collectionView.reloadData()
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
                if offline {
                    self?.showOfflineAlert()
                } else {
                    self?.warningOfflineView.removeFromSuperview()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindLogined() {
        self.viewModel?.$logined
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] logined in
                let changingSections: [FixedSectionType] = [.recent, .tag]
                if logined {
                    changingSections
                        .compactMap { self?.fixedSectionViews[$0] }
                        .forEach { $0.isHidden = false }
                } else {
                    changingSections
                        .compactMap { self?.fixedSectionViews[$0] }
                        .forEach { sectionView in
                            sectionView.isHidden = true
                        }
                }
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
                    self?.showLoader()
                } else {
                    self?.removeLoader()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPracticeTests() {
        self.viewModel?.$workbookGroups
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.fixedSectionViews[.workbookGroup]?.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPopularTagContent() {
        self.viewModel?.$updatedPopularTagIndex
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] idx in
                guard let idx = idx,
                      let sectionView = self?.popularTagSectionViews[safe: idx],
                      let sectionName = self?.viewModel?.popularTagContents[safe: idx]?.tagName else {
                    return
                }
                
                sectionView.configureTitle(to: sectionName)
                sectionView.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
}
