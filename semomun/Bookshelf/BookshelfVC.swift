//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

class BookshelfVC: UIViewController {
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    enum SortOrder: String {
        case purchase = "최근 구매일 순"
        case recent = "최근 읽은 순"
        case alphabet = "제목 가나다 순"
    }
    
    @IBOutlet weak var navigationTitleView: UIView!
    // workbookGroups
    @IBOutlet weak var workbookGroupsRefreshBT: UIButton!
    @IBOutlet weak var workbookGroupsSortSelector: UIButton!
    @IBOutlet weak var workbookGroups: UICollectionView!
    @IBOutlet weak var workbookGroupsHeight: NSLayoutConstraint! // 회전, 디바이스별 크기에 따른 설정 필요
    private var workbookGroupsOrder: SortOrder = .purchase
    // workbooks
    @IBOutlet weak var workbooksRefreshBT: UIButton!
    @IBOutlet weak var workbooksSortSelector: UIButton!
    @IBOutlet weak var workbooks: UICollectionView!
    private var workbooksOrder: SortOrder = .purchase
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    private var logined: Bool = false
    
    private lazy var portraitColumnCount: Int = {
        let screenWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        var horizontalCellCount: Int
        
        switch screenWidth {
            // 12인치의 경우 6개씩 표시
        case 1024:
            horizontalCellCount = 6
            // 미니의 경우 4개씩 표시
        case 744:
            horizontalCellCount = 4
        default:
            // 기본의 경우 5개씩 표시
            horizontalCellCount = 5
        }
        if UIDevice.current.userInterfaceIdiom == .phone { // phone 일 경우 2개씩 표시
            horizontalCellCount = 2
        }
        return horizontalCellCount
    }()
    
    private lazy var landscapeColumnCount: Int = {
        return self.portraitColumnCount + 2
    }()
    
    private var columnCount: Int {
        return UIWindow.isLandscape ? self.landscapeColumnCount : self.portraitColumnCount
    }
    
    private var portraitImageFrameViewSize: CGSize {
        return self.getImageFrameViewSize(columnCount: self.portraitColumnCount)
    }
    
    private var landscapeImageFrameViewSize: CGSize {
        return self.getImageFrameViewSize(columnCount: self.landscapeColumnCount)
    }
    
    private var imageFrameViewSize: CGSize {
        return UIWindow.isLandscape ? self.landscapeImageFrameViewSize : self.portraitImageFrameViewSize
    }
    
    private var portraitCellSize: CGSize {
        return self.getCellSize(imageFrameViewSize: self.portraitImageFrameViewSize)
    }
    
    private var landscapeCellSize: CGSize {
        return self.getCellSize(imageFrameViewSize: self.landscapeImageFrameViewSize)
    }
    
    private var cellSize: CGSize {
        return UIWindow.isLandscape ? self.landscapeCellSize : self.portraitCellSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.checkSyncBookshelf()
        self.configureObservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UserDefaultsManager.isLogined else { return }
        self.reloadWorkbookGroups()
        self.reloadWorkbooks()
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard self.workbookGroups != nil, self.workbooks != nil else { return }
        coordinator.animate(alongsideTransition: { _ in
            self.workbookGroups.reloadData()
            self.workbooks.reloadData()
        })
    }
    
    @IBAction func workbookGroupsRefresh(_ sender: Any) {
        self.logined = UserDefaultsManager.isLogined
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.showAlertWithOK(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하세요")
            return
        }
        
        if UserDefaultsManager.isLogined {
            self.reloadWorkbookGroups()
            self.syncWorkbookGroups()
        } else {
            self.spinAnimation(refreshButton: self.workbookGroupsRefreshBT)
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    @IBAction func workbooksRefresh(_ sender: Any) {
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.showAlertWithOK(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하세요")
            return
        }
        
        if UserDefaultsManager.isLogined {
            self.reloadWorkbooks()
            self.syncWorkbooks()
        } else {
            self.spinAnimation(refreshButton: self.workbooksRefreshBT)
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    private func spinAnimation(refreshButton: UIButton) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            refreshButton.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
            refreshButton.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            refreshButton.transform = CGAffineTransform.identity
        }
    }
}

extension BookshelfVC {
    private func configureUI() {
        self.view.layoutIfNeeded()
        self.setShadow(with: navigationTitleView)
        self.configureWorkbookGroupsMenu()
        self.configureWorkbooksMenu()
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = BookshelfVM(networkUsecse: networkUsecase)
    }
    
    private func configureWorkbookGroupsMenu() {
        let purchaseAction = UIAction(title: SortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbookGroupsSort(to: .purchase)
        }
        let recentAction = UIAction(title: SortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbookGroupsSort(to: .recent)
        }
        let alphabetAction = UIAction(title: SortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbookGroupsSort(to: .alphabet)
        }
        if let order = UserDefaultsManager.workbookGroupsOrder {
            self.workbookGroupsOrder = SortOrder(rawValue: order) ?? .purchase
        }
        self.workbookGroupsSortSelector.setTitle(self.workbookGroupsOrder.rawValue, for: .normal)
        self.workbookGroupsSortSelector.menu = UIMenu(title: "정렬 리스트", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.workbookGroupsSortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func configureWorkbooksMenu() {
        let purchaseAction = UIAction(title: SortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbooksSort(to: .purchase)
        }
        let recentAction = UIAction(title: SortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbooksSort(to: .recent)
        }
        let alphabetAction = UIAction(title: SortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.changeWorkbooksSort(to: .alphabet)
        }
        if let order = UserDefaultsManager.bookshelfOrder {
            self.workbooksOrder = SortOrder(rawValue: order) ?? .purchase
        }
        self.workbooksSortSelector.setTitle(self.workbooksOrder.rawValue, for: .normal)
        self.workbooksSortSelector.menu = UIMenu(title: "정렬 리스트", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.workbooksSortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func configureCollectionView() {
        self.workbookGroups.dataSource = self
        self.workbookGroups.delegate = self
        self.workbooks.dataSource = self
        self.workbooks.delegate = self
    }
    
    private func checkSyncBookshelf() {
        self.logined = UserDefaultsManager.isLogined
        if self.logined {
            self.reloadWorkbookGroups()
            self.reloadWorkbooks()
            self.syncWorkbookGroups()
            self.syncWorkbooks()
        } else {
            // login 없는 상태, 뭔가 UI적으로 표시할 게 있다면?
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .current) { [weak self] _ in
            self?.logined = true
            self?.checkSyncBookshelf()
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .current) { [weak self] _ in
            self?.logined = true
            self?.checkSyncBookshelf()
        }
    }
}

// MARK: Loader
extension BookshelfVC {
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

// MARK: Refresh Bookshelf
extension BookshelfVC {
    private func changeWorkbookGroupsSort(to order: SortOrder) {
        self.workbookGroupsOrder = order
        self.workbookGroupsSortSelector.setTitle(order.rawValue, for: .normal)
        UserDefaultsManager.workbookGroupsOrder = order.rawValue
        
        if self.logined {
            self.reloadWorkbookGroups()
        } else {
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    private func changeWorkbooksSort(to order: SortOrder) {
        self.workbooksOrder = order
        self.workbooksSortSelector.setTitle(order.rawValue, for: .normal)
        UserDefaultsManager.bookshelfOrder = order.rawValue
        
        if self.logined {
            self.reloadWorkbooks()
        } else {
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    private func reloadWorkbookGroups() {
        self.viewModel?.reloadWorkbookGroups(order: self.workbooksOrder)
    }
    
    private func reloadWorkbooks() {
        self.viewModel?.reloadWorkbooks(order: self.workbooksOrder)
    }
    
    private func syncWorkbookGroups() {
        self.spinAnimation(refreshButton: self.workbookGroupsRefreshBT)
        self.viewModel?.fetchWorkbookGroupsFromNetwork()
    }
    
    private func syncWorkbooks() {
        self.spinAnimation(refreshButton: self.workbooksRefreshBT)
        self.viewModel?.fetchWorkbooksFromNetwork()
    }
}

// MARK: binding
extension BookshelfVC {
    private func bindAll() {
        self.bindWorkbookGroups()
        self.bindWorkbooks()
        self.bindWarning()
        self.bindLoading()
    }
    
    private func bindWorkbookGroups() {
        self.viewModel?.$workbookGroups
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookGroups in
                self?.workbookGroups.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbooks() {
        self.viewModel?.$filteredWorkbooks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.workbooks.reloadData()
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
    private func bindLoading() {
        self.viewModel?.$loading
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] loading in
                if loading {
                    self?.showLoader()
                } else {
                    self?.removeLoader()
                    self?.reloadWorkbookGroups()
                    self?.reloadWorkbooks()
                }
            })
            .store(in: &self.cancellables)
    }
}

extension BookshelfVC: UICollectionViewDataSource {
    /// section 개수 = columnCount 으로  나눈 몫값, 나머지가 있는 경우 +1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.workbookGroups {
            return 1
        } else {
            if let booksCount = self.viewModel?.filteredWorkbooks.count {
                var sectionCount = booksCount / self.columnCount
                if booksCount % self.columnCount != 0 {
                    sectionCount += 1
                }
                return sectionCount
            } else {
                return 0
            }
        }
    }
    /// 해당 section의 cell 개수 = 전체 - (section+1)*columnCount 값이 0 이상 -> column수, 아닐 경우 나머지값
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.workbookGroups {
            return self.viewModel?.workbookGroups.count ?? 0
        } else {
            let booksCount = self.viewModel?.filteredWorkbooks.count ?? 0
            if booksCount - (section+1)*Int(self.columnCount) >= 0 {
                return Int(self.columnCount)
            } else {
                return booksCount % Int(self.columnCount)
            }
        }
    }
    /// cell.index = section*columnCount + row
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.workbookGroups {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfWorkbookGroupCell.identifier, for: indexPath) as? BookshelfWorkbookGroupCell else { return UICollectionViewCell() }
            guard let workbookGroup = self.viewModel?.workbookGroups[safe: indexPath.item] else { return cell }
            
            cell.configure(with: workbookGroup, imageSize: self.imageFrameViewSize)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfWorkbookCell.identifier, for: indexPath) as? BookshelfWorkbookCell else { return UICollectionViewCell() }
            let bookIndex = Int(self.columnCount)*indexPath.section + indexPath.row
            guard let book = self.viewModel?.filteredWorkbooks[bookIndex] else { return cell }
            
            cell.configure(with: book, imageSize: self.imageFrameViewSize)
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BookshelfFooterView.identifier, for: indexPath)
            return footer
        } else { return UICollectionReusableView() }
    }
}

extension BookshelfVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.workbookGroups {
            guard let workbookGroupCore = self.viewModel?.workbookGroups[safe: indexPath.item] else { return }
            self.showWorkbookGroupDetailVC(coreInfo: workbookGroupCore)
        } else {
            let bookIndex = Int(self.columnCount)*indexPath.section + indexPath.row
            guard let book = self.viewModel?.filteredWorkbooks[bookIndex] else { return }
            
            self.showWorkbookDetailVC(book: book)
        }
    }
}

extension BookshelfVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
}

extension BookshelfVC {
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecse else { return }
        let viewModel = WorkbookDetailVM(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showWorkbookGroupDetailVC(coreInfo: WorkbookGroup_Core) {
        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
        let viewModel = WorkbookGroupDetailVM(coreInfo: coreInfo, networkUsecase: NetworkUsecase(network: Network()))
        workbookGroupDetailVC.configureViewModel(to: viewModel)
        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
    }
}

// MARK: Rotation Layout
extension BookshelfVC {
    private func getImageFrameViewSize(columnCount: Int) -> CGSize {
        let horizontalMargin: CGFloat = 28
        let horizontalTerm: CGFloat = 10
        
        let superWidth = UIScreen.main.bounds.width - 2*horizontalMargin
        let cellWidth = (superWidth - (horizontalTerm*CGFloat(columnCount-1)))/CGFloat(columnCount)
        
        let width = cellWidth - 10
        let height = width*5/4
        
        return CGSize(width, height)
    }
    
    private func getCellSize(imageFrameViewSize: CGSize) -> CGSize {
        // MARK: phone 버전 대응은 추후 반영할 예정
        if UIDevice.current.userInterfaceIdiom == .pad {
            let width = imageFrameViewSize.width + 10
            let height = 10 + imageFrameViewSize.height + 42 + 30 + 10
            
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: self.workbooks.frame.width, height: 182)
        }
    }
}
