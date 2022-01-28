//
//  SearchVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

protocol SearchControlable: AnyObject {
    func appendTag(name: String)
    func changeToSearchFavoriteTagsVC()
    func changeToSearchTagsFromTextVC()
}

class SearchVC: UIViewController {
    static let identifier = "SearchVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchInnerView: UIView!
    @IBOutlet weak var removeTextBT: UIView!
    @IBOutlet weak var cancelSearchBT: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBT: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tagList: UICollectionView!
    
    private var viewModel: SearchVM?
    private var cancellables: Set<AnyCancellable> = []
    private var currentChildVC: UIViewController?
    private var isSearchTagsFromTextVC: Bool = false
    private lazy var searchFavoriteTagsVC: UIViewController = {
        let storyboard = UIStoryboard(name: SearchFavoriteTagsVC.storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchFavoriteTagsVC.identifier) as? SearchFavoriteTagsVC else { return UIViewController() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    private lazy var searchTagsFromTextVC: UIViewController = {
        let storyboard = UIStoryboard(name: SearchTagsFromTextVC.storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchTagsFromTextVC.identifier) as? SearchTagsFromTextVC else { return UIViewController() }
        viewController.configureDelegate(delegate: self)
        return viewController
    }()
    private lazy var searchResultVC: SearchResultVC = {
        let storyboard = UIStoryboard(name: SearchResultVC.storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: SearchResultVC.identifier) as? SearchResultVC else { return SearchResultVC() }
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setShadow(with: searchView)
        self.configureUI()
        self.configureViewModel()
        self.bindAll()
        self.configureCollectionView()
        self.configureTextFieldAction()
        self.changeToSearchFavoriteTagsVC()
    }
    
    @IBAction func removeText(_ sender: Any) {
        self.searchTextField.text = ""
        self.hiddenRemoveTextBT()
        if self.viewModel?.tags.isEmpty ?? true {
            self.hiddenSearchBT()
        }
    }
    
    @IBAction func search(_ sender: Any) {
        self.removeChildVC()
        self.changeChildVC(to: self.searchResultVC)
        self.fetchResults()
        self.isSearchTagsFromTextVC = false
        self.dismissKeyboard()
        self.hiddenSearchBT()
    }
    
    @IBAction func cancelSearch(_ sender: Any) {
        self.changeToSearchFavoriteTagsVC()
        self.searchTextField.text = ""
        self.hiddenSearchBT()
        self.hiddenRemoveTextBT()
        self.viewModel?.removeAll()
        self.hiddenCancelSearchBT()
        self.dismissKeyboard()
    }
}

// MARK: - Configure
extension SearchVC {
    private func configureUI() {
        self.configureSearchInnerView()
        self.hiddenRemoveTextBT()
        self.hiddenSearchBT()
        self.hiddenCancelSearchBT()
    }
    
    private func configureSearchInnerView() {
        self.searchInnerView.clipsToBounds = true
        self.searchInnerView.layer.borderWidth = 2
        self.searchInnerView.layer.cornerRadius = 10
        self.searchInnerView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
    }
    
    private func configureViewModel() {
        self.viewModel = SearchVM()
    }
    
    private func configureCollectionView() {
        self.tagList.delegate = self
        self.tagList.dataSource = self
    }
    
    private func configureTextFieldAction() {
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
}

// MARK: - Binding
extension SearchVC {
    private func bindAll() {
        self.bindTags()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.tagList.reloadData()
                if tags.count > 0 {
                    self?.showSearchBT()
                    self?.showCancelSearchBT()
                } else if tags.count == 0 {
                    self?.hiddenSearchBT()
                }
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
        guard let tag = self.viewModel?.tag(index: indexPath.item) else { return cell }
        cell.configure(tag: tag)
        
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
        if text.count == 0 {
            self.hiddenSearchBT()
            self.hiddenRemoveTextBT()
        } else {
            if !self.isSearchTagsFromTextVC {
                print("change")
                self.changeToSearchTagsFromTextVC()
            }
            self.showRemoveTextBT()
            self.showSearchBT()
            self.showCancelSearchBT()
        }
        NotificationCenter.default.post(name: .fetchTagsFromSearch, object: nil, userInfo: ["text" : text])
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
    }
    
    private func fetchResults() {
        guard let tags = self.viewModel?.tags,
              let text = self.searchTextField.text else { return }
        self.searchResultVC.fetch(tags: tags, text: text)
    }
}

// MARK: - ConfigureUI {
extension SearchVC {
    private func hiddenRemoveTextBT() {
        self.removeTextBT.isHidden = true
    }
    
    private func hiddenSearchBT() {
        self.searchBT.isHidden = true
    }
    
    private func hiddenCancelSearchBT() {
        self.cancelSearchBT.isHidden = true
    }
    
    private func showRemoveTextBT() {
        self.removeTextBT.isHidden = false
    }
    
    private func showSearchBT() {
        self.searchBT.isHidden = false
    }
    
    private func showCancelSearchBT() {
        self.cancelSearchBT.isHidden = false
    }
}

// MARK: - Delegate
extension SearchVC: SearchControlable {
    func appendTag(name: String) {
        self.viewModel?.append(tag: name)
        self.searchTextField.text = ""
        self.hiddenRemoveTextBT()
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
}