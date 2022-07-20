//
//  SearchTagVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import UIKit
import Combine

final class SearchTagVC: UIViewController {
    /* private */
    private var cancellables: Set<AnyCancellable> = []
    private var previousUserTagCount: Int?
    private let searchTagView: SearchTagView
    private let viewModel: SearchTagVM
    
    init(viewModel: SearchTagVM, mode: SearchTagView.Mode) {
        self.searchTagView = SearchTagView(mode: mode)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.configureCollectionView()
        self.configureTextField()
        self.configureButtonAction()
        
        self.bindAll()
        self.viewModel.fetch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.searchTagView
    }
}

// MARK: Configure
extension SearchTagVC {
    private func configureCollectionView() {
        self.searchTagView.searchResultCollectionView.delegate = self
        self.searchTagView.searchResultCollectionView.dataSource = self
        self.searchTagView.searchTagCollectionView.delegate = self
        self.searchTagView.searchTagCollectionView.dataSource = self
    }
    
    private func configureTextField() {
        self.searchTagView.searchBarTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.searchTagView.searchBarTextField.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {return }
        self.viewModel.search(keyword: text)
    }
    
    private func configureButtonAction() {
        self.searchTagView.cancelButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        self.searchTagView.confirmButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.save()
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }
}

extension SearchTagVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.searchTagView.searchTagCollectionView {
            return self.viewModel.userTags.count
        } else {
            return self.viewModel.searchResult.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.searchTagView.searchTagCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemoveableTagCell.identifier, for: indexPath) as? RemoveableTagCell else { return .init() }
            let tagName = self.viewModel.userTags[indexPath.item].name
            cell.configure(tag: tagName)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else { return .init() }
            let tagName = self.viewModel.searchResult[indexPath.item].name
            cell.configure(tag: tagName)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.searchTagView.searchTagCollectionView {
            self.viewModel.removeUserTag(index: indexPath.item)
        } else {
            let tag = self.viewModel.searchResult[indexPath.item]
            self.viewModel.addUserTag(tag)
        }
    }
}

extension SearchTagVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.searchTagView.searchTagCollectionView {
            let tagName = self.viewModel.userTags[indexPath.item].name
            return CGSize(width: tagName.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + RemoveableTagCell.horizontalMargin, height: 32)
        } else {
            let tagName = self.viewModel.searchResult[indexPath.item].name
            return CGSize(width: tagName.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + 32, height: 32)
        }
    }
}

extension SearchTagVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Binding
extension SearchTagVC {
    private func bindAll() {
        self.bindTags()
        self.bindSearchResults()
        self.bindWarning()
    }
    
    private func bindTags() {
        self.viewModel.$userTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] userTags in
                self?.searchTagView.searchTagCollectionView.reloadData()
                
                // 아이템이 추가된 경우면 오른쪽 끝으로 스크롤
                if let previousUserTagCount = self?.previousUserTagCount,
                   let currentUserTagCount = self?.viewModel.userTags.count {
                    if previousUserTagCount < currentUserTagCount {
                        self?.searchTagView.searchTagCollectionView.scrollToItem(at: IndexPath(item: currentUserTagCount-1, section: 0), at: .right, animated: true)
                    }
                    self?.previousUserTagCount = currentUserTagCount
                }
                
                self?.previousUserTagCount = self?.viewModel.userTags.count
                
                if userTags.isEmpty {
                    self?.searchTagView.disableConfirmButton()
                } else {
                    self?.searchTagView.enableConfirmButton()
                }
                if userTags.count == 10 {
                    self?.searchTagView.updateSearchResultTransparent()
                } else {
                    self?.searchTagView.updateSearchResultOpaque()
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSearchResults() {
        self.viewModel.$searchResult
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.searchTagView.searchResultCollectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text, completion: nil)
            })
            .store(in: &self.cancellables)
    }
}
