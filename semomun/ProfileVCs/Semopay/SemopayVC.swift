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
    
    private let viewModel = SemopayVM()
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var headerFrame: UIView!
    @IBOutlet weak var payChargeList: UITableView!
    
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
    }
    private func bindPurchaseList() {
        self.viewModel.$purchaseOfEachMonth
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.payChargeList.reloadData()
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
        cell.addShadow(direction: .bottom)
        self.removeBorderAndMask(in: cell)
        
        if numberOfRowsInSection == 1 {
        // 맨 위이자 맨 아래
            self.makeCornerRadius(in: cell, at: .all)
        } else if indexPath.row == 0 {
        // 맨 위
            self.makeCornerRadius(in: cell, at: .top)
            self.addBottomDivider(in: cell)
            self.clipShadow(in: cell, at: .bottom)
        } else if indexPath.row == numberOfRowsInSection - 1 {
        // 맨 아래
            self.makeCornerRadius(in: cell, at: .bottom)
            self.clipShadow(in: cell, at: .top)
        } else {
        // 중간
            self.addBottomDivider(in: cell)
            self.clipShadow(in: cell, at: .both)
            cell.layer.shadowOffset = CGSize()
        }
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
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

// MARK: 그림자를 위한 함수들
extension SemopayVC {
    private enum ShadowClipDirection {
        case top, bottom, both
    }
    
    private enum CornerRadiusDirection {
        case top, bottom, all
    }
    
    private func removeBorderAndMask(in cell: UITableViewCell) {
        cell.contentView.layer.mask = nil
        cell.contentView.layer.sublayers?.removeAll(where: { $0.name == "Divider"})
    }
    
    private func addBottomDivider(in cell: UITableViewCell) {
        guard let dividerColor = UIColor(named: "grayLineColor") else { return }
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 39
        let border = CALayer()
        border.name = "Divider"
        border.backgroundColor = dividerColor.cgColor
        border.frame = CGRect(x: dividerMargin, y: cell.contentView.frame.size.height - dividerHeight, width: cell.contentView.frame.size.width - 2*dividerMargin, height: dividerHeight)
        cell.contentView.layer.addSublayer(border)
    }
    
    private func clipShadow(in cell: UITableViewCell, at direction: ShadowClipDirection) {
        let shadowRadius: CGFloat = 10
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        switch direction {
        case .top:
            layer.frame = .init(-shadowRadius, 0, cell.layer.frame.width+2*shadowRadius, cell.layer.frame.height+shadowRadius)
        case .bottom:
            layer.frame = .init(-shadowRadius, -shadowRadius, cell.layer.frame.width+2*shadowRadius, cell.layer.frame.height+shadowRadius)
        case .both:
            layer.frame = .init(-shadowRadius, 0, cell.layer.frame.width+2*shadowRadius, cell.layer.frame.height)
        }
        cell.layer.mask = layer
    }
    
    private func makeCornerRadius(in cell: UITableViewCell, at direction: CornerRadiusDirection) {
        let cornerRadius: CGFloat = 10
        switch direction {
        case .top:
            let path = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.contentView.layer.mask = maskLayer
        case .bottom:
            let path = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.contentView.layer.mask = maskLayer
        case .all:
            cell.contentView.layer.cornerRadius = cornerRadius
        }
    }
}
