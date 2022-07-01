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
    /// viewDidAppear에서 애니메이션을 시도했는지 여부
    private var progressAnimateTried = false
    /// 애니메이션에 사용할 0과 1 사이의 progress값
    private var progressToAnimate: Float?
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
        self.bindAll()
        self.viewModel?.fetchResult()
        self.title = self.viewModel?.title ?? "임시 종합 성적표"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.progressAnimateTried == false {
            if let progressToAnimate = progressToAnimate {
                self.circularProgressView.setProgressWithAnimation(duration: 0.5, value: progressToAnimate, from: 0)
            }
            self.progressAnimateTried = true
        }
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
        self.circularProgressView.progressColor = UIColor(.mainColor) ?? .green
        
        let size = self.circularProgressView.frame.size
        let center = CGPoint(size.width/2, size.height)
        self.circularProgressView.changeCircleShape(center: center, startAngle: -CGFloat.pi, endAngle: 0)
    }
    
    private func configureRankLabel(to rank: Double) {
        self.rankLabel.text = "\(rank)"
    }
}

// MARK: Update
extension WorkbookGroupResultVC {
    private func updateAreaRankCollectionViewToCenter() {
        let cellCount = self.collectionView(self.areaRankCollectionView, numberOfItemsInSection: 0)
        self.areaRankCollectionView.scrollToItem(at: IndexPath(item: cellCount/2, section: 0), at: .centeredHorizontally, animated: false)
    }
}

// MARK: Binding
extension WorkbookGroupResultVC {
    private func bindAll() {
        self.bindSortedTestResults()
        self.bindNetworkFailed()
    }
    
    private func bindSortedTestResults() {
        self.viewModel?.$sortedTestResults
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] testResults in
                guard testResults.isEmpty == false else {
                    self?.showAlertWithOK(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                self?.configureData()
                self?.areaResultTableView.reloadData()
                self?.areaRankCollectionView.reloadData()
                self?.updateAreaRankCollectionViewToCenter()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNetworkFailed() {
        self.viewModel?.$networkFailed
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] networkFailed in
                if networkFailed == true {
                    self?.showAlertWithOK(title: "오프라인 상태입니다", text: "네트워크 연결을 확인 후 다시 시도하시기 바랍니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    
    private func configureData() {
        guard let viewModel = self.viewModel else { return }
        
        self.configureRankLabel(to: viewModel.averageRank)
        self.configureAnimation()
        self.totalTimeLabel.text = viewModel.formattedTotalTime
    }
    
    private func configureAnimation() {
        guard let viewModel = self.viewModel else { return }
        
        if self.progressAnimateTried == true { // viewDidAppear가 끝난 상태
            self.circularProgressView.setProgressWithAnimation(duration: 0.5, value: viewModel.normalizedAverageRank, from: 0)
        } else { // viewDidAppear가 아직 불리지 않은 상태
            self.progressToAnimate = viewModel.normalizedAverageRank
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
