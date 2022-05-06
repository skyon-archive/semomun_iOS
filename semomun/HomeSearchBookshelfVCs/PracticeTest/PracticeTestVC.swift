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
    
    @IBOutlet weak var practiceTests: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension PracticeTestVC: UICollectionViewDelegate {
    
}

extension PracticeTestVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 10
        case 1: return 5
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PracticeTestsHeaderView.identifier, for: indexPath) as? PracticeTestsHeaderView else { return UICollectionReusableView() }
            
            let headerTitle = indexPath.section == 0 ? "나의 실전 모의고사" : "실전 모의고사"
            headerView.configure(to: headerTitle)
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
}
