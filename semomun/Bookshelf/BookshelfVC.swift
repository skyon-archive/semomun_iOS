//
//  BookshelfVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class BookshelfVC: UIViewController {
    /* public */
    static let identifier = "BookshelfVC"
    static let storyboardName = "HomeSearchBookshelf"
    /* private */
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var books: UICollectionView!
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    
    private var hasWorkbookGroups: Bool {
        return self.viewModel?.workbookGroups.isEmpty == false
    }
    
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
        guard self.books != nil else { return }
        coordinator.animate(alongsideTransition: { _ in
            self.books.reloadData()
        })
    }
}

extension BookshelfVC {
    private func configureUI() {
        self.view.layoutIfNeeded()
        self.setShadow(with: navigationTitleView)
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = BookshelfVM(networkUsecse: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.books.dataSource = self
        self.books.delegate = self
    }
    
    private func checkSyncBookshelf() {
        if UserDefaultsManager.isLogined {
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
            self?.checkSyncBookshelf()
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .current) { [weak self] _ in
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
            .sink(receiveValue: { [weak self] _ in
                self?.books.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbooks() {
        self.viewModel?.$filteredWorkbooks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.books.reloadData()
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.hasWorkbookGroups ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.hasWorkbookGroups {
                return self.viewModel?.workbookGroups.count ?? 0
            } else {
                return self.viewModel?.filteredWorkbooks.count ?? 0
            }
        default:
            return self.viewModel?.filteredWorkbooks.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfCell.identifier, for: indexPath) as? BookshelfCell else { return UICollectionViewCell() }
        switch indexPath.section {
        case 0:
            if self.hasWorkbookGroups {
                guard let workbookGroup = self.viewModel?.workbookGroups[safe: indexPath.item] else { return cell }
                cell.configure(with: workbookGroup, imageSize: self.imageFrameViewSize)
            } else {
                guard let workbook = self.viewModel?.filteredWorkbooks[safe: indexPath.item] else { return cell }
                cell.configure(with: workbook, imageSize: self.imageFrameViewSize)
            }
        default:
            guard let workbook = self.viewModel?.filteredWorkbooks[safe: indexPath.item] else { return cell }
            cell.configure(with: workbook, imageSize: self.imageFrameViewSize)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BookshelfHeaderView.identifier, for: indexPath) as? BookshelfHeaderView else { return UICollectionReusableView() }
            
            switch indexPath.section {
            case 0:
                if self.hasWorkbookGroups {
                    header.configure(title: "나의 실전 모의고사", isWorkbookGroup: true, delegate: self)
                } else {
                    header.configure(title: "나의 문제집", isWorkbookGroup: false, delegate: self)
                }
            default:
                header.configure(title: "나의 문제집", isWorkbookGroup: false, delegate: self)
            }
            
            return header
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BookshelfFooterView.identifier, for: indexPath)
            return footer
        } else {
            return UICollectionReusableView()
        }
    }
}

extension BookshelfVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if self.hasWorkbookGroups {
                guard let workbookGroupCore = self.viewModel?.workbookGroups[safe: indexPath.item] else { return }
                self.showWorkbookGroupDetailVC(coreInfo: workbookGroupCore)
            } else {
                let bookIndex = Int(self.columnCount)*indexPath.section + indexPath.row
                guard let book = self.viewModel?.filteredWorkbooks[bookIndex] else { return }
                
                self.showWorkbookDetailVC(book: book)
            }
        default:
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
            return CGSize(width: self.books.frame.width, height: 182)
        }
    }
}

extension BookshelfVC {
    func reloadWorkbookGroups() {
        if let order = UserDefaultsManager.workbookGroupsOrder {
            self.viewModel?.reloadWorkbookGroups(order: BookshelfSortOrder(rawValue: order) ?? .purchase)
        } else {
            self.viewModel?.reloadWorkbookGroups(order: .purchase)
        }
    }
    
    func reloadWorkbooks() {
        if let order = UserDefaultsManager.bookshelfOrder {
            self.viewModel?.reloadWorkbooks(order: BookshelfSortOrder(rawValue: order) ?? .purchase)
        } else {
            self.viewModel?.reloadWorkbooks(order: .purchase)
        }
    }
}

extension BookshelfVC: BookshelfOrderController {
    func reloadWorkbookGroups(order: BookshelfSortOrder) {
        self.viewModel?.reloadWorkbookGroups(order: order)
    }
    
    func syncWorkbookGroups() {
        self.viewModel?.fetchWorkbookGroupsFromNetwork()
    }
    
    func reloadWorkbooks(order: BookshelfSortOrder) {
        self.viewModel?.reloadWorkbooks(order: order)
    }
    
    func syncWorkbooks() {
        self.viewModel?.fetchWorkbooksFromNetwork()
    }
    
    func showWarning(title: String, text: String) {
        self.showAlertWithOK(title: title, text: text)
    }
}
