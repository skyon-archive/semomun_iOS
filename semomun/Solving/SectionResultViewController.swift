//
//  SectionResultViewController.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit

class SectionResultViewController: UIViewController {
    static let identifier = "SectionResultViewController"
    
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
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
        self.frameView.clipsToBounds = true
        self.frameView.layer.cornerRadius = 25
    }
    
    private func configureData() {
        guard let result = self.result else { return }
        self.titleLabel.text = result.title
        self.totalScoreLabel.text = "\(result.totalScore) / \(result.perfectScore)"
        self.totalTimeLabel.text = result.totalTime.toTimeString()
        self.configureWrongProblems(to: result.wrongProblems)
    }
    
    private func configureWrongProblems(to problems: [String]) {
        let cellHeight: Int = 25
        self.wrongsHight.constant = CGFloat(cellHeight*(1+problems.count/6))
        self.wrongs = problems
        self.wrongProblems.reloadData()
    }
}

extension SectionResultViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.wrongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WrongProblemCell.identifier, for: indexPath) as? WrongProblemCell else { return UICollectionViewCell() }
        
        cell.configure(to: self.wrongs[indexPath.item])
        return cell
    }
}

extension SectionResultViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 33, height: 25)
    }
}
