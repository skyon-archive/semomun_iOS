//
//  HomeTagDetailVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/12.
//

import UIKit
import Combine

final class HomeTagDetailVC: HomeDetailVC<WorkbookPreviewOfDB> {
    private var tags: [String] = []
    
    init(viewModel: HomeTagDetailVM, title: String) {
        super.init(viewModel: viewModel, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindTag()
        self.viewModel.fetch()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) as? HomeDetailHeaderView else { return .init() }
        
        view.configureTagList(editAction: { [weak self] in
            let storyboard = UIStoryboard(name: SearchTagVC.storyboardName, bundle: nil)
            guard let searchTagVC = storyboard.instantiateViewController(withIdentifier: SearchTagVC.identifier) as? SearchTagVC else { return }
            self?.present(searchTagVC, animated: true, completion: nil)
        })
        view.tagList.updateTagList(tagNames: self.tags)
        
        return view
    }
}

// MARK: Configure
extension HomeTagDetailVC {
    private func bindTag() {
        guard let viewModel = self.viewModel as? HomeTagDetailVM else { return }
        viewModel.$tags
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tags in
                self?.tags = tags
                self?.collectionView.collectionViewLayout.invalidateLayout()
            })
            .store(in: &self.cancellables)
    }
}
