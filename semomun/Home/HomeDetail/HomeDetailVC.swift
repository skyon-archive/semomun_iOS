//
//  HomeDetailVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/11.
//

import UIKit
import Combine

final class HomeDetailVC<T: HomeBookcoverConfigurable>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /* private */
    private var viewModel: HomeDetailVM<T>
    private var cancellables: Set<AnyCancellable> = []
    private let collectionView: UICollectionView = {
        let flowLayout = ScrollingBackgroundFlowLayout(sectionHeaderExist: true)
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.collectionViewLayout = flowLayout
        view.configureDefaultDesign(topInset: 24)
        view.register(HomeBookcoverCell.self, forCellWithReuseIdentifier: HomeBookcoverCell.identifier)
        view.register(HomeDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeDetailHeaderView.identifier)
        
        return view
    }()
    
    init(viewModel: HomeDetailVM<T>, title: String, hasTagList: Bool) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = title
        self.view.backgroundColor = UIColor.getSemomunColor(.background)
        self.configureLayout()
        self.configureCollectionView()
        self.bindAll()
        self.viewModel.fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.cellData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBookcoverCell.identifier, for: indexPath) as? HomeBookcoverCell else { return .init() }
        
        let data = self.viewModel.cellData[indexPath.item]
        let s3ImageFetchable = self.viewModel.networkUsecase
        cell.configure(data, networkUsecase: s3ImageFetchable)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeDetailHeaderView.identifier, for: indexPath) as? HomeDetailHeaderView else { return .init() }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(self.collectionView.frame.width, 66)
    }
    
    // MARK: Pagination 을 위한 코드
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
            self.viewModel.fetchMore()
        }
    }
   
   func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
       self.viewModel.isPaging = false
   }
}

// MARK: Layout
extension HomeDetailVC {
    private func configureLayout() {
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
}

// MARK: Configure
extension HomeDetailVC {
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

// MARK: Binding
extension HomeDetailVC {
    private func bindAll() {
        self.bindData()
        self.bindWarning()
    }
    
    private func bindData() {
        self.viewModel.$cellData
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindWarning() {
        self.viewModel.$warning
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] warning in
                guard let warning = warning else { return }
                self?.showAlertWithOK(title: warning.title, text: warning.text)
            })
            .store(in: &self.cancellables)
    }
}
