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
    @IBOutlet weak var tb: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "페이 충전 내역"
        
        self.headerFrame.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        self.headerFrame.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.headerFrame.layer.shadowOpacity = 0.2
        self.headerFrame.layer.shadowRadius = 2.5
        
        tb.layer.masksToBounds = false
        tb.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.7).cgColor
        tb.layer.shadowOpacity = 0.2
        tb.layer.shadowRadius = 2.5
        tb.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        self.tb.dataSource = self
        self.tb.delegate = self
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
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SemopayCell.identifier) as? SemopayCell else { return UITableViewCell() }
        
        return cell
    }
}

extension SemopayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let mainColor = UIColor(named: "mainColor") else { return nil }
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 72))
        
        let label = UILabel()
        label.frame = CGRect.init(x: tableView.frame.width/2 - 56.5, y: 32, width: 113, height: 28)
        label.text = "2022.02"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = mainColor
        label.textAlignment = .center
        
        label.layer.borderColor = mainColor.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 14
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}


