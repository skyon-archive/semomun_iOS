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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as? SideMenuCell else { return UITableViewCell() }
        cell.title.text = categorys[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectCategory(to: self.categorys[indexPath.row])
        self.sideMenuTableView.deselectRow(at: indexPath, animated: true)
    }
}

class SideMenuCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
