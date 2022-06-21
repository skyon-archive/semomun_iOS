//
//  SearchTagVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/14.
//

import UIKit
import Combine

final class SearchTagVC: UIViewController {
    static let identifier = "SearchTagVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var selectedTags: UICollectionView!
    @IBOutlet weak var searchTagResults: UITableView!
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel: SearchTagVM?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureTableView()
        self.configureTextField()
        self.configureViewModel()
        self.bindAll()
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension SearchTagVC {
    private func configureCollectionView() {
        self.selectedTags.dataSource = self
        self.selectedTags.delegate = self
    }
    
    private func configureTableView() {
        self.searchTagResults.cellLayoutMarginsFollowReadableWidth = false
        self.searchTagResults.separatorInset.left = 0
        self.searchTagResults.dataSource = self
        self.searchTagResults.delegate = self
    }
    
    private func configureTextField() {
        self.searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.searchTextField.delegate = self
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchTagVM(networkUsecase: networkUsecase)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else {return }
        self.viewModel?.searchTags(text: text)
    }
}

extension SearchTagVC {
    private func bindAll() {
        self.bindTags()
        self.bindSearchResults()
        self.bindWarning()
    }
    
    private func bindTags() {
        self.viewModel?.$userTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.selectedTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSearchResults() {
        self.viewModel?.$filteredTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.searchTagResults.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text, completion: nil)
            })
            .store(in: &self.cancellables)
    }
}

extension SearchTagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.userTags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallTagCell.identifier, for: indexPath) as? SmallTagCell else { return UICollectionViewCell() }
        guard let tag = self.viewModel?.userTags[indexPath.item] else { return cell }
        cell.configure(tag: tag.name)
        
        return cell
    }
}

extension SearchTagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.removeTag(index: indexPath.item)
    }
}

extension SearchTagVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.filteredTags.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTagCell.identifier, for: indexPath) as? SearchResultTagCell else { return UITableViewCell() }
        guard let tag = self.viewModel?.filteredTags[indexPath.item] else { return cell }
        cell.configure(tag: tag.name)
        
        return cell
    }
}

extension SearchTagVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tag = self.viewModel?.filteredTags[indexPath.item] else { return }
        self.viewModel?.appendTag(tag)
        self.searchTextField.text = ""
    }
}

extension SearchTagVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
