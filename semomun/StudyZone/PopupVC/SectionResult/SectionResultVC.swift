//
//  SectionResultVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import Combine

final class SectionResultVC: UIViewController {
    static let identifier = "SectionResultVC"
    static let storyboardName = "Study"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressView!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var wrongProblems: UICollectionView!
    @IBOutlet weak var wrongsHight: NSLayoutConstraint!
    private var wrongs: [String] = []
    private var viewModel: SectionResultVM?
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        self.configureUI()
        self.bindAll()
        self.viewModel?.calculateResult()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureViewModel(viewModel: SectionResultVM) {
        self.viewModel = viewModel
    }
    
    private func configureDataSource() {
        self.wrongProblems.dataSource = self
    }
    
    private func configureUI() {
        self.progressView.progressWidth = 30
        self.progressView.trackColor = UIColor(.lightMainColor) ?? .lightGray
        self.progressView.progressColor = UIColor(.blueRegular) ?? .black
    }
}

extension SectionResultVC {
    private func bindAll() {
        self.bindTitle()
        self.bindResult()
    }
    
    private func bindTitle() {
        self.viewModel?.$sectionTitle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title ?? ""
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

extension SectionResultVC {
    private func configureData(result: SectionResult) {
        self.scoreLabel.text = "\(result.score.removeDecimalPoint)점"
        self.totalScoreLabel.text = "\(result.score.removeDecimalPoint) / \(result.perfectScore.removeDecimalPoint)점"
        self.totalTimeLabel.text = result.time.toTimeString
        self.configureWrongProblems(to: result.wrongProblems)
        self.setProgress(total: result.perfectScore, to: result.score)
    }
    
    private func configureWrongProblems(to problems: [String]) {
        let cellHeight: CGFloat = 27
        let verticalTerm: CGFloat = 5
        self.wrongsHight.constant = cellHeight+(cellHeight+verticalTerm)*CGFloat(problems.count/6)
        self.wrongs = problems
        self.wrongProblems.reloadData()
    }
    
    private func setProgress(total: Double, to: Double) {
        let percent = Float(to/total)
        self.progressView.setProgressWithAnimation(duration: 0.5, value: percent, from: 0)
    }
}

extension SectionResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wrongs.count == 0 ? 1 : self.wrongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WrongProblemCell.identifier, for: indexPath) as? WrongProblemCell else { return UICollectionViewCell() }
        
        if self.wrongs.count == 0 {
            cell.configure(to: "없음")
        } else {
            cell.configure(to: self.wrongs[indexPath.item])
        }
        return cell
    }
}

extension SectionResultVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 36, height: 27)
    }
}

