//
//  ShowSolvedProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/22.
//

import UIKit
import Combine

final class ShowSolvedProblemsVC: UIViewController {
    static let identifier = "ShowSolvedProblemsVC"
    static let storyboardName = "Study"
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var workbookTitleLabel: UILabel!
    @IBOutlet weak var problems: UICollectionView!
    
    private var viewModel: ShowSolvedProblemsVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureCollectionView()
        self.bindAll()
    }
    
    func configureViewModel(viewModel: ShowSolvedProblemsVM) {
        self.viewModel = viewModel
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scoringProblems(_ sender: Any) {
        NotificationCenter.default.post(name: .sectionTerminated, object: nil)
        self.presentingViewController?.dismiss(animated: true)
    }
}

extension ShowSolvedProblemsVC {
    private func configureCollectionView() {
        self.problems.dataSource = self
    }
}

extension ShowSolvedProblemsVC {
    private func bindAll() {
        self.bindSectionTitle()
        self.bindScoreingQueue()
    }
    
    private func bindSectionTitle() {
        self.viewModel?.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.workbookTitleLabel.text = title // section, workbook 모두 title 동일
            })
            .store(in: &self.cancellables)
    }
    
    private func bindScoreingQueue() {
        self.viewModel?.$scoringQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.problems.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension ShowSolvedProblemsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemSelectCell.identifier, for: indexPath) as? ProblemSelectCell else { return UICollectionViewCell() }
        
        guard let problem = self.viewModel?.problems[safe: indexPath.item] else { return cell }
        guard let isSolved = self.viewModel?.isSolved(at: indexPath.item) else { return cell }
        
        cell.configure(problem: problem, isChecked: isSolved)
        return cell
    }
}
