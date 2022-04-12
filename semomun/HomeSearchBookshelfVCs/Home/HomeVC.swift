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
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    private lazy var warningOfflineView = WarningOfflineStatusView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureViewModel()
        self.bindAll()
        self.viewModel?.checkLogined()
        self.viewModel?.checkVersion()
        self.configureCollectionView()
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
    private func configureUI() {
        self.scrollView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
        self.navigationTitleView.addShadow(direction: .bottom)
    }
    
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
        self.bannerAds.decelerationRate = .fast
    }
    
    private func configureBannerAdsStartIndex() {
        let bannerAdsFlowLayout = BannerAdsFlowLayout(autoScrollStopper: self)
        self.bannerAds.collectionViewLayout = bannerAdsFlowLayout
        
        guard let adDataNum = self.viewModel?.ads.count, adDataNum > 0 else { return }
        let adRepeatTime = self.collectionView(self.bannerAds, numberOfItemsInSection: 0) / adDataNum
        let startIndex = adDataNum * (adRepeatTime / 2)
        self.bannerAds.scrollToItem(at: IndexPath(item: startIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    private func configureTags(with tags: [String]) {
        self.tagsStackView.subviews.forEach { $0.removeFromSuperview() }
        self.tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        var superWidth = self.view.frame.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            superWidth -= 200
        } else {
            superWidth -= 137
        }
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
            
            let width = "#\(tag)".size(withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]).width+20
            if superWidth > widthSum + width {
                self.tagsStackView.addArrangedSubview(tagView)
                widthSum += width+8
            }
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
        NotificationCenter.default.addObserver(forName: .tokenExpired, object: nil, queue: .main) { [weak self] _ in
            self?.showAlertWithOK(title: "세션이 만료되었습니다.", text: "다시 로그인 해주시기 바랍니다.") {
                LogoutUsecase.logout()
                NotificationCenter.default.post(name: .logout, object: nil)
            }
        }
    }
    
    private func showOfflineAlert() {
        self.view.addSubview(self.warningOfflineView)
        NSLayoutConstraint.activate([
            self.warningOfflineView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.warningOfflineView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.warningOfflineView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.warningOfflineView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
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
        self.bindNewest()
        self.bindWorkbookDTO()
        self.bindOfflineStatus()
        self.bindLogined()
        self.bindVersion()
        self.bindWarning()
        self.bindPopup()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.configureTags(with: tags.map(\.name))
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
                self?.configureBannerAdsStartIndex()
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
                if logined == false {
                    self?.configureLoginTextView()
                } else {
                    self?.noLoginedLabel1.removeFromSuperview()
                    self?.noLoginedLabel2.removeFromSuperview()
                    self?.recentHeight.constant = UIDevice.current.userInterfaceIdiom == .phone ? 200 : 232
                    self?.newestHeight.constant = UIDevice.current.userInterfaceIdiom == .phone ? 200 : 232
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
            
            cell.configureContent(imageURL: testAd.image, url: testAd.url)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeWorkbookCell.identifier, for: indexPath) as? HomeWorkbookCell else { return UICollectionViewCell() }
            cell.configureNetworkUsecase(to: self.viewModel?.networkUsecase)
            
            switch collectionView {
            case self.bestSellers:
                guard let preview = self.viewModel?.bestSellers[indexPath.item] else { return cell }
                cell.configure(with: preview)
            case self.workbooksWithTags:
                guard let preview = self.viewModel?.workbooksWithTags[indexPath.item] else { return cell }
                cell.configure(with: preview)
            case self.workbooksWithRecent:
                guard let info = self.viewModel?.workbooksWithRecent[indexPath.item] else { return cell }
                cell.configure(with: info)
            case self.workbooksWithNewest:
                guard let info = self.viewModel?.workbooksWithNewest[indexPath.item] else { return cell }
                cell.configure(with: info)
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
        if let book = CoreUsecase.fetchPreview(wid: wid) {
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
