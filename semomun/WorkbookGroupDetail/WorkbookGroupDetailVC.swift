//
//  WorkbookGroupDetailVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/06.
//

import UIKit
import Combine

final class WorkbookGroupDetailVC: UIViewController {
    /* public */
    static let identifier = "WorkbookGroupDetailVC"
    static let storyboardName = "HomeSearchBookshelf"
    var viewModel: WorkbookGroupDetailVM?
    
    /* private */
    private var cancellables: Set<AnyCancellable> = []
    private var networkUsecase: S3ImageFetchable = NetworkUsecase(network: Network())
    @IBOutlet weak var practiceTests: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindAll()
        self.configurePracticeTests()
        self.configureComprehensiveReportButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

// MARK: Public
extension WorkbookGroupDetailVC {
    func configureViewModel(to viewModel: WorkbookGroupDetailVM) {
        self.viewModel = viewModel
    }
}

// MARK: Configure
extension WorkbookGroupDetailVC {
    private func configurePracticeTests() {
        self.practiceTests.dataSource = self
        self.practiceTests.delegate = self
    }
    
    private func configureComprehensiveReportButton() {
        let comprehensiveReportButton = WorkbookGroupResultButton()
        let action = UIAction { [weak self] _ in self?.showWorkbookGroupResultVC() }
        comprehensiveReportButton.addAction(action, for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: comprehensiveReportButton)
    }
    
    private func showWorkbookGroupResultVC() {
        let storyboard = UIStoryboard(controllerType: WorkbookGroupResultVC.self)
        guard let comprehensiveReportVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupResultVC.identifier) as? WorkbookGroupResultVC else { return }
        
        // wgid 받아오는 임시 로직
        let wgid = 1
        
        let networkUsecase = NetworkUsecase(network: Network())
        let viewModel = WorkbookGroupResultVM(wgid: wgid, networkUsecase: networkUsecase)
        comprehensiveReportVC.configureViewModel(viewModel)
        self.navigationController?.pushViewController(comprehensiveReportVC, animated: true)
    }
}

extension WorkbookGroupDetailVC {
    private func bindAll() {
        self.bindWorkbookGroupInfo()
        self.bindPurchasedWorkbooks()
        self.bindNonPurchasedWorkbooks()
    }
    
    private func bindWorkbookGroupInfo() {
        self.viewModel?.$info
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] info in
                self?.title = info.title
            })
            .store(in: &self.cancellables)
    }
    
    private func bindPurchasedWorkbooks() {
        self.viewModel?.$purchasedWorkbooks
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] purchases in
                guard purchases.isEmpty == false else { return }
                self?.practiceTests.reloadData()
            })
            .store(in: &self.cancellables)
    }
    
    private func bindNonPurchasedWorkbooks() {
        self.viewModel?.$nonPurchasedWorkbooks
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] workbooks in
                print(workbooks.count)
                self?.practiceTests.reloadData()
            })
            .store(in: &self.cancellables)
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel?.isPurchased ?? false ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isPurchased = self.viewModel?.isPurchased ?? false
        let purchasedCount = self.viewModel?.purchasedWorkbooks.count ?? 0
        let nonPurchasedCount = self.viewModel?.nonPurchasedWorkbooks.count ?? 0
        
        switch section {
        case 0:
            return isPurchased ? purchasedCount : nonPurchasedCount
        case 1:
            return nonPurchasedCount
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectCell.identifer, for: indexPath) as? TestSubjectCell else { return UICollectionViewCell() }
        let isPurchased = self.viewModel?.isPurchased ?? false
        
        switch indexPath.section {
        case 0:
            if isPurchased {
                guard let coreInfo = self.viewModel?.purchasedWorkbooks[safe: indexPath.item] else { return cell
                }
                cell.configure(coreInfo: coreInfo)
            } else {
                guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
                cell.configureNetworkUsecase(to: self.networkUsecase)
                cell.configure(dtoInfo: dtoInfo)
            }
        case 1:
            guard let dtoInfo = self.viewModel?.nonPurchasedWorkbooks[safe: indexPath.item] else { return cell }
            cell.configureNetworkUsecase(to: self.networkUsecase)
            cell.configure(dtoInfo: dtoInfo)
        default:
            assertionFailure("collectionView indexPath section error")
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WorkbookGroupDetailHeaderView.identifier, for: indexPath) as? WorkbookGroupDetailHeaderView else { return UICollectionReusableView() }
            let isPurchased = self.viewModel?.isPurchased ?? false
            
            switch indexPath.section {
            case 0:
                headerView.updateLabel(to: isPurchased ? "나의 실전 모의고사" : "실전 모의고사")
            case 1:
                headerView.updateLabel(to: "실전 모의고사")
            default:
                assertionFailure("collectionView indexPath section error")
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 가로모드, 기기별, 그림자 처리 등 추후 수정 예정
        return TestSubjectCell.cellSize
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isPurchased = self.viewModel?.isPurchased ?? false
        switch indexPath.section {
        case 0:
            if isPurchased {
                self.viewModel?.selectCoreWorkbook(to: indexPath.item)
            } else {
                self.viewModel?.selectWorkbook(to: indexPath.item)
            }
        case 1:
            self.viewModel?.selectWorkbook(to: indexPath.item)
        default:
            assertionFailure("collectionView indexPath section error")
        }
    }
}
