//
//  ComprehensiveReport.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/13.
//

import UIKit

class ComprehensiveReport: UIViewController, StoryboardController {
    /* public */
    static var identifier: String = "ComprehensiveReport"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [
        .pad: "HomeSearchBookshelf"
    ]
    /* private */
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var areaResultTableView: UITableView!
    @IBOutlet weak var areaRankCollectionView: UICollectionView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureareaResultTableViewDelegate()
        self.configureAreaRankCollectionViewDelegate()
        self.configureCircularProgressView()
        self.configureRankLabel(to: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.circularProgressView.setProgressWithAnimation(duration: 0.5, value: 0.8, from: 0)
        self.configureRankLabel(to: "3")
        
        let cellCount = self.collectionView(self.areaRankCollectionView, numberOfItemsInSection: 0)
        self.areaRankCollectionView.scrollToItem(at: IndexPath(item: cellCount/2, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

// MARK: Configure
extension ComprehensiveReport {
    private func configureareaResultTableViewDelegate() {
        self.areaResultTableView.delegate = self
        self.areaResultTableView.dataSource = self
    }
    
    private func configureAreaRankCollectionViewDelegate() {
        self.areaRankCollectionView.delegate = self
        self.areaRankCollectionView.dataSource = self
    }
    
    private func configureCircularProgressView() {
        let size = self.circularProgressView.frame.size
        let center = CGPoint(size.width/2, size.height)
        self.circularProgressView.changeCircleShape(center: center, startAngle: -CGFloat.pi, endAngle: 0)
        
        self.circularProgressView.progressWidth = 35
        self.circularProgressView.trackColor = UIColor(.lightMainColor) ?? .white
        self.circularProgressView.progressColor = UIColor(.mainColor) ?? .white
    }
    
    private func configureRankLabel(to rank: String) {
        let numberAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 70, weight: .heavy)]
        let textAttribute = [NSAttributedString.Key.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 30, weight: .heavy)]
        let number = NSMutableAttributedString(string: rank, attributes: numberAttribute)
        let text = NSMutableAttributedString(string: "등급", attributes: textAttribute)
        number.append(text)
        
        self.rankLabel.attributedText = number
    }
}


extension ComprehensiveReport: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.areaResultTableView.dequeueReusableCell(withIdentifier: AreaResultCell.identifier) as? AreaResultCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ComprehensiveReport: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.areaRankCollectionView.dequeueReusableCell(withReuseIdentifier: AreaRankCell.identifier, for: indexPath) as? AreaRankCell else {
            return .init()
        }
        return cell
    }
}

extension ComprehensiveReport: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
    
    // https://stackoverflow.com/questions/34267662/how-to-center-horizontally-uicollectionview-cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let cellCount = self.collectionView(collectionView, numberOfItemsInSection: section)
        let totalCellWidth = 110 * cellCount
        let totalSpacingWidth = 10 * (cellCount - 1)

        let leftInset = max(0.0, (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2)
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
