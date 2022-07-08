//
//  ScrollingBackgroundFlowLayout.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/07.
//

import UIKit

/// 섹션 헤더가 전혀 존재하지 않거나, 있다면 모든 섹션 상단에 높이 40의 섹션 헤더가 존재함을 가정
class ScrollingBackgroundFlowLayout: UICollectionViewFlowLayout {
    static let elementKindRoundedBackground = "background"
    
    private let sectionHeaderExist: Bool
    
    init(sectionHeaderExist: Bool) {
        self.sectionHeaderExist = sectionHeaderExist
        super.init()
        self.register(ScrollingBackground.self, forDecorationViewOfKind: Self.elementKindRoundedBackground)
        self.sectionInset = .init(top: 0, left: UICollectionView.gridPadding, bottom: UICollectionView.sectionVerticalSpacing, right: UICollectionView.gridPadding)
        self.minimumLineSpacing = UICollectionView.lineSpacingInSection
        self.itemSize = UICollectionView.bookcoverCellSize
        // 임시 기본값
        self.headerReferenceSize = .init(500, 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func invalidateLayout() {
        self.itemSize = UICollectionView.bookcoverCellSize
        super.invalidateLayout()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        
        if self.sectionHeaderExist {
            let sectionCount = self.collectionView?.numberOfSections ?? 0
            attributes?.append(contentsOf: (0..<sectionCount).compactMap {
                self.layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    at: .init(item: 0, section: $0)
                )
            })
        }
        
        if let decorationViewAttribute = self.layoutAttributesForDecorationView(ofKind: Self.elementKindRoundedBackground, at: .init(item: 0, section: 0)) {
            attributes?.append(decorationViewAttribute)
        }
        
        return attributes
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == Self.elementKindRoundedBackground {
            let attrs = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
            // 하단 스크롤 overflow에서도 흰색 배경이 보이게 하기 위해 충분히 큰 높이값 설정
            let decorationViewHeight = (self.collectionView?.frame.height ?? self.collectionViewContentSize.height) * 2
            attrs.frame = .init(origin: .init(0, -UICollectionView.gridPadding), size: .init(self.collectionViewContentSize.width, decorationViewHeight))
            // 셀보다 뒤로 가도록 설정
            attrs.zIndex = -999
            
            return attrs
        } else {
            return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard self.sectionHeaderExist else { return nil }
        
        let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        if elementKind == UICollectionView.elementKindSectionHeader {
            attrs.frame = .init(0, 0, self.collectionViewContentSize.width, 40)
            return attrs
        } else {
            return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
    }
}
