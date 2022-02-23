//
//  SelectProblemVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import UIKit
import Combine

class SelectProblemVC: UIViewController {
    static let identifier = "SelectProblemVC"
    static let storyboardName = "Study"

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var totalProblemsCountLabel: UILabel!
    @IBOutlet weak var checkingProblemsCountLabel: UILabel!
    @IBOutlet weak var allSelectIndicator: UIButton!
    @IBOutlet weak var problems: UICollectionView!
    @IBOutlet weak var startScoringBT: UIButton!
    private var viewModel: SelectProblemVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.bindAll()
    }
    
    func configureViewModel(viewModel: SelectProblemVM) {
        self.viewModel = viewModel
    }
    
    private func configureCollectionView() {
        self.problems.delegate = self
        self.problems.dataSource = self
    }
}

extension SelectProblemVC {
    private func bindAll() {
        self.bindTitle()
        self.bindProblems()
        self.bindScoreingQueue()
    }
    
    private func bindTitle() {
        self.viewModel?.$title
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.sectionTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindProblems() {
        self.viewModel?.$problems
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] problems in
                self?.totalProblemsCountLabel.text = "\(problems.count) 문제"
            })
            .store(in: &self.cancellables)
    }
    
    private func bindScoreingQueue() {
        self.viewModel?.$scoringQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scoringQueue in
                self?.checkingProblemsCountLabel.text = "\(scoringQueue.count) 문제"
                self?.problems.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension SelectProblemVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemSelectCell.identifier, for: indexPath) as? ProblemSelectCell else { return UICollectionViewCell() }
        guard let problem = self.viewModel?.problems[indexPath.item] else { return cell }
        guard let isChecked = self.viewModel?.isChecked(at: indexPath.item) else { return cell }
        
        cell.configure(problem: problem, isChecked: isChecked)
        return cell
    }
}

extension SelectProblemVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.toggle(at: indexPath.item)
    }
}
