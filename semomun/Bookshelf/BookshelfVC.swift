//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class BookshelfVC: UIViewController {
    enum Tab: Int {
        case home = 0
        case workbook = 1
        case practiceTest = 2
    }
    /* public */
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet var bookshelfTabButtons: [UIButton]!
    @IBOutlet var bookshelfTabUnderlines: [UIView]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    private var currentTab: Tab = .home {
        didSet {
            self.changeTabUI()
            self.collectionView.reloadData() // section 개수 변동
            if currentTab == .home {
                self.viewModel?.refresh(tab: .home) // home order 반영
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
        self.viewModel?.refresh(tab: .home)
        self.viewModel?.fetchBookshelf()
        self.configureObservation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard self.collectionView != nil else { return }
        guard self.currentTab == .home else {
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func changeTab(_ sender: UIButton) {
        self.currentTab = Tab(rawValue: sender.tag) ?? .home
    }
}

extension BookshelfVC {
    private func configureCollectionView() {
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.configureDefaultDesign()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(BookshelfCell.self, forCellWithReuseIdentifier: BookshelfCell.identifier)
        
        let homeHeaderNib = UINib(nibName: BookshelfHomeHeaderView.identifier, bundle: nil)
        let detailHeaderNib = UINib(nibName: BookshelfDetailHeaderView.identifier, bundle: nil)
        self.collectionView.register(homeHeaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookshelfHomeHeaderView.identifier)
        self.collectionView.register(detailHeaderNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BookshelfDetailHeaderView.identifier)
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = BookshelfVM(networkUsecse: networkUsecase)
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .current) { [weak self] _ in
            self?.viewModel?.reloadWorkbooks()
            self?.viewModel?.reloadWorkbookGroups()
            self?.viewModel?.fetchBookshelf()
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .current) { [weak self] _ in
            self?.viewModel?.reloadWorkbooks()
            self?.viewModel?.reloadWorkbookGroups()
            self?.viewModel?.fetchBookshelf()
        }
    }
}

extension BookshelfVC {
    private func bindAll() {
        self.bindWorkbooksForRecent()
        self.bindWorkbooks()
        self.bindWorkbookGroups()
        self.bindWarning()
    }
    /// Home : 최근에 푼 문제집 섹션 표시용
    private func bindWorkbooksForRecent() {
        self.viewModel?.$workbooksForRecent
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbooks in
                guard self?.currentTab == .home else { return }
                let count = min(workbooks.count, UICollectionView.columnCount)
                let indexes = (0..<count).map { IndexPath(row: $0, section: 0) }
                UIView.performWithoutAnimation {
                    self?.collectionView.reloadItems(at: indexes)
                }
            })
            .store(in: &self.cancellables)
    }
    /// Home : 최근에 구매한 문제집 섹션 표시용
    /// Detail : 문제집 탭 표시용
    /// Detail : 최근에 구매한 문제집 모두보기 표시용
    private func bindWorkbooks() {
        self.viewModel?.$workbooks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbooks in
                var count = 0
                var section: Int = 0
                switch self?.currentTab {
                case .home:
                    section = 1
                    count = min(workbooks.count, UICollectionView.columnCount)
                case .workbook:
                    section = 0
                    count = workbooks.count
                default: return
                }
                let indexes = (0..<count).map { IndexPath(row: $0, section: section) }
                UIView.performWithoutAnimation {
                    self?.collectionView.reloadItems(at: indexes)
                }
            })
            .store(in: &self.cancellables)
    }
    
    /// Home: 실전 모의고사 섹션 표시용
    /// Detail : 실전 모의고사 탭 표시용
    /// Detail : 실전 모의고사 모두보기 표시용
    private func bindWorkbookGroups() {
        self.viewModel?.$workbookGroups
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookGroups in
                var count = 0
                var section: Int = 0
                switch self?.currentTab {
                case .home:
                    section = 2
                    count = min(workbookGroups.count, UICollectionView.columnCount)
                case .practiceTest:
                    section = 0
                    count = workbookGroups.count
                default: return
                }
                let indexes = (0..<count).map { IndexPath(row: $0, section: section) }
                UIView.performWithoutAnimation {
                    self?.collectionView.reloadItems(at: indexes)
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
}

extension BookshelfVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.currentTab {
        case .home: return 3
        default: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.currentTab == .home {
                return min(self.viewModel?.workbooksForRecent.count ?? 0, UICollectionView.columnCount)
            } else if self.currentTab == .workbook {
                return self.viewModel?.workbooks.count ?? 0
            } else if self.currentTab == .practiceTest {
                return self.viewModel?.workbookGroups.count ?? 0
            } else {
                assertionFailure("numberOfItemsInSection Error")
                return 0
            }
        case 1:
            guard self.currentTab == .home else {
                assertionFailure("numberOfItemsInSection Error")
                return 0
            }
            return min(self.viewModel?.workbooks.count ?? 0, UICollectionView.columnCount)
        case 2:
            guard self.currentTab == .home else {
                assertionFailure("numberOfItemsInSection Error")
                return 0
            }
            return min(self.viewModel?.workbookGroups.count ?? 0, UICollectionView.columnCount)
        default:
            assertionFailure("numberOfItemsInSection Error")
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfCell.identifier, for: indexPath) as? BookshelfCell else { return UICollectionViewCell() }
        switch indexPath.section {
        case 0:
            if self.currentTab == .home {
                guard let info = self.viewModel?.workbooksForRecent[safe: indexPath.item] else { return cell }
                cell.configure(with: info, delegate: self)
            } else if self.currentTab == .workbook {
                guard let info = self.viewModel?.workbooks[safe: indexPath.item] else { return cell }
                cell.configure(with: info, delegate: self)
            } else if self.currentTab == .practiceTest {
                guard let info = self.viewModel?.workbookGroups[safe: indexPath.item] else { return cell }
                cell.configure(with: info, delegate: self)
            } else {
                assertionFailure("cellForItemAt Error")
            }
        case 1:
            guard self.currentTab == .home,
                  let info = self.viewModel?.workbooks[safe: indexPath.item] else { return cell }
            cell.configure(with: info, delegate: self)
        case 2:
            guard self.currentTab == .home,
                  let info = self.viewModel?.workbookGroups[safe: indexPath.item] else { return cell }
            cell.configure(with: info, delegate: self)
        default:
            assertionFailure("cellForItemAt Error")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        if self.currentTab == .home {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BookshelfHomeHeaderView.identifier, for: indexPath) as? BookshelfHomeHeaderView else { return UICollectionReusableView() }
            header.configure(delegate: self, section: indexPath.section)
            return header
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BookshelfDetailHeaderView.identifier, for: indexPath) as? BookshelfDetailHeaderView else { return UICollectionReusableView() }
            guard let order = self.currentTab == .workbook ? self.viewModel?.currentWorkbooksOrder : self.viewModel?.currentWorkbookGroupsOrder else { return header }
            header.configure(delegate: self, order: order)
            return header
        }
    }
}

extension BookshelfVC: UICollectionViewDelegateFlowLayout {
    // MARK: 0개인 경우 UI 표시 분기처리 로직 필요
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.currentTab == .home {
            return CGSize(collectionView.bounds.width, 40)
        } else {
            return CGSize(collectionView.bounds.width, 66)
        }
    }
}

extension BookshelfVC {
    private func changeTabUI() {
        let tabIndex = self.currentTab.rawValue
        for (idx, button) in self.bookshelfTabButtons.enumerated() {
            if button.tag == tabIndex {
                button.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
                self.bookshelfTabUnderlines[idx].alpha = 1
            } else {
                button.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                self.bookshelfTabUnderlines[idx].alpha = 0
            }
        }
    }
}

extension BookshelfVC: BookshelfHomeDelegate {
    func showAllRecentWorkbooks() {
        self.viewModel?.currentWorkbooksOrder = .recentRead
        self.viewModel?.reloadWorkbooks()
        self.currentTab = .workbook
    }
    
    func showAllRecentPurchaseWorkbooks() {
        self.viewModel?.currentWorkbooksOrder = .recentPurchase
        self.currentTab = .workbook
    }
    
    func showAllPracticeTests() {
        self.viewModel?.currentWorkbookGroupsOrder = .recentRead
        self.currentTab = .practiceTest
    }
}

extension BookshelfVC: BookshelfDetailDelegate {
    func refreshWorkbooks() {
        self.viewModel?.refresh(tab: self.currentTab)
    }
    
    func changeOrder(to order: DropdownOrderButton.BookshelfOrder) {
        if self.currentTab == .workbook {
            self.viewModel?.currentWorkbooksOrder = order
            self.viewModel?.reloadWorkbooks()
        } else {
            self.viewModel?.currentWorkbookGroupsOrder = order
            self.viewModel?.reloadWorkbookGroups()
        }
    }
}

extension BookshelfVC: BookshelfCellDelegate {
    func showWorkbookDetailVC(wid: Int) {
        guard let workbook = CoreUsecase.fetchPreview(wid: wid) else { return }
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        
        let viewModel = WorkbookDetailVM(previewCore: workbook, networkUsecase: NetworkUsecase(network: Network()))
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    func showWorkbookGroupDetailVC(wgid: Int) {
        guard let workbookGroup = CoreUsecase.fetchWorkbookGroup(wgid: wgid) else { return }
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        
        let viewModel = WorkbookGroupDetailVM(coreInfo: workbookGroup, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
}
