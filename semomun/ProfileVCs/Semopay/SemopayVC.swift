//
//  SemopayVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class SemopayVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SemopayVC"
    
    private let viewModel: PayHistoryVM? = PayHistoryVM(onlyPurchaseHistory: false, networkUsecase: NetworkUsecase(network: Network()))
    
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var headerFrame: UIView!
    @IBOutlet weak var payChargeList: UITableView!
    @IBOutlet weak var remainingSemopay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderUI()
        self.configureDelegates()
        self.bindAll()
        self.viewModel?.initPublished()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureScrollIndicatorInset()
    }
    
    @IBAction func charge(_ sender: Any) {
        let storyboard = UIStoryboard(name: WaitingChargeVC.storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: WaitingChargeVC.identifier)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SemopayVC {
    private func configureHeaderUI() {
        self.navigationItem.titleView?.backgroundColor = .white
        self.navigationItem.title = "페이 이용 내역"
    }
    
    private func configureDelegates() {
        self.payChargeList.dataSource = self
        self.payChargeList.delegate = self
    }
    
    private func configureScrollIndicatorInset() {
        let rightInset = (self.view.frame.width - self.payChargeList.frame.width)/2
        self.payChargeList.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -rightInset)
    }
}

// MARK: Binding
extension SemopayVC {
    private func bindAll() {
        self.bindAlert()
        self.bindPurchaseList()
        self.bindRemainingSemopay()
    }
    private func bindAlert() {
        self.viewModel?.$alert
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
    private func bindPurchaseList() {
        self.viewModel?.$purchaseOfEachMonth
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.payChargeList.reloadData()
            })
            .store(in: &self.cancellables)
    }
    private func bindRemainingSemopay() {
        self.viewModel?.$remainingSemopay
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] remainingSemopay in
                let costStr = remainingSemopay.withComma 
                self?.remainingSemopay.text = costStr + "원"
            })
            .store(in: &self.cancellables)
    }
}

extension SemopayVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.purchaseOfEachMonth.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.purchaseOfEachMonth[section].content.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SemopayCell.identifier) as? SemopayCell else { return UITableViewCell() }
        
        // Configuring cell using data
        guard let purchase = self.viewModel?.purchaseOfEachMonth[indexPath.section].content[indexPath.row] else {
            return cell
        }
        
        cell.configureCell(using: purchase)
        return cell
    }
}

extension SemopayVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.payChargeList.contentOffset.y >= (self.payChargeList.contentSize.height - self.payChargeList.bounds.size.height) {
            self.viewModel?.tryFetchMoreList()
        }
    }
}

extension SemopayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionText = self.viewModel?.purchaseOfEachMonth[section].section else {
            return nil
        }
        return SectionDateLabelFrame(text: sectionText, filled: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
}
