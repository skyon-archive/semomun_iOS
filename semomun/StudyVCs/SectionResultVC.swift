//
//  SectionResultVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit

class SectionResultVC: UIViewController {
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
    var result: SectionResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureDataSource()
        self.configureUI()
        self.configureData()
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func configureDataSource() {
        self.wrongProblems.dataSource = self
    }
    
    private func configureUI() {
        self.progressView.progressWidth = 30
        self.progressView.trackColor = UIColor(.lightMainColor) ?? .lightGray
        self.progressView.progressColor = UIColor(.mainColor) ?? .black
    }
    
    private func configureData() {
        guard let result = self.result else { return }
        self.titleLabel.text = result.title
        self.scoreLabel.text = "\(result.totalScore)점"
        self.totalScoreLabel.text = "\(result.totalScore) / \(result.perfectScore)점"
        self.totalTimeLabel.text = result.totalTime.toTimeString
        self.configureWrongProblems(to: result.wrongProblems)
        self.setProgress(total: result.perfectScore, to: result.totalScore)
    }
    
    private func configureWrongProblems(to problems: [String]) {
        let cellHeight: CGFloat = 25
        let verticalTerm: CGFloat = 5
        self.wrongsHight.constant = cellHeight+(cellHeight+verticalTerm)*CGFloat(problems.count/6)
        self.wrongs = problems
        self.wrongProblems.reloadData()
    }
    
    private func setProgress(total: Double, to: Double) {
        let persent = Float(to/total)
        self.progressView.setProgressWithAnimation(duration: 0.5, value: persent, from: 0)
    }
}

extension SectionResultVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.wrongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WrongProblemCell.identifier, for: indexPath) as? WrongProblemCell else { return UICollectionViewCell() }
        
        cell.configure(to: self.wrongs[indexPath.item])
        return cell
    }
}

extension SectionResultVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 33, height: 25)
    }
}

