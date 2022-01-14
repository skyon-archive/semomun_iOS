//
//  WorkBookDetailViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import UIKit

final class WorkbookDetailViewController: UIViewController {
    static let identifier = "WorkbookDetailViewController"
    var previewCore: Preview_Core?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var sectionListTableView: UITableView!
    
    private var dummyTitles: [String] = []
    
    override func viewDidLoad() {
        self.configureBookInfo()
        self.configureDummy()
        self.configureTableViewDelegate()
    }
    
    private func configureTableViewDelegate() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
    }
    
    private func configureBookInfo() {
        self.titleLabel.text = self.previewCore?.title ?? ""
        self.authorLabel.text = "저자 정보 없음"
        self.publisherLabel.text = self.previewCore?.publisher ?? "출판사 정보 없음"
        self.releaseDateLabel.text = makeReleaseDateStr() ?? "출간일 정보 없음"
        if let imageData = previewCore?.image {
            DispatchQueue.main.async { [weak self] in
                self?.bookCoverImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    private func makeReleaseDateStr() -> String? {
        if let year = self.previewCore?.year {
            if let month = self.previewCore?.month {
                return "\(year)년 \(month)월"
            } else {
                return "\(year)년"
            }
        } else {
            return nil
        }
    }
    
    private func configureDummy() {
        (1...10).forEach { _ in
            self.dummyTitles.append("hello, hi")
        }
    }
}

extension WorkbookDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dummyTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else {
            return UITableViewCell() }
        cell.configureCell(title: self.dummyTitles[indexPath.row])
        
        return cell
    }
    
    
}
