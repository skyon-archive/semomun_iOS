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
                self.hideResetTextButton()
                self.hideCancelSearchButton()
                self.searchTextField.text = ""
                self.searchOrder = .recentUpload
                self.viewModel?.removeAllSelectedTags()
                self.viewModel?.resetSearchInfos()
                self.viewModel?.fetchFavoriteTags()
                self.mainCollectionView.reloadData()
            case .searching:
                self.showCancelSearchButton()
            case .searchResult:
                self.showCancelSearchButton()
                self.viewModel?.search(keyword: self.searchTextField.text ?? "", rowCount: UICollectionView.columnCount, type: self.searchType, order: self.searchOrder)
                self.dismissKeyboard()
            }
        }
    }
    private var searchType: SearchType = .workbook {
        didSet {
            guard self.status == .searchResult else { return }
            self.viewModel?.search(keyword: self.searchTextField.text ?? "", rowCount: UICollectionView.columnCount, type: self.searchType, order: self.searchOrder)
            self.mainCollectionView.reloadData()
        }
    }
    private var searchOrder: DropdownOrderButton.SearchOrder = .recentUpload {
        didSet {
            guard self.status == .searchResult else { return }
            self.status = .searchResult
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureTintColor()
        self.configureRadius()
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
    private func configureTintColor() {
        self.leftSearchIcon.setSVGTintColor(to: UIColor.getSemomunColor(.lightGray))
        self.textResetXButton.setImageWithSVGTintColor(image: UIImage(.xOutline), color: .lightGray)
    }
    
    private func configureRadius() {
        self.collectionViewBackgroundFrameView.configureTopCorner(radius: .cornerRadius24)
        self.mainCollectionView.configureTopCorner(radius: .cornerRadius24)
    }
    
    private func configureCollectionView() {
        self.tagsCollectionView.dataSource = self
        self.tagsCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        self.mainCollectionView.delegate = self
        
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        self.mainCollectionView.collectionViewLayout = flowLayout
        self.mainCollectionView.configureDefaultDesign(topInset: 24)
        
        let tagCellNib = UINib(nibName: TagCell.identifier, bundle: nil)
        let removeableTagCellNib = UINib(nibName: RemoveableTagCell.identifier, bundle: nil)
        self.tagsCollectionView.register(tagCellNib, forCellWithReuseIdentifier: TagCell.identifier)
        self.tagsCollectionView.register(removeableTagCellNib, forCellWithReuseIdentifier: RemoveableTagCell.identifier)
        self.mainCollectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        self.mainCollectionView.register(SearchResultHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchResultHeaderView.identifier)
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
        self.bindWorkbookDetail()
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
    
    private func bindWorkbookDetail() {
        self.viewModel?.$workbookDetailInfo
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookDTO in
                guard let workbookDTO = workbookDTO,
                      self?.status == .searchResult,
                      self?.searchType == .workbook else { return }
                self?.showWorkbookDetailVC(workbookDTO: workbookDTO)
            })
            .store(in: &self.cancellables)
    }
}

extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// tagsCollectionView
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
        /// mainCollectionView
        guard self.status == .searchResult else { return }
        if self.searchType == .workbook {
            guard let workbook = self.viewModel?.searchResultWorkbooks[safe: indexPath.item] else { return }
            if let workbookCore = CoreUsecase.fetchPreview(wid: workbook.wid) {
                self.showWorkbookDetailVC(workbookCore: workbookCore)
            } else {
                self.viewModel?.fetchWorkbookDetailInfo(wid: workbook.wid)
            }
        } else {
            guard let workbookGroup = self.viewModel?.searchResultWorkbookGroups[safe: indexPath.item] else { return }
            if let workbookGroupCore = CoreUsecase.fetchWorkbookGroup(wgid: workbookGroup.wgid) {
                self.showWorkbookGroupDetailVC(workbookGroupCore: workbookGroupCore)
            } else {
                self.showWorkbookGroupDetailVC(workbookGroupDTO: workbookGroup)
            }
        }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SearchResultHeaderView.identifier, for: indexPath) as? SearchResultHeaderView else { return .init() }
        guard collectionView == self.mainCollectionView,
              self.status == .searchResult else {
            header.isHidden = true
            return header
        }
        header.isHidden = false
        header.configure(delegate: self, workbookCount: 30, workbookGroupCount: 5)
        return header
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard collectionView == self.mainCollectionView,
              self.status == .searchResult else {
            return CGSize.zero
        }
        return CGSize(collectionView.bounds.width, 66)
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

extension SearchVC {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         guard self.status == .searchResult else { return }
         guard self.mainCollectionView.contentOffset.y >= (self.mainCollectionView.contentSize.height - self.mainCollectionView.bounds.size.height) else { return }
         
         if self.searchType == .workbook {
             self.viewModel?.fetchWorkbooks(rowCount: UICollectionView.columnCount, order: self.searchOrder)
         } else {
             self.viewModel?.fetchWorkbookGroups(rowCount: UICollectionView.columnCount, order: self.searchOrder)
         }
     }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viewModel?.isPaging = false
    }
 }

extension SearchVC: SearchOrderDelegate {
    func changeOrder(to order: DropdownOrderButton.SearchOrder) {
        self.searchOrder = order
    }
    
    func changeType(to type: SearchType) {
        self.searchType = type
    }
}
