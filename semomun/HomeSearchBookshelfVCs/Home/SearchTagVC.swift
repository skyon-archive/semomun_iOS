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
        self.configureViewModel()
        self.bindAll()
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchTag(_ sender: Any) {
        
    }
}

extension SearchTagVC {
    private func configureCollectionView() {
        self.selectedTags.collectionViewLayout = TagsLayout()
        self.selectedTags.dataSource = self
        self.selectedTags.delegate = self
    }
    
    private func configureTableView() {
        
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchTagVM(networkUsecase: networkUsecase)
    }
}

extension SearchTagVC {
    private func bindAll() {
        self.bindTags()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.selectedTags.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SearchTagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.tags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallTagCell.identifier, for: indexPath) as? SmallTagCell else { return UICollectionViewCell() }
        guard let tag = self.viewModel?.tags[indexPath.item] else { return cell }
        cell.configure(tag: tag)
        
        return cell
    }
}

extension SearchTagVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.removeTag(index: indexPath.item)
    }
}
