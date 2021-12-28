//
//  SideMenuViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/09/25.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func selectCategory(to: String)
}

class SideMenuViewController: UIViewController {
    static let identifier = "SideMenuViewController"
    
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    var delegate: SideMenuViewControllerDelegate?
    var defaultHighlightedCell: Int = 0
    var categorys: [String] = []
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.configureCategorys()
    }
}

extension SideMenuViewController {
    func configureCategorys() {
        self.categorys = UserDefaults.standard.value(forKey: "categorys") as? [String] ?? []
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categorys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell else { return UITableViewCell() }
        if let currentIndex = self.currentIndex, currentIndex == indexPath.row {
            cell.configure(to: self.categorys[indexPath.row], isSelected: true)
        } else {
            cell.configure(to: self.categorys[indexPath.row], isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentIndex = indexPath.row
        self.delegate?.selectCategory(to: self.categorys[indexPath.row])
        self.sideMenuTableView.reloadData()
    }
}
