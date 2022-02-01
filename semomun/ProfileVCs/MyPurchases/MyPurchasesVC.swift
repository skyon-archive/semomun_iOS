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
    private var selectedButtonIndex = 0
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var purchaseList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.configurePublished()
        self.configureHeaderUI()
        self.purchaseList.dataSource = self
        self.purchaseList.delegate = self
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// MARK: Bindings
extension MyPurchasesVC {
    private func bindAll() {
        self.bindPurchaseList()
        self.bindAlert()
    }
    private func bindPurchaseList() {
        self.viewModel.$purchaseListToShow
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] purchaseList in
                self?.purchaseList.reloadData()
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
                case .networkFailonStart:
                    self?.showAlertWithOK(title: "네트워크 없음", text: "") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}

// MARK: Configure
extension MyPurchasesVC {
    private func configureHeaderUI() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
    }
}

extension MyPurchasesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.purchaseListToShow[section].contents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.purchaseListToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPurchaseCell.identifier) as? MyPurchaseCell else { return UITableViewCell() }
        let purchase = self.viewModel.purchaseListToShow[indexPath.section].contents[indexPath.row]
        cell.configure(using: purchase)
        return cell
    }
}

extension MyPurchasesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeight = self.tableView(tableView, heightForHeaderInSection: section)
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: sectionHeight))
        let sectionText = self.viewModel.purchaseListToShow[section].section
        let label = SectionDateLabel(text: sectionText, filled: true)
        let labelBottomMargin: CGFloat = 12
        label.center = CGPoint(headerView.frame.midX, headerView.frame.maxY - labelBottomMargin - label.frame.height / 2)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}
