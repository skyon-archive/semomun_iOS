//
//  SelectProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/23.
//

import UIKit
import Combine

final class SelectProblemsVC: UIViewController {
    /* public */
    static let identifier = "SelectProblemsVC"
    static let storyboardName = "Study"
    /* private */
    enum Mode {
        case `default`, practiceTest
    }
    private var mode: Mode? // default, practiceTest
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var totalProblemsCountLabel: UILabel!
    @IBOutlet weak var checkingProblemsCountLabel: UILabel!
    @IBOutlet weak var allSelectIndicator: UIButton!
    @IBOutlet weak var allSelectButton: UIButton!
    @IBOutlet weak var problems: UICollectionView!
    @IBOutlet weak var startScoringBT: UIButton!
    @IBOutlet weak var problemCountLabel: UILabel!
    private var selectProblemsVM: SelectProblemsVM?
    private var showSolvedProblemsVM: ShowSolvedProblemsVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureCollectionView()
        self.bindAll()
        self.configurePracticeTestMode()
    }
    
    @IBAction func selectAllProblems(_ sender: Any) {
        self.allSelectIndicator.isSelected.toggle()
        self.selectProblemsVM?.selectAll(to: self.allSelectIndicator.isSelected)
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startScoring(_ sender: Any) {
        if self.mode == .default {
            self.selectProblemsVM?.startScoring() { [weak self] success in
                guard success == true else { return }
                self?.presentingViewController?.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: .showSectionResult, object: nil)
                })
            }
        } else {
            NotificationCenter.default.post(name: .sectionTerminated, object: nil)
            self.presentingViewController?.dismiss(animated: true)
        }
    }
}

// MARK: Public
extension SelectProblemsVC {
    func configureViewModel(viewModel: SelectProblemsVM) {
        self.selectProblemsVM = viewModel
        self.mode = .default
    }
    
    func configureViewModel(viewModel: ShowSolvedProblemsVM) {
        self.showSolvedProblemsVM = viewModel
        self.mode = .practiceTest
    }
}

// MARK: Configure
extension SelectProblemsVC {
    private func configureCollectionView() {
        self.problems.delegate = self
        self.problems.dataSource = self
    }
    
    private func configurePracticeTestMode() {
        if self.mode == .practiceTest {
            self.problemCountLabel.text = "푼 문제"
            self.allSelectIndicator.isHidden = true
            self.allSelectButton.isHidden = true
        }
    }
}

// MARK: Binding
extension SelectProblemsVC {
    private func bindAll() {
        self.bindTitle()
        self.bindProblems()
        self.bindScoreingQueue()
    }
    
    private func bindTitle() {
        self.selectProblemsVM?.$title
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.sectionTitleLabel.text = title
            })
            .store(in: &self.cancellables)
        self.showSolvedProblemsVM?.$title
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.sectionTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindProblems() {
        /// 총 문제 수
        self.selectProblemsVM?.$problems
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] problems in
                self?.totalProblemsCountLabel.text = "\(problems.count) 문제"
            })
            .store(in: &self.cancellables)
        self.showSolvedProblemsVM?.$problems
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] problems in
                self?.totalProblemsCountLabel.text = "\(problems.count) 문제"
            })
            .store(in: &self.cancellables)
    }
    
    private func bindScoreingQueue() {
        /// 채점할 문제 수
        self.selectProblemsVM?.$scoringQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scoringQueue in
                self?.checkingProblemsCountLabel.text = "\(scoringQueue.count) 문제"
                self?.problems.reloadData()
                
                if scoringQueue.isEmpty {
                    self?.preventScoring()
                } else {
                    self?.activeScoring()
                }
                
                guard let totalCount = self?.selectProblemsVM?.scoreableTotalCount else { return }
                if scoringQueue.count == totalCount {
                    self?.allSelectIndicator.isSelected = true
                } else {
                    self?.allSelectIndicator.isSelected = false
                }
            })
            .store(in: &self.cancellables)
        /// 푼 문제 수
        self.showSolvedProblemsVM?.$scoringQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scoringQueue in
                self?.checkingProblemsCountLabel.text = "\(scoringQueue.count) 문제"
                self?.problems.reloadData()
                self?.activeScoring()
            })
            .store(in: &self.cancellables)
    }
}

extension SelectProblemsVC {
    private func preventScoring() {
        self.startScoringBT.isUserInteractionEnabled = false
        self.startScoringBT.backgroundColor = UIColor(.lightGray)
    }
    
    private func activeScoring() {
        self.startScoringBT.isUserInteractionEnabled = true
        self.startScoringBT.backgroundColor = UIColor(.blueRegular)
    }
}

extension SelectProblemsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.mode {
        case .default: return self.selectProblemsVM?.problems.count ?? 0
        case .practiceTest: return self.showSolvedProblemsVM?.problems.count ?? 0
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemSelectCell.identifier, for: indexPath) as? ProblemSelectCell else { return UICollectionViewCell() }
        
        switch self.mode {
        case .default:
            guard let problem = self.selectProblemsVM?.problems[safe: indexPath.item] else { return cell }
            guard let isChecked = self.selectProblemsVM?.isChecked(at: indexPath.item) else { return cell }
            
            cell.configure(problem: problem, isChecked: isChecked)
            return cell
        case .practiceTest:
            guard let problem = self.showSolvedProblemsVM?.problems[safe: indexPath.item] else { return cell }
            guard let isSolved = self.showSolvedProblemsVM?.isSolved(at: indexPath.item) else { return cell }
            
            cell.configure(problem: problem, isChecked: isSolved)
            return cell
        default:
            return cell
        }
    }
}


extension SelectProblemsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.mode == .default else { return }
        self.selectProblemsVM?.toggle(at: indexPath.item)
    }
}
