//
//  HomeVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class HomeVC: UIViewController {
    @IBOutlet weak var navigationTitleView: UIView!
    @IBOutlet weak var bannerAds: UICollectionView!
    @IBOutlet weak var bestSellers: UICollectionView!
    @IBOutlet weak var workbooksWithTags: UICollectionView!
    @IBOutlet weak var workbooksWithRecent: UICollectionView!
    @IBOutlet weak var workbooksWithNewest: UICollectionView!
    @IBOutlet weak var tagsStackView: UIStackView!
    @IBOutlet weak var recentHeight: NSLayoutConstraint!
    @IBOutlet weak var newestHeight: NSLayoutConstraint!
    private var viewModel: HomeVM?
    private var cancellables: Set<AnyCancellable> = []
    private var bannerAdsAutoScrollTimer: Timer?
    private let bannerAdsAutoScrollInterval: TimeInterval = 3
    private lazy var noLoginedLabel1 = NoneWorkbookLabel()
    private lazy var noLoginedLabel2 = NoneWorkbookLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: navigationTitleView)
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
        self.fetch()
        self.configureAddObserver()
        self.configureBannerAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startBannerAdsAutoScroll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopBannerAdsAutoScroll()
    }
    
    @IBAction func appendTags(_ sender: Any) {
        self.showSearchTagVC()
    }
}

// MARK: - Configure
extension HomeVC {
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = HomeVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.configureBannerAds()
        self.bestSellers.dataSource = self
        self.workbooksWithTags.dataSource = self
        self.workbooksWithRecent.dataSource = self
        self.workbooksWithNewest.dataSource = self
        self.bestSellers.delegate = self
        self.workbooksWithTags.delegate = self
        self.workbooksWithRecent.delegate = self
        self.workbooksWithNewest.delegate = self
    }
    
    private func configureBannerAds() {
        self.bannerAds.delegate = self
        self.bannerAds.dataSource = self
        let bannerAdsFlowLayout = BannerAdsFlowLayout(autoScrollStopper: self)
        self.bannerAds.collectionViewLayout = bannerAdsFlowLayout
        self.bannerAds.decelerationRate = .fast
        self.configureBannerAdsStartIndex()
    }
    
    private func configureBannerAdsStartIndex() {
        guard let adDataNum = self.viewModel?.ads.count, adDataNum > 0 else { return }
        let adRepeatTime = self.collectionView(self.bannerAds, numberOfItemsInSection: 0) / adDataNum
        let startIndex = adDataNum * (adRepeatTime / 2)
        self.bannerAds.scrollToItem(at: IndexPath(item: startIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func configureTags(with tags: [String]) {
        self.tagsStackView.subviews.forEach { $0.removeFromSuperview() }
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        let superWidth = self.view.frame.width
        var widthSum: CGFloat = 0
        
        tags.forEach { tag in
            let tagView = UIView()
            tagView.layer.borderWidth = 1
            tagView.layer.cornerRadius = 15
            tagView.clipsToBounds = true
            tagView.layer.borderColor = UIColor(.deepMint)?.cgColor
            let tagLabel = UILabel()
            tagLabel.backgroundColor = .clear
            tagLabel.textColor = UIColor(.deepMint)
            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            tagLabel.text = "#\(tag)"
            
            tagView.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagView.addSubview(tagLabel)
            NSLayoutConstraint.activate([
                tagView.heightAnchor.constraint(equalToConstant: 30),
                tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
                tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
                tagLabel.leadingAnchor.constraint(equalTo: tagView.leadingAnchor, constant: 10)
            ])
            
            let width = "#\(tag)".size(withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]).width+20+8
            if superWidth - 200 > widthSum + width {
                self.tagsStackView.addArrangedSubview(tagView)
                widthSum += width+8
            }
        }
    }
    
    private func fetch() {
        let isLogined = UserDefaultsManager.get(forKey: .logined) as? Bool ?? false
        if isLogined {
            self.noLoginedLabel1.removeFromSuperview()
            self.noLoginedLabel2.removeFromSuperview()
            self.recentHeight.constant = 232
            self.newestHeight.constant = 232
            self.viewModel?.fetchAll()
        } else {
            self.viewModel?.fetchSome()
            self.configureLoginTextView()
        }
    }
    
    private func configureLoginTextView() {
        self.recentHeight.constant = 72
        self.newestHeight.constant = 72
        
        self.noLoginedLabel1.text = "아직 푼 문제집이 없습니다!\n문제집을 검색하여 추가하고, 문제집을 풀어보세요"
        self.workbooksWithRecent.addSubview(self.noLoginedLabel1)
        NSLayoutConstraint.activate([
            self.noLoginedLabel1.centerYAnchor.constraint(equalTo: self.workbooksWithRecent.centerYAnchor),
            self.noLoginedLabel1.leadingAnchor.constraint(equalTo: self.workbooksWithRecent.leadingAnchor, constant: 50)
        ])
        
        self.noLoginedLabel2.text = "아직 구매한 문제집이 없습니다!\n문제집을 검색하여 추가하고, 문제집을 풀어보세요"
        self.workbooksWithNewest.addSubview(self.noLoginedLabel2)
        NSLayoutConstraint.activate([
            self.noLoginedLabel2.centerYAnchor.constraint(equalTo: self.workbooksWithNewest.centerYAnchor),
            self.noLoginedLabel2.leadingAnchor.constraint(equalTo: self.workbooksWithNewest.leadingAnchor, constant: 50)
        ])
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .refreshBookshelf, object: nil, queue: .main) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        }
        NotificationCenter.default.addObserver(forName: .logined, object: nil, queue: .main) { [weak self] _ in
            self?.fetch()
        }
    }
}

// MARK: - Binding
extension HomeVC {
    private func bindAll() {
        self.bindTags()
        self.bindAds()
        self.bindBestSellers()
        self.bindRecent()
        self.bindNewest()
        self.bindWorkbookDTO()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.configureTags(with: tags)
            })
            .store(in: &self.cancellables)
        
        self.viewModel?.$workbooksWithTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.workbooksWithTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindAds() {
        self.viewModel?.$ads
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.bannerAds.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindBestSellers() {
        self.viewModel?.$bestSellers
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.bestSellers.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindRecent() {
        self.viewModel?.$workbooksWithRecent
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.workbooksWithRecent.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNewest() {
        self.viewModel?.$workbooksWithNewest
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.workbooksWithNewest.reloadData()
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
}

// MARK: - CollectionView
extension HomeVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case self.bannerAds:
            return (self.viewModel?.ads.count ?? 0) * 500
        case self.bestSellers:
            return self.viewModel?.bestSellers.count ?? 0
        case self.workbooksWithTags:
            return self.viewModel?.workbooksWithTags.count ?? 0
        case self.workbooksWithRecent:
            return self.viewModel?.workbooksWithRecent.count ?? 0
        case self.workbooksWithNewest:
            return self.viewModel?.workbooksWithNewest.count ?? 0
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bannerAds {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeAdCell.identifier, for: indexPath) as? HomeAdCell else { return UICollectionViewCell() }
            guard let count = self.viewModel?.ads.count else { return cell }
            guard let testAd = self.viewModel?.ads[indexPath.item % count] else { return cell }
            
            cell.configureTest(imageURL: testAd.0, url: testAd.1)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeWorkbookCell.identifier, for: indexPath) as? HomeWorkbookCell else { return UICollectionViewCell() }
            cell.configureNetworkUsecase(to: self.viewModel?.networkUsecase)
            
            switch collectionView {
            case self.bestSellers:
                guard let preview = self.viewModel?.bestSeller(index: indexPath.item) else { return cell }
                cell.configure(with: preview)
            case self.workbooksWithTags:
                guard let preview = self.viewModel?.workbookWithTags(index: indexPath.item) else { return cell }
                cell.configure(with: preview)
            case self.workbooksWithRecent:
                guard let preview = self.viewModel?.workbookWithRecent(index: indexPath.item) else { return cell }
                cell.configure(with: preview)
            case self.workbooksWithNewest:
                guard let preview = self.viewModel?.workbookWithNewest(index: indexPath.item) else { return cell }
                cell.configure(with: preview)
            default:
                return cell
            }
            
            return cell
        }
    }
}

extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case self.bannerAds:
            return
        case self.bestSellers:
            guard let wid = self.viewModel?.bestSellers[indexPath.item].wid else { return }
            self.searchWorkbook(wid: wid)
        case self.workbooksWithTags:
            guard let wid = self.viewModel?.workbooksWithTags[indexPath.item].wid else { return }
            self.searchWorkbook(wid: wid)
        case self.workbooksWithRecent:
            guard let wid = self.viewModel?.workbooksWithRecent[indexPath.item].wid else { return }
            self.searchWorkbook(wid: wid)
        case self.workbooksWithNewest:
            guard let wid = self.viewModel?.workbooksWithNewest[indexPath.item].wid else { return }
            self.searchWorkbook(wid: wid)
        default:
            return
        }
    }
    
    private func searchWorkbook(wid: Int) {
        guard let books = CoreUsecase.fetchPreviews() else { return }
        let isCoredata = books.contains { Int($0.wid) == wid }
        
        if isCoredata {
            guard let book = CoreUsecase.fetchPreview(wid: wid) else { return }
            self.showWorkbookDetailVC(book: book)
        } else {
            self.viewModel?.fetchWorkbook(wid: wid)
        }
    }
    
    private func showWorkbookDetailVC(workbook: WorkbookOfDB) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookViewModel(workbookDTO: workbook, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: false)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(name: WorkbookDetailVC.storyboardName, bundle: nil)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookViewModel(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showSearchTagVC() {
        let storyboard = UIStoryboard(name: SearchTagVC.storyboardName, bundle: nil)
        guard let searchTagVC = storyboard.instantiateViewController(withIdentifier: SearchTagVC.identifier) as? SearchTagVC else { return }
        
        self.present(searchTagVC, animated: true, completion: nil)
    }
}

extension HomeVC {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.startBannerAdsAutoScroll()
    }
    
    /// Note: Cell의 개수가 화면을 가득 채움을 가정
    private func startBannerAdsAutoScroll() {
        guard self.bannerAdsAutoScrollTimer == nil else { return }
        self.bannerAdsAutoScrollTimer = Timer(timeInterval: self.bannerAdsAutoScrollInterval, repeats: true) { [weak self] _ in
            self?.scrollOneItemInBannerAds()
        }
        RunLoop.current.add(self.bannerAdsAutoScrollTimer!, forMode: .common)
    }
    private func scrollOneItemInBannerAds() {
        guard let bannerAds = self.bannerAds else { return }
        let bannerAdsDataCount = bannerAds.dataSource?.collectionView(bannerAds, numberOfItemsInSection: 0) ?? 0
        guard bannerAdsDataCount != 0 else { return }
        let visibleItemIndexes = bannerAds.indexPathsForVisibleItems.sorted()
        
        // 더 이상 넘길 수 없는 경우 체크
        let lastVisibleItemIndex = visibleItemIndexes.last!.item
        if lastVisibleItemIndex == bannerAdsDataCount - 1 {
            self.bannerAds.scrollToItem(at: IndexPath(item: bannerAdsDataCount/2, section: 0), at: .centeredHorizontally, animated: false)
            return
        }
        
        let nextIndex = visibleItemIndexes[visibleItemIndexes.count/2 + 1]
        self.bannerAds.scrollToItem(at: nextIndex, at: .centeredHorizontally, animated: true)
    }
}

extension HomeVC: BannerAdsAutoScrollStoppable {
    func stopBannerAdsAutoScroll() {
        self.bannerAdsAutoScrollTimer?.invalidate()
        self.bannerAdsAutoScrollTimer = nil
    }
}
