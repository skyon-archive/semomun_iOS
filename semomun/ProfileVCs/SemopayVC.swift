//
//  SemopayVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class SemopayVC: UIViewController {
    static let storyboardName = "Profile"
    static let identifier = "SemopayVC"
    
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
        
        self.payChargeList.clipsToBounds = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension SemopayVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 100
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SemopayCell.identifier) as? SemopayCell, let dividerColor = UIColor(named: "grayLineColor") else { return UITableViewCell() }
        
        let numberOfRowsInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let cornerRadius: CGFloat = 10
        let dividerHeight: CGFloat = 0.25
        let dividerMargin: CGFloat = 39

        cell.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 2.5
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.cornerRadius = 10
        
        cell.contentView.layer.mask = nil
        cell.contentView.layer.sublayers = nil

        if numberOfRowsInSection == 1 {
        // 맨 위이자 맨 아래
            cell.contentView.layer.cornerRadius = cornerRadius
        } else if indexPath.row == 0 {
        // 맨 위
            let path = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.contentView.layer.mask = maskLayer

            let border = CALayer()
            border.backgroundColor = dividerColor.cgColor
            border.frame = CGRect(x: dividerMargin, y: cell.contentView.frame.size.height - dividerHeight, width: cell.contentView.frame.size.width - 2*dividerMargin, height: dividerHeight)
            cell.contentView.layer.addSublayer(border)
            
            let layer = CALayer()
            layer.frame = .init(-5, -5, cell.layer.frame.width+10, cell.layer.frame.height+5)
            layer.backgroundColor = UIColor.white.cgColor
            cell.layer.mask = layer

        } else if indexPath.row == numberOfRowsInSection - 1 {
        // 맨 아래
            let path = UIBezierPath(roundedRect: cell.contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.contentView.layer.mask = maskLayer
            
            let layer = CALayer()
            layer.frame = .init(-5, 0, cell.layer.frame.width+10, cell.layer.frame.height+5)
            layer.backgroundColor = UIColor.white.cgColor
            cell.layer.mask = layer
        } else {
        // 중간
            let border = CALayer()
            border.backgroundColor = dividerColor.cgColor
            border.frame = CGRect(x: dividerMargin, y: cell.contentView.frame.size.height - dividerHeight, width: cell.contentView.frame.size.width - 2*dividerMargin, height: dividerHeight)
            cell.contentView.layer.addSublayer(border)
            
            let layer = CALayer()
            layer.frame = .init(-5, 0, cell.layer.frame.width+10, cell.layer.frame.height)
            layer.backgroundColor = UIColor.white.cgColor
            cell.layer.mask = layer
        }
        cell.contentView.clipsToBounds = false
        cell.clipsToBounds = false
        return cell
    }
}

extension SemopayVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let mainColor = UIColor(named: "mainColor") else { return nil }
        guard let backgroundColor = UIColor(named: "tableViewBackground") else { return nil}
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 72))
        
        let label = UILabel()
        label.backgroundColor = backgroundColor
        label.clipsToBounds = true
        label.frame = CGRect.init(x: tableView.frame.width/2 - 56.5, y: 32, width: 113, height: 28)
        label.text = "2022.02"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = mainColor
        label.textAlignment = .center
        
        label.layer.borderColor = mainColor.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 14
        label.layer.shadowOpacity = 0
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
}


