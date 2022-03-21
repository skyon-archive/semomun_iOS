//
//  SearchResultVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit
import Combine

final class SearchResultVC: UIViewController {
    static let identifier = "SearchResultVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var searchResults: UICollectionView!
    
    private weak var delegate: SearchControlable?
    private var viewModel: SearchResultVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewModel()
        self.configureCollectionView()
        self.bindAll()
    }
}

// MARK: - Configure
extension SearchResultVC {
    func configureDelegate(delegate: SearchControlable) {
        self.delegate = delegate
    }
    
    func fetch(tags: [TagOfDB], text: String) {
        self.searchResults.setContentOffset(.zero, animated: true)
        self.viewModel?.fetchSearchResults(tags: tags, text: text)
    }
    
    func removeAll() {
        self.viewModel?.removeAll()
    }
    
    private func configureViewModel() {
        let network = Network()
        let networkUsecase = NetworkUsecase(network: network)
        self.viewModel = SearchResultVM(networkUsecase: networkUsecase)
    }
    
    private func configureCollectionView() {
        self.searchResults.delegate = self
        self.searchResults.dataSource = self
    }
}

// MARK: - Binding
extension SearchResultVC {
    private func bindAll() {
        self.bindSearchResults()
        self.bindWarning()
    }
    
    private func bindSearchResults() {
        self.viewModel?.$searchResults
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.searchResults.reloadData()
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
extension SearchResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.searchResults.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.identifier, for: indexPath) as? SearchResultCell else { return UICollectionViewCell() }
        guard let preview = self.viewModel?.searchResults[indexPath.item] else { return cell }
        cell.configureNetworkUsecase(to: self.viewModel?.networkUsecase)
        cell.configure(with: preview)
        
        return cell
    }
}

extension SearchResultVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let target = self.viewModel?.searchResults[indexPath.item] else { return }
        self.delegate?.showWorkbookDetail(wid: target.wid)
    }
}

extension SearchResultVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalTerm: CGFloat = 20
        let horizontalMargin: CGFloat = 28
        let superWidth = self.searchResults.frame.width - 2*horizontalMargin
        let textHeight: CGFloat = 34
        let textHeightTerm: CGFloat = 5
        var horizontalCellCount: CGFloat = 5 // 기본의 경우 5개씩 표시
        if self.view.frame.width == 1024 { // 12인치의 경우 6개씩 표시
            horizontalCellCount = 6
        } else if self.view.frame.width == 744 { // 미니의 경우 4개씩 표시
            horizontalCellCount = 4
        }
        let width = (superWidth - ((horizontalCellCount-1)*horizontalTerm))/horizontalCellCount
        let height = (width/4)*5 + textHeightTerm + textHeight
        return CGSize(width: width, height: height)
    }
}

// MARK: Pagination 을 위한 코드
extension SearchResultVC {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         if self.searchResults.contentOffset.y >= (self.searchResults.contentSize.height - self.searchResults.bounds.size.height) {
             self.viewModel?.fetchSearchResults()
         }
     }
 }
