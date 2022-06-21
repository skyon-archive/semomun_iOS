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
    @IBOutlet weak var bookCountLabel: UILabel!
    @IBOutlet weak var refreshBT: UIButton!
    @IBOutlet weak var sortSelector: UIButton!
    @IBOutlet weak var books: UICollectionView!
    
    private var viewModel: BookshelfVM?
    private var cancellables: Set<AnyCancellable> = []
    private lazy var loadingView = LoadingView()
    private var order: SortOrder = .purchase
    private var logined: Bool = false
    
    private lazy var columnCount: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 3
        } else {
            if self.view.frame.width == 1024 {
                return 6
            } else if self.view.frame.width == 744 {
                return 4
            } else {
                return 5
            }
        }
    }()
    
    private lazy var imageFrameViewSize: CGSize = {
        let horizontalMargin: CGFloat = 28
        let horizontalTerm: CGFloat = 10
        
        let superWidth = self.books.frame.width - 2*horizontalMargin
        let cellWidth = (superWidth - (horizontalTerm*(self.columnCount-1)))/self.columnCount
        
        let width = cellWidth - 10
        let height = width*5/4
        
        return CGSize(width, height)
    }()
    
    private lazy var cellSize: CGSize = {
        // MARK: phone 버전 대응은 추후 반영할 예정
        if UIDevice.current.userInterfaceIdiom == .pad {
            let imageFrameViewSize = self.imageFrameViewSize
            
            let width = imageFrameViewSize.width + 10
            let height = 10 + imageFrameViewSize.height + 42 + 30 + 10
            
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: self.books.frame.width, height: 182)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.checkSyncBookshelf()
        self.configureObservation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard UserDefaultsManager.isLogined else { return }
        self.reloadBookshelf()
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.logined = UserDefaultsManager.isLogined
        guard NetworkStatusManager.isConnectedToInternet() else {
            self.showAlertWithOK(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.")
            return
        }
        if self.logined {
            self.syncBookshelf()
        } else {
            self.spinAnimation()
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    private func spinAnimation() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1) {
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((180.0 * .pi) / 180.0) * -1)
            self.refreshBT.transform = CGAffineTransform(rotationAngle: ((0.0 * .pi) / 360.0) * -1)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.refreshBT.transform = CGAffineTransform.identity
        }
    }
}

extension BookshelfVC {
    private func configureUI() {
        self.view.layoutIfNeeded()
        self.setShadow(with: navigationTitleView)
        self.sortSelector.layer.borderWidth = 1
        self.sortSelector.layer.borderColor = UIColor.lightGray.cgColor
        self.sortSelector.clipsToBounds = true
        self.sortSelector.layer.cornerRadius = 3
        self.configureMenu()
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = BookshelfVM(networkUsecse: networkUsecase)
    }
    
    private func configureMenu() {
        let purchaseAction = UIAction(title: SortOrder.purchase.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .purchase)
        }
        let recentAction = UIAction(title: SortOrder.recent.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .recent)
        }
        let alphabetAction = UIAction(title: SortOrder.alphabet.rawValue, image: nil) { [weak self] _ in
            self?.changeSort(to: .alphabet)
        }
        if let order = UserDefaultsManager.bookshelfOrder {
            self.order = SortOrder(rawValue: order) ?? .purchase
        }
        self.sortSelector.setTitle(self.order.rawValue, for: .normal)
        self.sortSelector.menu = UIMenu(title: "정렬 리스트", image: nil, children: [purchaseAction, recentAction, alphabetAction])
        self.sortSelector.showsMenuAsPrimaryAction = true
    }
    
    private func configureCollectionView() {
        self.books.dataSource = self
        self.books.delegate = self
    }
    
    private func checkSyncBookshelf() {
        self.logined = UserDefaultsManager.isLogined
        if self.logined {
            self.reloadBookshelf()
            self.syncBookshelf()
        } else {
            // login 없는 상태, 뭔가 UI적으로 표시할 게 있다면?
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .current) { [weak self] _ in
            self?.logined = true
            self?.syncBookshelf()
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
    private func changeSort(to order: SortOrder) {
        self.order = order
        self.sortSelector.setTitle(order.rawValue, for: .normal)
        UserDefaultsManager.bookshelfOrder = order.rawValue
        
        if self.logined {
            self.reloadBookshelf()
        } else {
            // login 없는 상태, 표시할 팝업이 있다면?
        }
    }
    
    private func reloadBookshelf() {
        self.viewModel?.reloadBookshelf(order: self.order)
    }
    
    private func syncBookshelf() {
        self.spinAnimation()
        self.viewModel?.fetchBooksFromNetwork()
    }
}

// MARK: binding
extension BookshelfVC {
    private func bindAll() {
        self.bindBooks()
        self.bindWarning()
        self.bindLoading()
    }
    
    private func bindBooks() {
        self.viewModel?.$books
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] books in
                self?.bookCountLabel.text = "\(books.count)권"
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
                    self?.reloadBookshelf()
                }
            })
            .store(in: &self.cancellables)
    }
}

extension BookshelfVC: UICollectionViewDataSource {
    /// section 개수 = columnCount 으로  나눈 몫값, 나머지가 있는 경우 +1
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let booksCount = self.viewModel?.books.count {
            var sectionCount = booksCount / Int(self.columnCount)
            if booksCount % Int(self.columnCount) != 0 {
                sectionCount += 1
            }
            return sectionCount
        } else {
            return 0
        }
    }
    /// 해당 section의 cell 개수 = 전체 - (section+1)*columnCount 값이 0 이상 -> column수, 아닐 경우 나머지값
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let booksCount = self.viewModel?.books.count ?? 0
        if booksCount - (section+1)*Int(self.columnCount) >= 0 {
            return Int(self.columnCount)
        } else {
            return booksCount % Int(self.columnCount)
        }
    }
    /// cell.index = section*columnCount + row
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfCell.identifier, for: indexPath) as? BookshelfCell else { return UICollectionViewCell() }
        let bookIndex = Int(self.columnCount)*indexPath.section + indexPath.row
        guard let book = self.viewModel?.books[bookIndex] else { return cell }
        
        cell.configure(with: book, imageSize: self.imageFrameViewSize)
        
        return cell
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
        let bookIndex = Int(self.columnCount)*indexPath.section + indexPath.row
        guard let book = self.viewModel?.books[bookIndex] else { return }
        
        self.showWorkbookDetailVC(book: book)
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
}
