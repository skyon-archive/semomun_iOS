//
//  SearchVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

protocol SearchControlable: AnyObject {
    func append(tag: TagOfDB)
    func changeToSearchFavoriteTagsVC()
    func changeToSearchTagsFromTextVC()
    func showWorkbookDetail(wid: Int)
    func showWorkbookGroupDetail(dtoInfo: WorkbookGroupPreviewOfDB)
}

//class SearchVC_past: UIViewController {
//    @IBOutlet weak var searchView: UIView!
//    @IBOutlet weak var searchInnerView: UIView!
//    @IBOutlet weak var cancelSearchBT: UIView!
//    @IBOutlet weak var searchTextField: UITextField!
//    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var tagList: UICollectionView!
//
//    // searchView가 보일 때 상단 여백 조절용
//    @IBOutlet weak var grayMarginView: UIView!
//    @IBOutlet weak var containerViewTopMargin: NSLayoutConstraint!
//
//    private var viewModel: SearchVM?
//    private var cancellables: Set<AnyCancellable> = []
//    private var currentChildVC: UIViewController?
//    private var isSearchTagsFromTextVC: Bool = false
//    private lazy var searchFavoriteTagsVC: UIViewController = {
//        let storyboard = UIStoryboard(controllerType: SearchFavoriteTagsVC.self)
//        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchFavoriteTagsVC.identifier) as? SearchFavoriteTagsVC else { return UIViewController() }
//        viewController.configureDelegate(delegate: self)
//        return viewController
//    }()
//    private lazy var searchTagsFromTextVC: SearchTagsFromTextVC = {
//        let storyboard = UIStoryboard(controllerType: SearchTagsFromTextVC.self)
//        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchTagsFromTextVC.identifier) as? SearchTagsFromTextVC else { return SearchTagsFromTextVC() }
//        viewController.configureDelegate(delegate: self)
//        return viewController
//    }()
//    private lazy var searchResultVC: SearchResultVC = {
//        let storyboard = UIStoryboard(controllerType: SearchResultVC.self)
//        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchResultVC.identifier) as? SearchResultVC else { return SearchResultVC() }
//        viewController.configureDelegate(delegate: self)
//        return viewController
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setShadow(with: searchView)
//        self.configureUI()
//        self.configureViewModel()
//        self.bindAll()
//        self.configureCollectionView()
//        self.configureTextField()
//        self.changeToSearchFavoriteTagsVC()
//        self.configureAddObserver()
//    }
//
//    @IBAction func cancelSearch(_ sender: Any) {
//        self.searchTextField.text = ""
//        self.viewModel?.removeAll()
//    }
//}
//
//// MARK: - Configure
//extension SearchVC_past {
//    private func configureUI() {
//        self.hiddenCancelSearchBT()
//    }
//
//    private func configureViewModel() {
//        let network = Network()
//        let networkUsecase = NetworkUsecase(network: network)
//        self.viewModel = SearchVM(networkUsecase: networkUsecase)
//    }
//
//    private func configureCollectionView() {
//        self.tagList.delegate = self
//        self.tagList.dataSource = self
//    }
//
//    private func configureTextField() {
//        self.searchTextField.delegate = self
//
//        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidTap), for: .touchDown)
//    }
//
//    private func configureAddObserver() {
//        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .main) { [weak self] _ in
//            self?.tabBarController?.selectedIndex = 2
//        }
//    }
//}
//
//// MARK: - Binding
//extension SearchVC_past {
//    private func bindAll() {
//        self.bindTags()
//        self.bindWorkbook()
//    }
//
//    private func bindTags() {
//        self.viewModel?.$tags
//            .receive(on: DispatchQueue.main)
//            .dropFirst()
//            .sink(receiveValue: { [weak self] tags in
//                self?.tagList.reloadData()
//                self?.searchTagsFromTextVC.updateSelectedTags(tags: tags)
//                self?.searchResultVC.removeAll()
//                self?.dismissKeyboard()
//                if tags.count > 0 {
//                    self?.searchWorkbooks()
//                    self?.showCancelSearchBT()
//                } else if tags.count == 0 && self?.searchTextField.text == "" {
//                    self?.searchTagsFromTextVC.refresh()
//                    self?.changeToSearchFavoriteTagsVC()
//                    self?.hiddenCancelSearchBT()
//                }
//            })
//            .store(in: &self.cancellables)
//    }
//
//    private func bindWorkbook() {
//        self.viewModel?.$workbook
//            .receive(on: DispatchQueue.main)
//            .dropFirst()
//            .sink(receiveValue: { [weak self] workbook in
//                guard let workbook = workbook else { return }
//                self?.showWorkbookDetailVC(workbook: workbook)
//            })
//            .store(in: &self.cancellables)
//    }
//}
//
//// MARK: - CollectionView
//extension SearchVC_past: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.viewModel?.tags.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallTagCell.identifier, for: indexPath) as? SmallTagCell else { return UICollectionViewCell() }
//        guard let tag = self.viewModel?.tags[indexPath.item] else { return cell }
//        cell.configure(tag: tag.name)
//
//        return cell
//    }
//}
//
//extension SearchVC_past: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.viewModel?.removeTag(index: indexPath.item)
//    }
//}
//
//// MARK: - Logic
//extension SearchVC_past {
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        guard let text = textField.text else { return }
//        if text.count != 0 {
//            if !self.isSearchTagsFromTextVC {
//                self.changeToSearchTagsFromTextVC()
//                self.searchResultVC.removeAll()
//            }
//            self.showCancelSearchBT()
//        }
//        NotificationCenter.default.post(name: .fetchTagsFromSearch, object: nil, userInfo: ["text" : text])
//    }
//
//    @objc func textFieldDidTap() {
//        self.showCancelSearchBT()
//        if !self.isSearchTagsFromTextVC {
//            self.changeToSearchTagsFromTextVC()
//            self.searchResultVC.removeAll()
//        }
//    }
//
//    private func removeChildVC() {
//        self.currentChildVC?.willMove(toParent: nil)
//        self.currentChildVC?.view.removeFromSuperview()
//        self.currentChildVC?.removeFromParent()
//    }
//
//    private func changeChildVC(to targetVC: UIViewController) {
//        targetVC.view.frame = self.containerView.bounds
//        self.containerView.addSubview(targetVC.view)
//        self.addChild(targetVC)
//        targetVC.didMove(toParent: self)
//
//        if targetVC == self.searchResultVC {
//            self.containerViewTopMargin.constant = -self.grayMarginView.frame.height
//        } else {
//            self.containerViewTopMargin.constant = 0
//        }
//    }
//
//    private func fetchResults() {
//        guard let tags = self.viewModel?.tags,
//              let text = self.searchTextField.text else { return }
//        self.searchResultVC.fetch(tags: tags, text: text)
//    }
//
//    private func showWorkbookDetailVC(workbook: WorkbookOfDB) {
//        let storyboard = UIStoryboard(controllerType: WorkbookDetailVC.self)
//        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
//        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
//        let viewModel = WorkbookDetailVM(workbookDTO: workbook, networkUsecase: networkUsecase)
//        workbookDetailVC.configureViewModel(to: viewModel)
//        workbookDetailVC.configureIsCoreData(to: false)
//        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
//    }
//
//    private func showWorkbookDetailVC(book: Preview_Core) {
//        let storyboard = UIStoryboard(controllerType: WorkbookDetailVC.self)
//        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
//        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
//        let viewModel = WorkbookDetailVM(previewCore: book, networkUsecase: networkUsecase)
//        workbookDetailVC.configureViewModel(to: viewModel)
//        workbookDetailVC.configureIsCoreData(to: true)
//        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
//    }
//
//    private func showWorkbookGroupDetailVC(dtoInfo: WorkbookGroupPreviewOfDB) {
//        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
//        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
//        let viewModel = WorkbookGroupDetailVM(dtoInfo: dtoInfo, networkUsecase: NetworkUsecase(network: Network()))
//        workbookGroupDetailVC.configureViewModel(to: viewModel)
//        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
//    }
//
//    private func showWorkbookGroupDetailVC(coreInfo: WorkbookGroup_Core) {
//        let storyboard = UIStoryboard(name: WorkbookGroupDetailVC.storyboardName, bundle: nil)
//        guard let workbookGroupDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupDetailVC.identifier) as? WorkbookGroupDetailVC else { return }
//        let viewModel = WorkbookGroupDetailVM(coreInfo: coreInfo, networkUsecase: NetworkUsecase(network: Network()))
//        workbookGroupDetailVC.configureViewModel(to: viewModel)
//        self.navigationController?.pushViewController(workbookGroupDetailVC, animated: true)
//    }
//}
//
//// MARK: - ConfigureUI {
//extension SearchVC_past {
//    private func hiddenCancelSearchBT() {
//        self.cancelSearchBT.isHidden = true
//    }
//
//    private func showCancelSearchBT() {
//        self.cancelSearchBT.isHidden = false
//    }
//}
//
//// MARK: - Delegate
//extension SearchVC_past: SearchControlable {
//    func append(tag: TagOfDB) {
//        self.searchTextField.text = ""
//        self.viewModel?.append(tag: tag)
//    }
//
//    func changeToSearchFavoriteTagsVC() {
//        self.removeChildVC()
//        self.changeChildVC(to: self.searchFavoriteTagsVC)
//        self.isSearchTagsFromTextVC = false
//    }
//
//    func changeToSearchTagsFromTextVC() {
//        self.removeChildVC()
//        self.changeChildVC(to: self.searchTagsFromTextVC)
//        self.isSearchTagsFromTextVC = true
//    }
//
//    func showWorkbookDetail(wid: Int) {
//        if UserDefaultsManager.isLogined, let book = CoreUsecase.fetchPreview(wid: wid) {
//            self.showWorkbookDetailVC(book: book)
//        } else {
//            self.viewModel?.fetchWorkbook(wid: wid)
//        }
//    }
//
//    func showWorkbookGroupDetail(dtoInfo: WorkbookGroupPreviewOfDB) {
//        if let coreInfo = CoreUsecase.fetchWorkbookGroup(wgid: dtoInfo.wgid) {
//            self.showWorkbookGroupDetailVC(coreInfo: coreInfo)
//        } else {
//            self.showWorkbookGroupDetailVC(dtoInfo: dtoInfo)
//        }
//    }
//}
//
//extension SearchVC_past: UITextFieldDelegate {
//    private func searchWorkbooks() {
//        self.removeChildVC()
//        self.changeChildVC(to: self.searchResultVC)
//        self.fetchResults()
//        self.isSearchTagsFromTextVC = false
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.searchResultVC.removeAll()
//        self.searchWorkbooks()
//        self.dismissKeyboard()
//        return true
//    }
//}








final class SearchVC: UIViewController {
    enum SearchStatus {
        case `default`
        case searching
        case searchResult
    }
    enum SearchType {
        case workbook
        case workbookGroup
    }
    @IBOutlet weak var leftSearchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var textResetXButton: UIButton! // text.count > 0 인 경우 표시
    @IBOutlet weak var searchCancelButton: UIButton! // search 모드인 경우 표시
    @IBOutlet weak var searchFrameView: UIView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewBackgroundFrameView: UIView!
    @IBOutlet weak var searchResultHeaderFrameView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    // Layout
    @IBOutlet weak var searchFrameTrailingConstraint: NSLayoutConstraint!
    
    private let orderButton = DropdownOrderButton(order: .recentUpload)
    private var viewModel: SearchVM?
    private var cancellables: Set<AnyCancellable> = []
    
    private var status: SearchStatus = .default {
        didSet {
            switch self.status {
            case .default:
                self.hideSearchResultHeaderFrameView()
                self.hideResetTextButton()
                self.hideCancelSearchButton()
                self.searchTextField.text = ""
                self.viewModel?.removeAllSelectedTags()
                self.viewModel?.resetSearchInfos()
                self.viewModel?.fetchFavoriteTags()
                self.mainCollectionView.reloadData()
            case .searching:
                self.showCancelSearchButton()
            case .searchResult:
                self.showCancelSearchButton()
                self.showSearchResultHeaderFrameView()
                let keywoard = self.searchTextField.text ?? ""
                self.viewModel?.search(keyword: keywoard, rowCount: UICollectionView.columnCount, type: self.searchType)
                self.dismissKeyboard()
            }
        }
    }
    private var searchType: SearchType = .workbook {
        didSet {
            self.mainCollectionView.reloadData()
        }
    }
    private var searchOrder: DropdownOrderButton.SearchOrder = .recentUpload {
        didSet {
            // 정렬값에 따라 API 요청
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSearchResultHeaderView()
//        self.hideSearchResultHeaderFrameView()
        self.configureTintColor()
        self.configureRadius()
        self.configureCollectionView()
        self.configureTextField()
        self.configureViewModel()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.fetchFavoriteTags()
    }
    
    @IBAction func resetText(_ sender: Any) {
        self.searchTextField.text = ""
    }
    
    @IBAction func searchCancel(_ sender: Any) {
        self.status = .default
    }
}

extension SearchVC {
    private func configureSearchResultHeaderView() {
        self.configureSearchTypeButton()
        self.configureOrderButton()
    }
    
    private func configureSearchTypeButton() {
        // MARK: workbook, workbookGroup 선택하는 버튼 생성 로직 필요
    }
    
    private func configureOrderButton() {
        self.searchResultHeaderFrameView.addSubview(self.orderButton)
        NSLayoutConstraint.activate([
            self.orderButton.centerYAnchor.constraint(equalTo: self.searchResultHeaderFrameView.centerYAnchor),
            self.orderButton.trailingAnchor.constraint(equalTo: self.searchResultHeaderFrameView.trailingAnchor, constant: -32)
        ])
        self.orderButton.configureSearchMenu { [weak self] order in
            self?.searchOrder = order
        }
    }
    
    private func configureTintColor() {
        self.leftSearchIcon.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
        self.textResetXButton.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .lightGray)
    }
    
    private func configureRadius() {
        self.collectionViewBackgroundFrameView.configureTopCorner(radius: .cornerRadius24)
    }
    
    private func configureCollectionView() {
        self.tagsCollectionView.dataSource = self
        self.tagsCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.delegate = self
        
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        self.mainCollectionView.collectionViewLayout = flowLayout
        self.mainCollectionView.configureDefaultDesign()
        
        let tagCellNib = UINib(nibName: TagCell.identifier, bundle: nil)
        let removeableTagCellNib = UINib(nibName: RemoveableTagCell.identifier, bundle: nil)
        self.tagsCollectionView.register(tagCellNib, forCellWithReuseIdentifier: TagCell.identifier)
        self.tagsCollectionView.register(removeableTagCellNib, forCellWithReuseIdentifier: RemoveableTagCell.identifier)
        self.mainCollectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
    }
    
    private func configureTextField() {
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidTap), for: .touchDown)
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchVM(networkUsecase: networkUsecase)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard textField.text?.count ?? 0 > 0 else {
            self.hideResetTextButton()
            return
        }
        self.showResetTextButton()
        self.status = .searching
    }

    @objc func textFieldDidTap() {
        self.status = .searching
    }
}

extension SearchVC {
    private func bindAll() {
        self.bindFavoriteTags()
        self.bindSelectedTags()
        self.bindWorkbooks()
        self.bindWorkbookGroups()
    }
    
    private func bindFavoriteTags() {
        self.viewModel?.$favoriteTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                guard self?.status == .default else { return }
                self?.tagsCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSelectedTags() {
        self.viewModel?.$selectedTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                guard self?.status == .searchResult else { return }
                guard tags.isEmpty == false else {
                    self?.status = .default
                    return
                }
                self?.tagsCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbooks() {
        self.viewModel?.$searchResultWorkbooks
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbooks in
                guard self?.status == .searchResult,
                      self?.searchType == .workbook,
                      workbooks.isEmpty == false else { return }
                self?.mainCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbookGroups() {
        self.viewModel?.$searchResultWorkbookGroups
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookGroups in
                guard self?.status == .searchResult,
                      self?.searchType == .workbookGroup,
                      workbookGroups.isEmpty == false else { return }
                self?.mainCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.mainCollectionView else {
            if self.status == .default {
                guard let selectedFavoriteTag = self.viewModel?.favoriteTags[safe: indexPath.item] else { return }
                self.viewModel?.appendSelectedTag(selectedFavoriteTag)
                self.status = .searchResult
            } else {
                self.viewModel?.removeSelectedTag(at: indexPath.item)
            }
            return
        }
        // cell 클릭
    }
}

extension SearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        guard collectionView == self.mainCollectionView else {
            return self.status == .searchResult ? viewModel.selectedTags.count : viewModel.favoriteTags.count
        }
        
        guard self.status == .searchResult else {
            // 검색전 cell UI 확인
            return 0
        }
        
        return self.searchType == .workbook ? viewModel.searchResultWorkbooks.count : viewModel.searchResultWorkbookGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /// tagsCollectionView
        guard collectionView == self.mainCollectionView else {
            if self.status == .default {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else { return .init() }
                guard let tagName = self.viewModel?.favoriteTags[safe: indexPath.item]?.name else { return cell }
                cell.configure(tag: tagName)
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemoveableTagCell.identifier, for: indexPath) as? RemoveableTagCell else { return .init() }
                guard let tagName = self.viewModel?.selectedTags[safe: indexPath.item]?.name else { return cell }
                cell.configure(tag: tagName)
                return cell
            }
        }
        /// mainCollectionView
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else { return .init() }
        guard let viewModel = self.viewModel else { return cell }
        if self.searchType == .workbook {
            guard let info = self.viewModel?.searchResultWorkbooks[safe: indexPath.item] else { return cell }
            cell.configure(with: info, networkUsecase: viewModel.networkUsecase)
        } else {
            guard let info = self.viewModel?.searchResultWorkbookGroups[safe: indexPath.item] else { return cell }
            cell.configure(with: info, networkUsecase: viewModel.networkUsecase)
        }
        return cell
    }
}

extension SearchVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard collectionView == self.mainCollectionView else {
            if self.status == .default {
                guard let tagName = self.viewModel?.favoriteTags[safe: indexPath.item]?.name else { return CGSize(width: 100, height: 32) }
                return CGSize(width: tagName.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + 32, height: 32)
            } else {
                guard let tagName = self.viewModel?.selectedTags[safe: indexPath.item]?.name else { return CGSize(width: 100, height: 32) }
                return CGSize(width: tagName.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + RemoveableTagCell.horizontalMargin, height: 32)
            }
        }
        
        // mainCollectionView 의 cell 반환
        return UICollectionView.bookcoverCellSize
    }
}

extension SearchVC {
    func hideResetTextButton() {
        self.textResetXButton.isHidden = true
    }
    
    func showResetTextButton() {
        self.textResetXButton.isHidden = false
    }
    
    func hideCancelSearchButton() {
        UIView.animate(withDuration: 0.3) {
            self.searchCancelButton.alpha = 0
        }
        self.searchFrameTrailingConstraint.constant = 36
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showCancelSearchButton() {
        UIView.animate(withDuration: 0.25) {
            self.searchCancelButton.alpha = 1
        }
        self.searchFrameTrailingConstraint.constant = 73
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideSearchResultHeaderFrameView() {
        self.searchResultHeaderFrameView.isHidden = true
    }
    
    func showSearchResultHeaderFrameView() {
        self.searchResultHeaderFrameView.isHidden = false
    }
}

extension SearchVC: UITextFieldDelegate {
//    private func searchWorkbooks() {
//        self.removeChildVC()
//        self.changeChildVC(to: self.searchResultVC)
//        self.fetchResults()
//        self.isSearchTagsFromTextVC = false
//    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.status = .searchResult
        return true
    }
}
