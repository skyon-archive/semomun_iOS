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
        
        self.navigationItem.title = "페이 충전 내역"
        
        self.headerFrame.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        self.headerFrame.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.headerFrame.layer.shadowOpacity = 0.2
        self.headerFrame.layer.shadowRadius = 2.5
        
        self.payChargeList.dataSource = self
        self.payChargeList.delegate = self
        self.payChargeList.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -33)
        self.payChargeList.clipsToBounds = false
        
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
                self?.remainingSemopay.text = remainingSemopay.withComma() + "원"
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
        
        let purchase = self.viewModel.purchaseOfEachMonth[indexPath.section].content[indexPath.row]
        cell.configureCell(using: purchase)
        
        let numberOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if numberOfRowsInSection == 1 {
            cell.configureCellUI(at: .oneAndOnly)
        } else if indexPath.row == 0 {
            cell.configureCellUI(at: .top)
        } else if indexPath.row == numberOfRowsInSection - 1 {
            cell.configureCellUI(at: .bottom)
        } else {
            cell.configureCellUI(at: .middle)
        }
        return cell
    }
}

extension SemopayVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeight = self.tableView(tableView, heightForHeaderInSection: section)
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: sectionHeight))
        let sectionText = self.viewModel.purchaseOfEachMonth[section].section
        guard let label = makeSectionLabel(text: sectionText) else { return nil }
        let labelHeight: CGFloat = 28
        let labelWidth: CGFloat = 113
        let xPos = (headerView.frame.width - labelWidth) / 2
        let labelBottomMargin: CGFloat = 12
        let yPos = headerView.frame.height - labelBottomMargin - labelHeight
        label.frame = CGRect.init(x: xPos, y: yPos, width: labelWidth, height: labelHeight)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
}

extension SemopayVC {
    private func makeSectionLabel(text: String) -> UILabel? {
        guard let mainColor = UIColor(named: "mainColor") else { return nil }
        guard let backgroundColor = UIColor(named: "tableViewBackground") else { return nil }
        
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.clipsToBounds = true
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = mainColor
        label.textAlignment = .center
        label.layer.borderColor = mainColor.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 14
        return label
    }
}


