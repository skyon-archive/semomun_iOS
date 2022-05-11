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
}

class SearchVC: UIViewController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchInnerView: UIView!
    @IBOutlet weak var cancelSearchBT: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagList: UICollectionView!
    
    // searchView가 보일 때 상단 여백 조절용
    @IBOutlet weak var grayMarginView: UIView!
    @IBOutlet weak var containerViewTopMargin: NSLayoutConstraint!
    
    private var viewModel: SearchVM?
    private var cancellables: Set<AnyCancellable> = []
    private var currentChildVC: UIViewController?
    private var isSearchTagsFromTextVC: Bool = false
    private lazy var searchFavoriteTagsVC: UIViewController = {
        let storyboard = UIStoryboard(controllerType: SearchFavoriteTagsVC.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchFavoriteTagsVC.identifier) as? SearchFavoriteTagsVC else { return UIViewController() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    private lazy var searchTagsFromTextVC: SearchTagsFromTextVC = {
        let storyboard = UIStoryboard(controllerType: SearchTagsFromTextVC.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchTagsFromTextVC.identifier) as? SearchTagsFromTextVC else { return SearchTagsFromTextVC() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    private lazy var searchResultVC: SearchResultVC = {
        let storyboard = UIStoryboard(controllerType: SearchResultVC.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchResultVC.identifier) as? SearchResultVC else { return SearchResultVC() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: searchView)
        self.configureUI()
        self.configureViewModel()
        self.bindAll()
        self.configureCollectionView()
        self.configureTextField()
        self.changeToSearchFavoriteTagsVC()
        self.configureAddObserver()
    }
    
    @IBAction func cancelSearch(_ sender: Any) {
        self.searchTextField.text = ""
        self.viewModel?.removeAll()
    }
}

// MARK: - Configure
extension SearchVC {
    private func configureUI() {
        self.hiddenCancelSearchBT()
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.tagList.delegate = self
        self.tagList.dataSource = self
    }
    
    private func configureTextField() {
        self.searchTextField.delegate = self
        
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidTap), for: .touchDown)
    }
    
    private func configureAddObserver() {
        NotificationCenter.default.addObserver(forName: .purchaseBook, object: nil, queue: .main) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
        }
    }
}

// MARK: - Binding
extension SearchVC {
    private func bindAll() {
        self.bindTags()
        self.bindWorkbook()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.tagList.reloadData()
                self?.searchTagsFromTextVC.updateSelectedTags(tags: tags)
                self?.searchResultVC.removeAll()
                self?.dismissKeyboard()
                if tags.count > 0 {
                    self?.searchWorkbooks()
                    self?.showCancelSearchBT()
                } else if tags.count == 0 && self?.searchTextField.text == "" {
                    self?.searchTagsFromTextVC.refresh()
                    self?.changeToSearchFavoriteTagsVC()
                    self?.hiddenCancelSearchBT()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbook() {
        self.viewModel?.$workbook
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbook in
                guard let workbook = workbook else { return }
                self?.showWorkbookDetailVC(workbook: workbook)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - CollectionView
extension SearchVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.tags.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallTagCell.identifier, for: indexPath) as? SmallTagCell else { return UICollectionViewCell() }
        guard let tag = self.viewModel?.tags[indexPath.item] else { return cell }
        cell.configure(tag: tag.name)
        
        return cell
    }
}

extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.removeTag(index: indexPath.item)
    }
}

// MARK: - Logic
extension SearchVC {
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.count != 0 {
            if !self.isSearchTagsFromTextVC {
                print("change")
                self.changeToSearchTagsFromTextVC()
                self.searchResultVC.removeAll()
            }
            self.showCancelSearchBT()
        }
        NotificationCenter.default.post(name: .fetchTagsFromSearch, object: nil, userInfo: ["text" : text])
    }
    
    @objc func textFieldDidTap() {
        self.showCancelSearchBT()
        if !self.isSearchTagsFromTextVC {
            print("change")
            self.changeToSearchTagsFromTextVC()
            self.searchResultVC.removeAll()
        }
    }
    
    private func removeChildVC() {
        self.currentChildVC?.willMove(toParent: nil)
        self.currentChildVC?.view.removeFromSuperview()
        self.currentChildVC?.removeFromParent()
    }
    
    private func changeChildVC(to targetVC: UIViewController) {
        targetVC.view.frame = self.containerView.bounds
        self.containerView.addSubview(targetVC.view)
        self.addChild(targetVC)
        targetVC.didMove(toParent: self)
        
        if targetVC == self.searchResultVC {
            self.containerViewTopMargin.constant = -self.grayMarginView.frame.height
        } else {
            self.containerViewTopMargin.constant = 0
        }
    }
    
    private func fetchResults() {
        guard let tags = self.viewModel?.tags,
              let text = self.searchTextField.text else { return }
        self.searchResultVC.fetch(tags: tags, text: text)
    }
    
    private func showWorkbookDetailVC(workbook: WorkbookOfDB) {
        let storyboard = UIStoryboard(controllerType: WorkbookDetailVC.self)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(workbookDTO: workbook, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: false)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
    
    private func showWorkbookDetailVC(book: Preview_Core) {
        let storyboard = UIStoryboard(controllerType: WorkbookDetailVC.self)
        guard let workbookDetailVC = storyboard.instantiateViewController(withIdentifier: WorkbookDetailVC.identifier) as? WorkbookDetailVC else { return }
        guard let networkUsecase = self.viewModel?.networkUsecase else { return }
        let viewModel = WorkbookDetailVM(previewCore: book, networkUsecase: networkUsecase)
        workbookDetailVC.configureViewModel(to: viewModel)
        workbookDetailVC.configureIsCoreData(to: true)
        self.navigationController?.pushViewController(workbookDetailVC, animated: true)
    }
}

// MARK: - ConfigureUI {
extension SearchVC {
    private func hiddenCancelSearchBT() {
        self.cancelSearchBT.isHidden = true
    }
    
    private func showCancelSearchBT() {
        self.cancelSearchBT.isHidden = false
    }
}

// MARK: - Delegate
extension SearchVC: SearchControlable {
    func append(tag: TagOfDB) {
        self.searchTextField.text = ""
        self.viewModel?.append(tag: tag)
    }
    
    func changeToSearchFavoriteTagsVC() {
        self.removeChildVC()
        self.changeChildVC(to: self.searchFavoriteTagsVC)
        self.isSearchTagsFromTextVC = false
    }
    
    func changeToSearchTagsFromTextVC() {
        self.removeChildVC()
        self.changeChildVC(to: self.searchTagsFromTextVC)
        self.isSearchTagsFromTextVC = true
    }
    
    func showWorkbookDetail(wid: Int) {
        if let book = CoreUsecase.fetchPreview(wid: wid) {
            self.showWorkbookDetailVC(book: book)
        } else {
            self.viewModel?.fetchWorkbook(wid: wid)
        }
    }
}

extension SearchVC: UITextFieldDelegate {
    private func searchWorkbooks() {
        self.removeChildVC()
        self.changeChildVC(to: self.searchResultVC)
        self.fetchResults()
        self.isSearchTagsFromTextVC = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchResultVC.removeAll()
        self.searchWorkbooks()
        self.dismissKeyboard()
        return true
    }
}
