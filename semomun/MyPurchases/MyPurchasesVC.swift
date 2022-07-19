//
//  MyPurchasesVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class MyPurchasesVC: UIViewController {
    /* private */
    private let viewModel: PayHistoryVM
    private var cancellables: Set<AnyCancellable> = []
    private let roundedBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.configureTopCorner(radius: .cornerRadius24)
        return view
    }()
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(MyPurchasesCell.self, forCellWithReuseIdentifier: MyPurchasesCell.identifier)
        view.configureDefaultDesign()
        return view
    }()
    
    init(viewModel: PayHistoryVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .getSemomunColor(.background)
        self.configureLayout()
        self.configureCollectionView()
        self.configureHeaderUI()
        self.bindAll()
        self.viewModel.fetch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            UIView.performWithoutAnimation {
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
        })
    }
}

// MARK: Configure
extension MyPurchasesVC {
    private func configureHeaderUI() {
        self.navigationItem.titleView?.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func configureLayout() {
        self.view.addSubview(self.roundedBackground)
        self.roundedBackground.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            self.roundedBackground.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.roundedBackground.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.roundedBackground.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.roundedBackground.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.collectionView.topAnchor.constraint(equalTo: self.roundedBackground.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.roundedBackground.leadingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.roundedBackground.bottomAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.roundedBackground.trailingAnchor)
        ])
    }
}

// MARK: Bindings
extension MyPurchasesVC {
    private func bindAll() {
        self.bindPurchaseList()
        self.bindAlert()
    }
    private func bindPurchaseList() {
        self.viewModel.$purchasedItems
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                guard let alert = alert else { return }
                self?.showAlertWithOK(title: alert.title, text: alert.message)
            }
            .store(in: &self.cancellables)
    }
}

extension MyPurchasesVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.purchasedItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPurchasesCell.identifier, for: indexPath) as? MyPurchasesCell else {
            return .init()
        }
        let purchasedItem = self.viewModel.purchasedItems[indexPath.item]
        cell.configureContent(purchasedItem, networkUsecase: self.viewModel.networkUsecase)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(self.view.bounds.width-UICollectionView.gridPadding*2, 147)
    }
}

extension MyPurchasesVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
            self.viewModel.fetch()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viewModel.isPaging = false
    }
}
