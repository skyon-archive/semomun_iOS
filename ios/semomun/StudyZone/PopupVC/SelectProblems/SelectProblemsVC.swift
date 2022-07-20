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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var workbookTitleLabel: UILabel!
    @IBOutlet weak var sectionNumLabel: UILabel!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var showPastResultButton: UIButton!
    @IBOutlet weak var problems: UICollectionView!
    @IBOutlet weak var scoringSelectedProblemsButton: UIButton!
    @IBOutlet weak var scoringAllProblemsButton: UIButton!
    
    private var selectProblemsVM: SelectProblemsVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureCollectionView()
        self.bindAll()
    }
    
    @IBAction func close(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showPastResult(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .showSectionResult, object: nil)
        })
    }
    
    @IBAction func scoringSelectedProblems(_ sender: Any) {
        self.selectProblemsVM?.startSelectedScoring { [weak self] success in
            guard success == true else { return }
            self?.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .showSectionResult, object: nil)
            })
        }
    }
    
    @IBAction func scoringAllProblems(_ sender: Any) {
        self.selectProblemsVM?.startAllScoring { [weak self] success in
            guard success == true else { return }
            self?.presentingViewController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .showSectionResult, object: nil)
            })
        }
    }
}

// MARK: Public
extension SelectProblemsVC {
    func configureViewModel(viewModel: SelectProblemsVM) {
        self.selectProblemsVM = viewModel
    }
}

// MARK: Configure
extension SelectProblemsVC {
    private func configureCollectionView() {
        self.problems.delegate = self
        self.problems.dataSource = self
    }
}

// MARK: Binding
extension SelectProblemsVC {
    private func bindAll() {
        self.bindWorkbookTitle()
        self.bindSectionNum()
        self.bindSectionTitle()
        self.bindScoreingQueue()
        self.bindTotalCount()
        self.bindShowPastResult()
    }
    
    private func bindWorkbookTitle() {
        self.selectProblemsVM?.$workbookTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.workbookTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionNum() {
        self.selectProblemsVM?.$sectionNum
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sectionNum in
                self?.sectionNumLabel.text = String(format: "%02d", sectionNum)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionTitle() {
        self.selectProblemsVM?.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.sectionTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindScoreingQueue() {
        self.selectProblemsVM?.$scoringQueue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scoringQueue in
                self?.scoringSelectedProblemsButton.setTitle("선택한 \(scoringQueue.count)문제 채점", for: .normal)
                if scoringQueue.isEmpty {
                    self?.preventScoring()
                } else {
                    self?.activeScoring()
                }
                
                self?.problems.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindTotalCount() {
        self.selectProblemsVM?.$scoreableTotalCount
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] count in
                self?.scoringAllProblemsButton.setTitle("\(count)문제 전체 채점", for: .normal)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindShowPastResult() {
        self.selectProblemsVM?.$showPastResult
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] active in
                guard active == true else { return }
                self?.showPastResultButton.backgroundColor = UIColor.getSemomunColor(.background)
                self?.showPastResultButton.setTitleColor(UIColor.getSemomunColor(.black), for: .normal)
                self?.showPastResultButton.isUserInteractionEnabled = true
            })
            .store(in: &self.cancellables)
    }
}

extension SelectProblemsVC {
    private func preventScoring() {
        self.scoringSelectedProblemsButton.isUserInteractionEnabled = false
        self.scoringSelectedProblemsButton.backgroundColor = UIColor.systemGray4
        self.scoringSelectedProblemsButton.setTitleColor(UIColor.getSemomunColor(.white), for: .normal)
    }
    
    private func activeScoring() {
        self.scoringSelectedProblemsButton.isUserInteractionEnabled = true
        self.scoringSelectedProblemsButton.backgroundColor = UIColor.getSemomunColor(.background)
        self.scoringSelectedProblemsButton.setTitleColor(UIColor.getSemomunColor(.blueRegular), for: .normal)
    }
}

extension SelectProblemsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectProblemsVM?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemSelectCell.identifier, for: indexPath) as? ProblemSelectCell else { return UICollectionViewCell() }
        
        guard let problem = self.selectProblemsVM?.problems[safe: indexPath.item] else { return cell }
        guard let isChecked = self.selectProblemsVM?.isChecked(at: indexPath.item) else { return cell }
        
        cell.configure(problem: problem, isChecked: isChecked)
        return cell
    }
}


extension SelectProblemsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectProblemsVM?.toggle(at: indexPath.item)
    }
}
