//
//  SemopayVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

class SemopayVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SemopayVC"
    
    private let viewModel = SemopayVM(networkUsecase: NetworkUsecase(network: Network()))
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var headerFrame: UIView!
    @IBOutlet weak var payChargeList: UITableView!
    @IBOutlet weak var remainingSemopay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderUI()
        self.configureDelegates()
        self.configureTableView()
        self.bindAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func charge(_ sender: Any) {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SemopayVC {
    private func configureHeaderUI() {
        self.navigationItem.title = "페이 충전 내역"
        self.headerFrame.addShadow(direction: .bottom)
        self.headerFrame.clipShadow(at: .top)
    }
    private func configureDelegates() {
        self.payChargeList.dataSource = self
        self.payChargeList.delegate = self
    }
    private func configureTableView() {
        self.payChargeList.clipsToBounds = false
        self.payChargeList.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -33)
    }
}

// MARK: Binding
extension SemopayVC {
    private func bindAll() {
        self.bindPurchaseList()
        self.bindRemainingSemopay()
    }
    private func bindPurchaseList() {
        self.viewModel.$purchaseOfEachMonth
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.payChargeList.reloadData()
            })
            .store(in: &self.cancellables)
    }
    private func bindRemainingSemopay() {
        self.viewModel.$remainingSemopay
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] remainingSemopay in
                guard let costStr = remainingSemopay.withComma else { return }
                self?.remainingSemopay.text = costStr + "원"
            })
            .store(in: &self.cancellables)
    }
}

extension SemopayVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.purchaseOfEachMonth.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.purchaseOfEachMonth[section].content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SemopayCell.identifier) as? SemopayCell else { return UITableViewCell() }
        // Configuring cell using data
        let purchase = self.viewModel.purchaseOfEachMonth[indexPath.section].content[indexPath.row]
        cell.configureNetworkUsecase(self.viewModel.networkUsecase)
        cell.configureCell(using: purchase)
        // Configuring cell on specific position
        let numberOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        cell.configureCellUI(row: indexPath.row, numberOfRowsInSection: numberOfRowsInSection)
        return cell
    }
}

extension SemopayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionText = self.viewModel.purchaseOfEachMonth[section].section
        return SectionDateLabelFrame(text: sectionText, filled: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}
