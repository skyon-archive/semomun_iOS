//
//  SelectProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import UIKit
import Combine

class SelectProblemsVC: UIViewController {
    static let identifier = "SelectProblemsVC"
    static let storyboardName = "Study"

    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var totalProblemsCountLabel: UILabel!
    @IBOutlet weak var checkingProblemsCountLabel: UILabel!
    @IBOutlet weak var allSelectIndicator: UIButton!
    @IBOutlet weak var problems: UICollectionView!
    @IBOutlet weak var startScoringBT: UIButton!
    private var viewModel: SelectProblemsVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureCollectionView()
        self.bindAll()
    }
    
    func configureViewModel(viewModel: SelectProblemsVM) {
        self.viewModel = viewModel
    }
    
    private func configureCollectionView() {
        self.problems.delegate = self
        self.problems.dataSource = self
    }
    
    @IBAction func selectAllProblems(_ sender: Any) {
        self.allSelectIndicator.isSelected.toggle()
        self.viewModel?.selectAll(to: self.allSelectIndicator.isSelected)
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startScoring(_ sender: Any) {
        self.viewModel?.startScoring() { [weak self] success in
            guard success == true else { return }
            self?.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .showSectionResult, object: nil)
            })
        }
    }
}

extension SelectProblemsVC {
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
                
                if scoringQueue.count == 0 {
                    self?.preventScoring()
                } else {
                    self?.activeScoring()
                }
                
                guard let totalCount = self?.viewModel?.scoreableTotalCount else { return }
                if scoringQueue.count == totalCount {
                    self?.allSelectIndicator.isSelected = true
                } else {
                    self?.allSelectIndicator.isSelected = false
                }
            })
            .store(in: &self.cancellables)
    }
}

extension SelectProblemsVC {
    private func preventScoring() {
        self.startScoringBT.isUserInteractionEnabled = false
        self.startScoringBT.alpha = 0.5
    }
    
    private func activeScoring() {
        self.startScoringBT.isUserInteractionEnabled = true
        self.startScoringBT.alpha = 1
    }
}

extension SelectProblemsVC: UICollectionViewDataSource {
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

extension SelectProblemsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.toggle(at: indexPath.item)
    }
}
