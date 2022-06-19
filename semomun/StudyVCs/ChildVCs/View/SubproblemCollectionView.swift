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
    func updateFrame(formOneContentSize contentSize: CGSize) {
        self.frame = .init(contentSize.width/2, 0, contentSize.width/2 - 10, contentSize.height)
        self.collectionViewLayout.invalidateLayout()
    }
    
    /**
     - FormOne exp 있을 때
     */
    func updateFrameWithExp(formOneContentSize contentSize: CGSize) {
        if UIWindow.isLandscape {
            self.frame = .init(contentSize.width/2, 0, contentSize.width/2 - 10, contentSize.height)
        } else {
            self.frame = .init(contentSize.width/2, 0, contentSize.width/2 - 10, contentSize.height/2)
        }
        self.collectionViewLayout.invalidateLayout()
    }
    
    /**
     - FormTwo 화면회전시 실행
     */
    func updateFrame(formTwoContentSize contentSize: CGSize) {
        if UIWindow.isLandscape {
            let marginBetweenView: CGFloat = 26
            self.frame = .init(x: (contentSize.width - marginBetweenView)/2 + marginBetweenView, y: 0, width: (contentSize.width - marginBetweenView)/2 - 10, height: contentSize.height)
        } else {
            let marginBetweenView: CGFloat = 13
            self.frame = .init(0, (contentSize.height - marginBetweenView)/2 + marginBetweenView, contentSize.width - 10, (contentSize.height - marginBetweenView)/2)
        }
        self.collectionViewLayout.invalidateLayout()
    }
}
