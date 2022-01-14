//
//  WorkBookDetailViewController.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import Foundation
import Combine
import UIKit

final class WorkbookDetailViewController: UIViewController {
    static let identifier = "WorkbookDetailViewController"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    
    @IBOutlet weak var sectionNumberLabel: UILabel!
    @IBOutlet weak var sectionListTableView: UITableView!
    
    private var dummyTitles: [String] = []
    private var viewModel: WorkbookViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableViewDelegate()
        self.bindAll()
        self.viewModel?.configureWorkbookInfo()
    }
}

extension WorkbookDetailViewController {
    func configureViewModel(to viewModel: WorkbookViewModel) {
        self.viewModel = viewModel
    }
    
    private func configureTableViewDelegate() {
        self.sectionListTableView.delegate = self
        self.sectionListTableView.dataSource = self
    }
    
    private func bindAll() {
        self.bindWorkbookInfo()
    }
    
    private func bindWorkbookInfo() {
        self.viewModel?.$workbookInfo
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] workbookInfo in
                guard let workbookInfo = workbookInfo else { return }
                self?.configureBookInfo(workbookInfo: workbookInfo)
            })
            .store(in: &self.cancellables)
    }
    
    private func configureBookInfo(workbookInfo: WorkbookInfo) {
        self.titleLabel.text = workbookInfo.title
        self.authorLabel.text = workbookInfo.author
        self.publisherLabel.text = workbookInfo.publisher
        self.releaseDateLabel.text = workbookInfo.releaseDate
        if let imageData = workbookInfo.image {
            self.bookCoverImageView.image = UIImage(data: imageData)
        } else {
            self.bookCoverImageView.image = UIImage(named: SemomunImage.warning)
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
