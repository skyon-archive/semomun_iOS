//
//  SubproblemCollectionView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/10.
//

import UIKit

class SubproblemCollectionView: UICollectionView {
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateFrame(contentRect: CGRect) {
        self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height)
//         self.collectionViewLayout.invalidateLayout()
    }
}
