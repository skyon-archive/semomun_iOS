//
//  MyPurchasesVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class MyPurchasesVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "MyPurchasesVC"
    
    private let viewModel = MyPurchasesVM(networkUsecase: NetworkUsecase(network: Network()))
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var purchaseList: UITableView!
    @IBOutlet var dateRangeSelectors: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.configurePublished()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
        self.purchaseList.dataSource = self
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: Bindings
extension MyPurchasesVC {
    func bindAll() {
        self.viewModel.$purchaseListToShow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] purchaseList in
                self?.purchaseList.reloadData()
            }
            .store(in: &self.cancellables)
    }
}

extension MyPurchasesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.purchaseListToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPurchaseCell.identifier) as? MyPurchaseCell else { return UITableViewCell() }
        let purchase = self.viewModel.purchaseListToShow[indexPath.row]
        cell.configure(using: purchase)
        return cell
    }
}
