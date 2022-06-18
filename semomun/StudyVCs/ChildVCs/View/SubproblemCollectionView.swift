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
    
    /**
     - FormOne exp 없을 때
     */
    func updateFrame(formOneContentRect contentRect: CGRect) {
        self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height)
        self.collectionViewLayout.invalidateLayout()
    }
    
    /**
     - FormOne exp 있을 때
     */
    func updateFrameWithExp(formOneContentRect contentRect: CGRect) {
        if UIWindow.isLandscape {
            self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height)
        } else {
            self.frame = .init(contentRect.width/2, 0, contentRect.width/2, contentRect.height/2)
        }
        self.collectionViewLayout.invalidateLayout()
    }
    
    /**
     - FormTwo 화면회전시 실행
     */
    func updateFrame(formTwoContentRect contentRect: CGRect) {
        if UIWindow.isLandscape {
            let marginBetweenView: CGFloat = 26
            self.frame = .init(x: (contentRect.width - marginBetweenView)/2 + marginBetweenView, y: 0, width: (contentRect.width - marginBetweenView)/2, height: contentRect.height)
        } else {
            let marginBetweenView: CGFloat = 13
            self.frame = .init(0, (contentRect.height - marginBetweenView)/2 + marginBetweenView, contentRect.width, (contentRect.height - marginBetweenView)/2)
        }
        self.collectionViewLayout.invalidateLayout()
    }
}
