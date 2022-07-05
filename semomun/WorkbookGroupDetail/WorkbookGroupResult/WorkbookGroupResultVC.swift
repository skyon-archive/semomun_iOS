//
//  WorkbookGroupResultVC.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/13.
//

import UIKit
import Combine

class WorkbookGroupResultVC: UIViewController, StoryboardController {
    /* public */
    static var identifier: String = "WorkbookGroupResultVC"
    static var storyboardNames: [UIUserInterfaceIdiom : String] = [
        .pad: "HomeSearchBookshelf"
    ]
    /* private */
    private var viewModel: WorkbookGroupResultVM?
    private var cancellables: Set<AnyCancellable> = []
    private let areaRankCellSpacing: CGFloat = 16
    /// 애니메이션에 사용할 0과 1 사이의 progress값
    private var progressToAnimate: Float = 0
    private var didProgressAnimationed = false
    @IBOutlet weak var circularProgressView: CircularProgressView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var areaResultTableView: UITableView!
    @IBOutlet weak var areaRankCollectionView: UICollectionView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureareaResultTableView()
        self.configureAreaRankCollectionView()
        self.configureCircularProgressView()
        self.configureViewModelData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.updateAreaRankCollectionViewToCenter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateProgress()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.areaRankCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.areaRankCollectionView.performBatchUpdates { [weak self] in
                self?.areaRankCollectionView.collectionViewLayout.invalidateLayout()
            }
        })
    }
}

// MARK: Public
extension WorkbookGroupResultVC {
    func configureViewModel(_ viewModel: WorkbookGroupResultVM) {
        self.viewModel = viewModel
    }
}

// MARK: Configure
extension WorkbookGroupResultVC {
    private func configureareaResultTableView() {
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
        self.circularProgressView.trackColor = UIColor(.lightMainColor) ?? .lightGray
        self.circularProgressView.progressColor = UIColor(.blueRegular) ?? .green
        
        let size = self.circularProgressView.frame.size
        let center = CGPoint(size.width/2, size.height)
        self.circularProgressView.changeCircleShape(center: center, startAngle: -CGFloat.pi, endAngle: 0)
    }
    
    private func configureViewModelData() {
        guard let viewModel = self.viewModel else { return }
        
        self.configureRankLabel(to: viewModel.averageRank)
        self.totalTimeLabel.text = viewModel.formattedTotalTime
        self.title = viewModel.title
        self.progressToAnimate = viewModel.normalizedAverageRank
    }
    
    private func configureRankLabel(to rank: Double) {
        self.rankLabel.text = "\(rank)"
    }
}

// MARK: Update
extension WorkbookGroupResultVC {
    private func updateAreaRankCollectionViewToCenter() {
        let cellCount = self.collectionView(self.areaRankCollectionView, numberOfItemsInSection: 0)
        guard cellCount > 0 else { return }
        self.areaRankCollectionView.scrollToItem(at: IndexPath(item: cellCount/2, section: 0), at: .centeredHorizontally, animated: false)
    }
}

// MARK: Animate
extension WorkbookGroupResultVC {
    private func animateProgress() {
        if self.didProgressAnimationed == false {
            self.circularProgressView.setProgressWithAnimation(duration: 0.5, value: progressToAnimate, from: 0)
            self.didProgressAnimationed = true
        }
    }
}

extension WorkbookGroupResultVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        
        return viewModel.sortedTestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.areaResultTableView.dequeueReusableCell(withIdentifier: TestSubjectResultCell.identifier) as? TestSubjectResultCell else {
            return UITableViewCell()
        }
        guard let viewModel = self.viewModel else { return cell }
        
        cell.prepareForReuse(index: indexPath.row+1, info: viewModel.sortedTestResults[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension WorkbookGroupResultVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else { return 0 }
        
        return viewModel.sortedTestResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.areaRankCollectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectRankCell.identifier, for: indexPath) as? TestSubjectRankCell else {
            return .init()
        }
        guard let viewModel = self.viewModel else { return cell }
        
        cell.prepareForReuse(info: viewModel.sortedTestResults[indexPath.row])
        
        return cell
    }
}

extension WorkbookGroupResultVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TestSubjectRankCell.cellSize
    }
    
    // MARK: 셀 중앙 정렬
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // VM 을 통한 로직으로 수정 필요
        let cellCount = self.collectionView(collectionView, numberOfItemsInSection: section)
        let totalCellWidth = TestSubjectRankCell.cellSize.width * CGFloat(cellCount)
        let totalSpacingWidth = self.areaRankCellSpacing * CGFloat(cellCount - 1)
        
        let leftInset = (self.areaRankCollectionView.bounds.width - totalCellWidth - totalSpacingWidth) / 2
        
        // 스크롤이 될 정도로 셀이 많은 경우에는 따로 inset을 주지 않아도 updateAreaRankCollectionViewToCenter 메소드로 충분
        guard leftInset > 0 else { return .zero }
        
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
