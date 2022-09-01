//
//  HomeVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit
import Combine

/// - Note: HomeSectionView들의 태그값은 UIStackView내에서의 순서와 같다(zero-based)
final class HomeVC: UIViewController {
    /* private */
    /// 고정된 섹션 종류. 각 case의 rawValue는 대응되는 collectionview의 태그값과 같다.
    private enum FixedSectionType: Int, CaseIterable {
        case bestseller
        case recent
        case tag
    }
    private var fixedSectionViews: [FixedSectionType: HomeSectionView] = [:]
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
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40
        
        return stackView
    }()
    private let roundedBackground: UIView = {
        let roundedBackground = UIView()
        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.configureTopCorner(radius: .cornerRadius24)
        roundedBackground.backgroundColor = UIColor.getSemomunColor(.white)
        
        return roundedBackground
    }()
    private var viewModel: HomeVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.getSemomunColor(.background)
        // 레이아웃 설정
        self.configureHomeHeaderViewLayout()
        self.configureScrollViewLayout()
        self.configureScrollViewBackgroundLayout()
        self.configureStackViewLayout()
        
        self.configureViewModel()
        self.configureFixedSection()
        self.configureAddObserver()
        
        self.bindAll()
        self.viewModel?.checkLogined()
        self.viewModel?.checkMigration()
        self.viewModel?.checkNetworkStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.checkVersion()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(
            alongsideTransition: { [weak self] _ in
                self?.fixedSectionViews.values.forEach {
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
            // 아래방향 스크롤 overflow가 일어나도 흰색 배경이 보이도록 여백 설정
            self.roundedBackground.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: 1000),
            self.roundedBackground.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.roundedBackground.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: self.roundedBackground.widthAnchor),
        ])
    }
    
    private func configureStackViewLayout() {
        self.roundedBackground.addSubview(self.stackView)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor, constant: 40),
            self.stackView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor),
            // configureScrollViewBackgroundLayout에서 설정한 여백 값만큼 아래 여백을 설정
            self.stackView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor, constant: -UICollectionView.gridPadding-1000),
            self.stackView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor, constant: 0),
        ])
    }
}

// MARK: Configure StackView
extension HomeVC {
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
            }
            
            sectionView.configureContent(
                collectionViewTag: sectionType.rawValue,
                delegate: self,
                title: sectionTitle
            )
            sectionView.configureSeeAllAction { [weak self] in
                self?.showHomeDetailVC(sectionType: sectionType)
            }
            
            self.fixedSectionViews[sectionType] = sectionView
        }
    }
    
    /// UIStackView 내에 HomeVCSectionView를 레이아웃에 맞게 추가
    private func addSectionToStackView(_ sectionView: HomeSectionView) {
        self.stackView.addArrangedSubview(sectionView)
        sectionView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
    }
    
    private func showHomeDetailVC(sectionType: FixedSectionType) {
        guard let viewModel = self.viewModel,
              let sectionTitle = self.fixedSectionViews[sectionType]?.title else {
            return
        }
        
        switch sectionType {
        case .bestseller:
            let vm = HomeDetailVM<WorkbookPreviewOfDB>(
                networkUsecase: viewModel.networkUsecase,
                cellDataFetcher: { viewModel.fetchBestSellers(page: $0, completion: $2) }
            )
            let vc = HomeDetailVC<WorkbookPreviewOfDB>(viewModel: vm, title: sectionTitle)
            self.navigationController?.pushViewController(vc, animated: true)
        case .recent:
            self.tabBarController?.selectedIndex = 2
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                NotificationCenter.default.post(name: .showRecentWorkbooks, object: nil)
            }
        case .tag:
            let vm = HomeUserTagDetailVM(
                networkUsecase: viewModel.networkUsecase,
                cellDataFetcher: viewModel.fetchTags
            )
            let vc = HomeUserTagDetailVC(viewModel: vm, title: sectionTitle)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeVC {
    private func configureViewModel() {
        let networkUsecase = NetworkUsecase(network: Network())
        self.viewModel = HomeVM(networkUsecase: networkUsecase)
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .main) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        }
        NotificationCenter.default.addObserver(forName: .tokenExpired, object: nil, queue: .main) { [weak self] _ in
            self?.showAlertWithOK(title: "세션이 만료되었습니다.", text: "다시 로그인 해주시기 바랍니다.") {
                LogoutUsecase.logout()
                NotificationCenter.default.post(name: .showLoginStartVC, object: nil)
            }
        }
    }
}

extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionType = FixedSectionType(rawValue: collectionView.tag) { // 고정 섹션
            switch sectionType {
            case .bestseller:
                return self.viewModel?.bestSellers.count ?? 0
            case .recent:
                return self.viewModel?.recentEntered.count ?? 0
            case .tag:
                return self.viewModel?.workbooksWithTags.count ?? 0
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            }
        } else { // 인기 태그 섹션들
            return cell
        }
        
        return cell
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            }
        }
    }
    
    private func searchWorkbook(wid: Int) {
        if UserDefaultsManager.isLogined, let book = CoreUsecase.fetchPreview(wid: wid) {
            self.showWorkbookDetailVC(workbookCore: book)
        } else {
            self.viewModel?.fetchWorkbook(wid: wid)
        }
    }
}

// MARK: Navigation 관련
extension HomeVC {
    private func showSearchTagVC() {
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = SearchTagVM(networkUsecase: networkUsecase)
        let searchTagVC = SearchTagVC(viewModel: viewModel, mode: .home)
        self.present(searchTagVC, animated: true, completion: nil)
    }
}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UICollectionView.bookcoverCellSize
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
        self.warningOfflineView.backgroundColor = .white
        self.view.addSubview(self.warningOfflineView)
        NSLayoutConstraint.activate([
            self.warningOfflineView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
            self.warningOfflineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.warningOfflineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.warningOfflineView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.scrollView.isHidden = true
    }
    
    private func hideOfflineAlert() {
        self.warningOfflineView.removeFromSuperview()
        self.scrollView.isHidden = false
    }
}

// MARK: - Binding
extension HomeVC {
    private func bindAll() {
        self.bindBestSellers()
        self.bindRecent()
        self.bindTags()
        
        self.bindOfflineStatus()
        self.bindLogined()
        self.bindVersion()
        self.bindWarning()
        self.bindPopup()
        self.bindMigrationLoading()
        self.bindWorkbookDTO()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                let tagSectionView = self?.fixedSectionViews[.tag]
                tagSectionView?.tagList.updateTagList(tags: tags)
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
            .sink(receiveValue: { [weak self] recentEntered in
                if recentEntered.isEmpty {
                    self?.fixedSectionViews[.recent]?.isHidden = true
                } else {
                    self?.fixedSectionViews[.recent]?.isHidden = false
                    self?.fixedSectionViews[.recent]?.collectionView.reloadData()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbookDTO() {
        self.viewModel?.$workbookDTO
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookDTO in
                guard let workbookDTO = workbookDTO else { return }
                self?.showWorkbookDetailVC(workbookDTO: workbookDTO)
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
                    self?.hideOfflineAlert()
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
                        .forEach { $0.isHidden = true }
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
}
