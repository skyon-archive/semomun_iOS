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
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.heading5
        label.textColor = UIColor.getSemomunColor(.lightGray)
        label.text = "아직 구매내역이 없어요"
        return label
    }()
    
    init(viewModel: PayHistoryVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.configureLayout()
        self.configureCollectionView()
        self.configureUI()
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
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func configureUI() {
        self.view.backgroundColor = .getSemomunColor(.background)
        self.navigationItem.title = "구매내역"
    }
    
    private func configureEmptyLabel() {
        self.collectionView.addSubview(self.emptyLabel)
        NSLayoutConstraint.activate([
            self.emptyLabel.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
            self.emptyLabel.topAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: 24)
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
            .sink { [weak self] purchasedItems in
                if purchasedItems.isEmpty == true {
                    self?.configureEmptyLabel()
                } else {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                switch alert {
                case .networkError:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크를 확인 후 다시 시도하시기 바랍니다.")
                case .nothingFetched:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크를 확인 후 다시 시도하시기 바랍니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .none:
                    break
                }
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
        cell.prepareForReuse(purchasedItem, networkUsecase: self.viewModel.networkUsecase)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(collectionView.bounds.width-UICollectionView.gridPadding*2, 147)
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