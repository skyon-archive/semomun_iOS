//
//  SearchFavoriteTagsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/25.
//

import UIKit
import Combine

final class SearchFavoriteTagsVC: UIViewController, StoryboardController {
    static let identifier = "SearchFavoriteTagsVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [.pad: "HomeSearchBookshelf", .phone: "HomeSearchBookshelf_phone"]
    
    @IBOutlet weak var tags: UICollectionView!
    private weak var delegate: SearchControlable?
    private var viewModel: SearchFavoriteTagsVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.fetchTags()
    }
}

// MARK: - Configure
extension SearchFavoriteTagsVC {
    func configureDelegate(delegate: SearchControlable) {
        self.delegate = delegate
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchFavoriteTagsVM(networkUsecsae: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.tags.delegate = self
        self.tags.dataSource = self
        self.tags.collectionViewLayout = TagsLayout()
    }
}

// MARK: - Binding
extension SearchFavoriteTagsVC {
    private func bindAll() {
        self.bindTags()
        self.bindError()
        self.bindWarning()
    }
    
    private func bindTags() {
        self.viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.tags.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindError() {
        self.viewModel?.$error
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] error in
                guard let error = error else { return }
                self?.showAlertWithOK(title: "네트워크 에러", text: error)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel?.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.0, text: warning.1)
            })
            .store(in: &self.cancellables)
    }
}

// MARK: - CollectionView
extension SearchFavoriteTagsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.viewModel?.tags.count ?? 0
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else { return UICollectionViewCell() }
//        guard let tag = self.viewModel?.tags[indexPath.item] else { return cell }
//        cell.configure(tag: tag.name)
//
//        return cell
        return UICollectionViewCell()
    }
}

extension SearchFavoriteTagsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = self.viewModel?.tags[indexPath.item] else { return }
        self.delegate?.append(tag: tag)
//        self.delegate?.changeToSearchTagsFromTextVC()
    }
}
