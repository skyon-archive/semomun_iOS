//
//  HomeCategoryDetailVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/28.
//

import UIKit
import Combine

final class CategoryDetailVC: UIViewController {
    /* private */
    private let customView = CategoryDetailView()
    private let viewModel: CategoryDetailVM
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: CategoryDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = viewModel.categoryName
        self.bindAll()
        self.viewModel.fetch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.customView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.customView.invalidateCollectionViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension CategoryDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.sectionData[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBookcoverCell.identifier, for: indexPath) as? HomeBookcoverCell else { return .init() }
        let data = self.viewModel.sectionData[collectionView.tag][indexPath.item]
        cell.configure(data, networkUsecase: self.viewModel.networkUsecase)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = self.viewModel.sectionData[collectionView.tag][indexPath.item]
        self.viewModel.fetchWorkbook(wid: data.wid)
    }
}

extension CategoryDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UICollectionView.bookcoverCellSize
    }
}

extension CategoryDetailVC {
    private func bindAll() {
        self.bindTagNames()
        self.bindFetchedIndex()
        self.bindWorkbook()
        self.bindNetworkWarning()
    }
    
    private func bindTagNames() {
        self.viewModel.$tagOfDBs
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] tagOfDBs in
                guard let self = self else { return }
                self.customView.headerView.configureTagList(tagOfDBs: tagOfDBs, action: self.openTagDetailVC)
                self.customView.configureCollectionViews(tagOfDBs: tagOfDBs, delegate: self, action: self.openTagDetailVC)
                self.viewModel.fetchWorkbooks()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindFetchedIndex() {
        self.viewModel.$fetchedIndex
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] index in
                guard let index = index else { return }
                self?.customView.reloadCollectionView(at: index)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWorkbook() {
        self.viewModel.$workbookDTO
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbook in
                guard let workbook = workbook else { return }
                self?.showWorkbookDetailVC(workbookDTO: workbook)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNetworkWarning() {
        self.viewModel.$networkWarning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] content in
                guard let content = content else { return }
                self?.showAlertWithOK(title: content.0, text: content.1)
            })
            .store(in: &self.cancellables)
    }
}

extension CategoryDetailVC {
    private func openTagDetailVC(tagOfDB: TagOfDB) {
        let networkUsecase = NetworkUsecase(network: Network())
        let cellDataFetcher: HomeDetailVM<WorkbookPreviewOfDB>.CellDataFetcher = { page, order, completion in
            networkUsecase.getPreviews(tags: [tagOfDB], keyword: "", page: page, limit: 30, order: order.param, cid: nil) { _, preview in
                guard let preview = preview?.workbooks else {
                    completion(nil)
                    return
                }
                completion(preview)
            }
        }
        let vm = HomeDetailVM<WorkbookPreviewOfDB>(
            networkUsecase: networkUsecase,
            cellDataFetcher: cellDataFetcher
        )
        let vc = TagDetailVC<WorkbookPreviewOfDB>(viewModel: vm, tagOfDB: tagOfDB)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}