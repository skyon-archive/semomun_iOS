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
    private var isMigration: Bool = false
    private var order: SortOrder = .purchase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.checkMigration()
        self.configureObservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isMigration {
            self.startMigration()
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.syncBookshelf()
    }
    
    private func spinAnimation() {
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
        if let order = UserDefaultsManager.get(forKey: .bookshelfOrder) as? String {
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
    
    private func checkMigration() {
        let logined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        let coreVersion = UserDefaultsManager.get(forKey: .coreVersion) as? String ?? String.pastVersion
        // 기존 회원이며, 이전버전의 CoreData 일 경우 -> migration 로직 적용
        if logined && coreVersion.compare(String.latestCoreVersion, options: .numeric) == .orderedAscending { // 비교 값은 분기 버전
            print("migration start")
            self.showLoader()
            self.isMigration = true
        } else {
            self.reloadBookshelf()
            self.syncBookshelf()
        }
    }
    
    private func configureObservation() {
        NotificationCenter.default.addObserver(forName: .refreshBookshelf, object: nil, queue: .current) { [weak self] _ in
            self?.syncBookshelf()
        }
    }
    
    private func startMigration() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? String.currentVersion
        CoreUsecase.migration { [weak self] didMigrationSuccess in
            self?.removeLoader()
            self?.isMigration = false
            
            guard didMigrationSuccess else {
                print("migration fail")
                return
            }
            // TODO: Migration 의 경우 syncBookshelf 에서 purchased 값을 저장하는 로직이 필요
            UserDefaultsManager.set(to: version, forKey: .coreVersion) // migration 완료시 현재 version 저장
            CoreDataManager.saveCoreData()
            self?.reloadBookshelf()
            print("migration success")
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
        UserDefaultsManager.set(to: order.rawValue, forKey: .bookshelfOrder)
        self.sortSelector.setTitle(order.rawValue, for: .normal)
        self.reloadBookshelf()
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.viewModel?.books.count ?? 0
        return count%2 == 1 ? count+1 : count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookshelfCell.identifier, for: indexPath) as? BookshelfCell else { return UICollectionViewCell() }
        let count = self.viewModel?.books.count ?? 0
        let isOdd = count%2 == 1
        let isLastIndex = self.isLastIndex(collectionView: collectionView, indexPath: indexPath)
        let isShadowCell = isOdd && isLastIndex
        if isShadowCell {
            cell.configureShadow()
        } else {
            guard let book = self.viewModel?.books[indexPath.item] else { return cell }
            cell.configure(with: book)
        }
        
        return cell
    }
    
    private func isLastIndex(collectionView: UICollectionView, indexPath: IndexPath) -> Bool {
        let lastIndex: Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        return indexPath.item == lastIndex
    }
}

extension BookshelfVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let count = self.viewModel?.books.count ?? 0
        let isOdd = count%2 == 1
        let isLastIndex = self.isLastIndex(collectionView: collectionView, indexPath: indexPath)
        if isOdd && isLastIndex { return } // 전체수가 홀수이면서 마지막 cell 일 경우 클릭액션 제거
        
        guard let book = self.viewModel?.books[indexPath.item] else { return }
        self.showWorkbookDetailVC(book: book)
    }
}

extension BookshelfVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.books.frame.width)/2
        let height: CGFloat = 182
        return CGSize(width: width, height: height)
    }
}

extension BookshelfVC {
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecse else { return }
        let viewModel = WorkbookViewModel(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
}
