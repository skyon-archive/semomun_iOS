//
//  MyPurchasesVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class MyPurchasesVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "MyPurchasesVC"
    
    @IBOutlet weak var tb: UITableView!
    @IBOutlet var dateRangeSelectors: [UIButton]!
    @IBOutlet weak var selectorBg: UIView!
    
    private var selectedRange: DateRange = .all {
        willSet {
            guard let mainColor = UIColor(named: "mainColor") else { return }
            if let button = button(inChargeOf: self.selectedRange) {
                button.backgroundColor = .white
                button.setTitleColor(mainColor, for: .normal)
            }
            if let button = button(inChargeOf: newValue) {
                button.backgroundColor = mainColor
                button.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    private let dateRangeForEachButtons: [Int: DateRange] = [
        0: .all,
        1: .three,
        2: .six,
        3: .twelve
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "구매내역"
        
        for index in dateRangeSelectors.indices {
            let action = UIAction { _ in
                self.selectedRange = self.dateRange(ofButtonWithIndex: index) ?? .all
            }
            dateRangeSelectors[index].addAction(action, for: .touchUpInside)
        }
        
        self.selectedRange = .all
        
        self.tb.dataSource = self
        
        self.tb.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension MyPurchasesVC {
    private enum DateRange {
        case all, three, six, twelve
    }
    
    private func dateRange(ofButtonWithIndex index: Int) -> DateRange? {
        return dateRangeForEachButtons[index, default: .all]
    }
    
    private func button(inChargeOf dateRange: DateRange) -> UIButton? {
        guard let index = dateRangeForEachButtons.first(where: { $0.value == dateRange })?.key else { return nil }
        return dateRangeSelectors[index]
    }
}

extension MyPurchasesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPurchaseCell.identifier) as? MyPurchaseCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            
        } else {
            
        }
        return cell
    }
}

extension MyPurchaseCell: UITableViewDelegate {
}
