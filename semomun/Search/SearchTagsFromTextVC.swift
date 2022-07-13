//
//  SearchTagsFromTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit
import Combine

protocol SearchTagsDelegate: AnyObject {
    func selectTag(_ tag: TagOfDB)
}

final class SearchTagsFromTextVC: UIViewController {
    static let identifier = "SearchTagsFromTextVC"
    @IBOutlet weak var collectionView: UICollectionView!
    private weak var delegate: SearchTagsDelegate?
    private var viewModel: SearchTagsFromTextVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.configureViewModel()
        self.bindAll()
    }
}

extension SearchTagsFromTextVC {
    func configureDelegate(delegate: SearchTagsDelegate) {
        self.delegate = delegate
    }
    
    private func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let tagCellNib = UINib(nibName: TagCell.identifier, bundle: nil)
        self.collectionView.register(tagCellNib, forCellWithReuseIdentifier: TagCell.identifier)
        
        let layout = TagsLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        self.collectionView.collectionViewLayout = layout
    }
    
    func refresh() {
        self.viewModel?.refresh()
    }
    
    func updateSelectedTags(tags: [TagOfDB]) {
        if self.viewModel == nil {
            self.configureViewModel()
        }
        self.viewModel?.updateSelectedTags(tags: tags)
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchTagsFromTextVM(networkUsecase: networkUsecase)
    }
}

extension SearchTagsFromTextVC {
    private func bindAll() {
        self.bindTags()
    }
    
    private func bindTags() {
        self.viewModel?.$filteredTags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SearchTagsFromTextVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = self.viewModel?.filteredTags[safe: indexPath.item] else { return }
        self.delegate?.selectTag(tag)
        self.viewModel?.refresh()
    }
}

extension SearchTagsFromTextVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.filteredTags.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as? TagCell else { return .init() }
        guard let tag = self.viewModel?.filteredTags[safe: indexPath.item] else { return cell }
        cell.configure(tag: tag.name)
        
        return cell
    }
}

extension SearchTagsFromTextVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tagName = self.viewModel?.filteredTags[safe: indexPath.item]?.name else { return CGSize(width: 100, height: 32) }
        return CGSize(width: tagName.size(withAttributes: [NSAttributedString.Key.font : UIFont.heading5]).width + 32, height: 32)
    }
}
