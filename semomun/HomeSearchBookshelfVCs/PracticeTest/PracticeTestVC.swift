//
//  PracticeTestVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/06.
//

import UIKit
import Combine

class PracticeTestVC: UIViewController {
    static let identifier = "PracticeTestVC"
    static let storyboardName = "HomeSearchBookshelf"
    
    @IBOutlet weak var practiceTests: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "실전 모의고사"
        // 임시 로직
        self.practiceTests.dataSource = self
        self.practiceTests.delegate = self
        self.practiceTests.reloadData()
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

extension PracticeTestVC: UICollectionViewDataSource {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PracticeTestCell.identifer, for: indexPath) as? PracticeTestCell else { return UICollectionViewCell() }
        
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
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PracticeTestsHeaderView.identifier, for: indexPath) as? PracticeTestsHeaderView else { return UICollectionReusableView() }
            
            if self.numberOfSections(in: collectionView) == 1 {
                headerView.configure(to: "실전 모의고사")
            } else if self.numberOfSections(in: collectionView) == 2 {
                let headerTitle = indexPath.section == 0 ? "나의 실전 모의고사" : "실전 모의고사"
                headerView.configure(to: headerTitle)
            }
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}

extension PracticeTestVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(146, 240)
    }
}

extension PracticeTestVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 임시 로직
        print(indexPath.section, indexPath.item)
    }
}
