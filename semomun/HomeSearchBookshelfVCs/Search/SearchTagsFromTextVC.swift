//
//  SearchTagsFromTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit
import Combine

final class SearchTagsFromTextVC: UIViewController {
    static let identifier = "SearchTagsFromTextVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var tags: UITableView!
    private weak var delegate: SearchControlable?
    private var viewModel: SearchTagsFromTextVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureViewModel()
        self.configureTableView()
        self.bindAll()
    }
}

// MARK: - Configure
extension SearchTagsFromTextVC {
    func configureDelegate(delegate: SearchControlable) {
        self.delegate = delegate
    }
    
    func refresh() {
        self.viewModel?.refresh()
    }
    
    private func configureUI() {
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 5
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchTagsFromTextVM(networkUsecase: networkUsecase)
    }
    
    private func configureTableView() {
        self.tags.separatorInset.left = 0
        self.tags.dataSource = self
        self.tags.delegate = self
    }
}

// MARK: - Binding
extension SearchTagsFromTextVC {
    private func bindAll() {
        self.bindTags()
    }
    
    private func bindTags() {
        self.viewModel?.$filteredTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.tags.setContentOffset(.zero, animated: true)
                self?.tags.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - TableView
extension SearchTagsFromTextVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.filteredTags.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTagCell.identifier, for: indexPath) as? SearchResultTagCell else { return UITableViewCell() }
        guard let tag = self.viewModel?.filteredTags[indexPath.row] else { return cell }
        cell.configure(tag: tag.name)
        
        return cell
    }
}

extension SearchTagsFromTextVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tag = self.viewModel?.filteredTags[indexPath.row] else { return }
        self.delegate?.append(tag: tag)
        self.viewModel?.removeAll()
    }
}
