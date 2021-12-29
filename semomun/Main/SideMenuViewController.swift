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
        self.configureCategories()
        self.configureIndex()
        self.configureObserve()
    }
}

extension SideMenuViewController {
    private func configureCategories() {
        NetworkUsecase.getCategorys { [weak self] categorys in
            guard let categorys = categorys else {
                self?.showAlertWithOK(title: "오프라인 모드", text: "저장되어 있는 문제집에 접근할 수 있습니다.")
                self?.categorys = UserDefaults.standard.value(forKey: "categorys") as? [String] ?? []
                self?.configureIndex()
                return
            }
            UserDefaults.standard.setValue(categorys, forKey: "categorys")
            self?.categorys = categorys
            self?.configureIndex()
        }
    }
    
    private func configureIndex() {
        guard let category = UserDefaults.standard.value(forKey: "currentCategory") as? String else { return }
        self.currentIndex = self.getIndex(from: category)
        self.sideMenuTableView.reloadData()
    }
    
    private func configureObserve() {
        NotificationCenter.default.addObserver(forName: .updateCategory, object: nil, queue: .main) { [weak self] _ in
            guard let self = self,
                  let category = UserDefaults.standard.value(forKey: "currentCategory") as? String,
                  let index = self.getIndex(from: category) else { return }
            self.currentIndex = index
            self.delegate?.selectCategory(to: self.categorys[index])
            self.sideMenuTableView.reloadData()
        }
    }
    
    private func getIndex(from target: String) -> Int? {
        for (idx, category) in self.categorys.enumerated() {
            if category == target {
                return idx
            }
        }
        return nil
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
