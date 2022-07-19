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
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: PayHistoryVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .getSemomunColor(.background)
        self.configureLayout()
        self.configureHeaderUI()
        self.bindAll()
        self.viewModel.initPublished()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: Configure
extension MyPurchasesVC {
    private func configureHeaderUI() {
        self.navigationItem.titleView?.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
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
        self.viewModel.$purchaseOfEachMonth
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] purchaseList in
                self?.collectionView.reloadData()
            }
            .store(in: &self.cancellables)
    }
    private func bindAlert() {
        self.viewModel.$alert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                switch alert {
                case .none:
                    break
                case .noNetwork:
                    self?.showAlertWithOK(title: "네트워크 에러", text: "네트워크를 확인 후 다시 시도하시기 바랍니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}

extension MyPurchasesVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
            self.viewModel.tryFetchMoreList()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viewModel.isPaging = false
    }
}
