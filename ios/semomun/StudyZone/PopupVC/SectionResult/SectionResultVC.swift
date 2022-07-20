//
//  SectionResultVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class SectionResultVC: UIViewController {
    /* public */
    static let identifier = "SectionResultVC"
    static let storyboardName = "Study"
    /* private */
    @IBOutlet weak var workbookTitleLabel: UILabel!
    @IBOutlet weak var sectionNumLabel: UILabel!
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var problems: UICollectionView!
    
    private var viewModel: SectionResultVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        self.configureCollectionView()
        self.bindAll()
        self.viewModel?.calculateResult()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureViewModel(viewModel: SectionResultVM) {
        self.viewModel = viewModel
    }
}

extension SectionResultVC {
    private func configureCollectionView() {
        self.problems.dataSource = self
    }
    
    private func configureData(result: SectionResult) {
        self.scoreLabel.text = "\(result.score.removeDecimalPoint)/\(result.perfectScore.removeDecimalPoint)"
        self.timeLabel.text = result.time.toTimeString
    }
}

extension SectionResultVC {
    private func bindAll() {
        self.bindWorkbookTitle()
        self.bindSectionNum()
        self.bindSectionTitle()
        self.bindResult()
    }
    
    private func bindWorkbookTitle() {
        self.viewModel?.$workbookTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.workbookTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionNum() {
        self.viewModel?.$sectionNum
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sectionNum in
                self?.sectionNumLabel.text = String(format: "%02d", sectionNum)
            })
            .store(in: &self.cancellables)
    }
    
    private func bindSectionTitle() {
        self.viewModel?.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.sectionTitleLabel.text = title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindResult() {
        self.viewModel?.$result
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let result = result else { return }
                self?.configureData(result: result)
            })
            .store(in: &self.cancellables)
    }
}

extension SectionResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemSelectCell.identifier, for: indexPath) as? ProblemSelectCell else { return UICollectionViewCell() }
        guard let problem = self.viewModel?.problems[safe: indexPath.item] else { return cell }
        cell.configure(problem: problem, isChecked: false)
        
        return cell
    }
}
