//
//  ComprehensiveReportVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/13.
//

import UIKit

class ComprehensiveReportVC: UIViewController, StoryboardController {
    /* public */
    static var identifier: String = "ComprehensiveReport"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [
        .pad: "HomeSearchBookshelf"
    ]
    /* private */
    private let areaRankCellSize = CGSize(width: 110, height: 100)
    private let areaRankCellSpacing: CGFloat = 16
    
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var areaResultTableView: UITableView!
    @IBOutlet weak var areaRankCollectionView: UICollectionView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureareaResultTableViewDelegate()
        self.configureAreaRankCollectionView()
        self.configureCircularProgressView()
        self.configureRankLabel(to: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // 임시 로직, VM이 생기면 binding 쪽으로 이동될 것이라 예상
        self.circularProgressView.setProgressWithAnimation(duration: 0.5, value: 0.8, from: 0)
        self.configureRankLabel(to: "3")
        self.updateAreaRankCollectionViewToCenter()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.areaRankCollectionView.performBatchUpdates { [weak self] in
                self?.areaRankCollectionView.collectionViewLayout.invalidateLayout()
            }
        })
    }
}

// MARK: Configure
extension ComprehensiveReportVC {
    private func configureareaResultTableViewDelegate() {
        self.areaResultTableView.delegate = self
        self.areaResultTableView.dataSource = self
    }
    
    private func configureAreaRankCollectionView() {
        self.areaRankCollectionView.delegate = self
        self.areaRankCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = self.areaRankCellSpacing
        self.areaRankCollectionView.collectionViewLayout = layout
    }
    
    private func configureCircularProgressView() {
        self.circularProgressView.progressWidth = 35
        self.circularProgressView.trackColor = UIColor(.lightMainColor) ?? .white
        self.circularProgressView.progressColor = UIColor(.mainColor) ?? .white
        
        let size = self.circularProgressView.frame.size
        let center = CGPoint(size.width/2, size.height)
        self.circularProgressView.changeCircleShape(center: center, startAngle: -CGFloat.pi, endAngle: 0)
    }
    
    private func configureRankLabel(to rank: String) {
        let numberAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 70, weight: .heavy)
        ]
        let textAttribute = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .heavy)
        ]
        
        let number = NSMutableAttributedString(string: rank, attributes: numberAttribute)
        let text = NSMutableAttributedString(string: "등급", attributes: textAttribute)
        number.append(text)
        
        self.rankLabel.attributedText = number
    }
}

// MARK: Update
extension ComprehensiveReportVC {
    private func updateAreaRankCollectionViewToCenter() {
        let cellCount = self.collectionView(self.areaRankCollectionView, numberOfItemsInSection: 0)
        self.areaRankCollectionView.scrollToItem(at: IndexPath(item: cellCount/2, section: 0), at: .centeredHorizontally, animated: false)
    }
}


extension ComprehensiveReportVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.areaResultTableView.dequeueReusableCell(withIdentifier: AreaResultCell.identifier) as? AreaResultCell else {
            return UITableViewCell()
        }
        cell.prepareForReuse(index: indexPath.row+1, areaTitle: "화법과 작문", rawScore: 92, deviation: 128, percentile: 96)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ComprehensiveReportVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.areaRankCollectionView.dequeueReusableCell(withReuseIdentifier: AreaRankCell.identifier, for: indexPath) as? AreaRankCell else {
            return .init()
        }
        return cell
    }
}

extension ComprehensiveReportVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 110)
    }
    
    // MARK: 셀 중앙 정렬
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let cellCount = self.collectionView(collectionView, numberOfItemsInSection: section)
        let totalCellWidth = self.areaRankCellSize.width * CGFloat(cellCount)
        let totalSpacingWidth = self.areaRankCellSpacing * CGFloat(cellCount - 1)

        let leftInset = (collectionView.bounds.width - totalCellWidth - totalSpacingWidth) / 2
        
        // 스크롤이 될 정도로 셀이 많은 경우에는 따로 inset을 주지 않아도 updateAreaRankCollectionViewToCenter으로 충분
        guard leftInset > 0 else { return .zero }
        
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
