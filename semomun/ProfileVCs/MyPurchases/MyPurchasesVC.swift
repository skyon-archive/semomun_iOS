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
    
    private let viewModel: PayHistoryVM? = PayHistoryVM(onlyPurchaseHistory: true, networkUsecase: NetworkUsecase(network: Network()))
    
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var purchaseList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderUI()
        self.purchaseList.dataSource = self
        self.purchaseList.delegate = self
        self.bindAll()
        self.viewModel?.initPublished()
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
        self.viewModel?.$purchaseOfEachMonth
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] purchaseList in
                self?.purchaseList.reloadData()
            }
            .store(in: &self.cancellables)
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
}

// MARK: Configure
extension MyPurchasesVC {
    private func configureHeaderUI() {
        self.navigationItem.titleView?.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
    }
}

extension MyPurchasesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.purchaseOfEachMonth[section].content.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.purchaseOfEachMonth.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPurchaseCell.identifier) as? MyPurchaseCell else {
            return UITableViewCell()
        }
        guard let item = self.viewModel?.purchaseOfEachMonth[indexPath.section].content[indexPath.row] else {
            return cell
        }
        cell.configure(item: item, networkUsecase: NetworkUsecase(network: Network()), superWidth: self.view.frame.width)
        
        return cell
    }
}

extension MyPurchasesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionText = self.viewModel?.purchaseOfEachMonth[section].section else {
            return nil
        }
        return SectionDateLabelFrame(text: sectionText, filled: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}

extension MyPurchasesVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.purchaseList.contentOffset.y >= (self.purchaseList.contentSize.height - self.purchaseList.bounds.size.height) {
            self.viewModel?.tryFetchMoreList()
        }
    }
}
