//
//  SideMenuViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/09/25.
//

import UIKit

protocol SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int)
}

class SideMenuViewController: UIViewController {
    @IBOutlet weak var sideMenuTableView: UITableView!
    var delegate: SideMenuViewControllerDelegate?
    var testTitles: [String] = ["수능 및 모의고사", "LEET", "공인회계사", "공인중개사", "9급 공무원"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
    }

}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as? SideMenuCell else { return UITableViewCell() }
        cell.title.text = testTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedCell(indexPath.row)
    }
}

class SideMenuCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
