//
//  SubproblemCollectionView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/10.
//

import UIKit

/// Cell이 포함된 Form들에서 Cell들을 표시하는 역할
class SubproblemCollectionView: UICollectionView {
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefaults() {
        self.contentOffset = .zero
    }
    
    /// - FormOne exp 없을 때
    func updateFrame(formOneContentRect: CGRect) {
        self.frame = .init(formOneContentRect.width/2, 0, formOneContentRect.width/2, formOneContentRect.height)
        self.collectionViewLayout.invalidateLayout()
    }
    
    /// - FormOne exp 있을 때
    func updateFrameWithExp(formOneContentRect contentRect: CGRect) {
        if UIWindow.isLandscape {
            self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height)
        } else {
            self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height/2)
        }
        self.collectionViewLayout.invalidateLayout()
    }
}
