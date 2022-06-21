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
    var workbookGroupInfo: WorkbookGroupPreviewOfDB?
    
    @IBOutlet weak var practiceTests: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurePracticeTests()
        self.configureComprehensiveReportButton()
        self.title = self.workbookGroupInfo?.title ?? ""
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

// MARK: Configure
extension WorkbookGroupDetailVC {
    private func configurePracticeTests() {
        self.practiceTests.dataSource = self
        self.practiceTests.delegate = self
    }
    
    private func configureComprehensiveReportButton() {
        let comprehensiveReportButton = WorkbookGroupResultButton()
        let action = UIAction { [weak self] _ in self?.showComprehensiveReport() }
        comprehensiveReportButton.addAction(action, for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: comprehensiveReportButton)
    }
    
    private func showComprehensiveReport() {
        let storyboard = UIStoryboard(controllerType: WorkbookGroupResultVC.self)
        guard let comprehensiveReportVC = storyboard.instantiateViewController(withIdentifier: WorkbookGroupResultVC.identifier) as? WorkbookGroupResultVC else { return }
        comprehensiveReportVC.workbookGroupInfo = self.workbookGroupInfo
        self.navigationController?.pushViewController(comprehensiveReportVC, animated: true)
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 8
        case 1: return 3
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestSubjectCell.identifer, for: indexPath) as? TestSubjectCell else { return UICollectionViewCell() }
        
        // 임시용 로직
        if indexPath.section == 0 {
            cell.configure(title: "국어(화법과 작문)")
        } else {
            cell.configure(title: "2021년도 국가직 9급 공무원 정보시스템 보안", price: "10,000원")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WorkbookGroupDetailHeaderView.identifier, for: indexPath) as? WorkbookGroupDetailHeaderView else { return UICollectionReusableView() }
            
            if self.numberOfSections(in: collectionView) == 1 {
                headerView.updateLabel(to: "실전 모의고사")
            } else if self.numberOfSections(in: collectionView) == 2 {
                let headerTitle = indexPath.section == 0 ? "나의 실전 모의고사" : "실전 모의고사"
                headerView.updateLabel(to: headerTitle)
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TestSubjectCell.cellSize
    }
}

extension WorkbookGroupDetailVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 임시 로직
        print(indexPath.section, indexPath.item)
    }
}
