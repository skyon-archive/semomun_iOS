//
//  HomeCategoryDetailVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import UIKit
import Combine

final class HomeCategoryDetailVC: UIViewController {
    /* private */
    private let customView = HomeCategoryDetailView()
    private let viewModel: HomeCategoryDetailVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: HomeCategoryDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.customView.headerView.configureTagList(["1학년", "2학년", "3학년"])
        self.customView.configureCollectionViews(tagOfDBs: [.init(tid: 0, name: "테스트1"), .init(tid: 1, name: "테스트2")], delegate: self, action: { print($0) })
        
        self.viewModel.fetch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension HomeCategoryDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sectionData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBookcoverCell.identifier, for: indexPath) as? HomeBookcoverCell else { return .init() }
        let data = self.viewModel.sectionData[indexPath.section][indexPath.item]
        cell.configure(data, networkUsecase: self.viewModel.networkUsecase)
        return cell
    }
}

extension HomeCategoryDetailVC {
    private func bindAll() {
        self.bindTagNames()
        self.bindFetchedIndex()
    }
    
    private func bindTagNames() {
        self.viewModel.$tagNames
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tagNames in
                                
            })
            .store(in: &self.cancellables)
    }
    
    private func bindFetchedIndex() {
        self.viewModel.$fetchedIndex
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] index in
                guard let index = index else { return }
                
            })
            .store(in: &self.cancellables)
    }
}
