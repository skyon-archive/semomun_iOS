//
//  BannerAdsFlowLayout.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/02/18.
//

import UIKit

protocol BannerAdsAutoScrollStoppable: AnyObject {
    func stopAutoScroll()
}

class BannerAdsFlowLayout: UICollectionViewLayout {
    init(autoScrollStopper: BannerAdsAutoScrollStoppable) {
        super.init()
        self.bannerAdsAutoScrollStoppable = autoScrollStopper
    }
    
    required init?(coder: NSCoder) { return nil }
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private weak var bannerAdsAutoScrollStoppable: BannerAdsAutoScrollStoppable?
    private lazy var itemCount: CGFloat = {
        guard let collectionView = self.collectionView else { return 0 }
        return CGFloat(collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) ?? 0)
    }()
    
    private let cellSize = CGSize(320, 200)
    private let cellMargin: CGFloat = 10
    
    override func prepare() {
        guard cache.isEmpty else { return }
        self.cache = (0..<Int(itemCount)).map { itemIndex in
            let indexPath = IndexPath(item: itemIndex, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let itemSize = self.cellSize
            let itemXPos = (self.cellSize.width + self.cellMargin) * CGFloat(itemIndex)
            let itemOrigin = CGPoint(itemXPos, 0)
            attributes.frame = CGRect(origin: itemOrigin, size: itemSize)
            return attributes
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize((self.cellSize.width + self.cellMargin)*itemCount, cellSize.height)
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cache.filter { $0.frame.intersects(rect) }
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else { return proposedContentOffset }
        
        self.bannerAdsAutoScrollStoppable?.stopAutoScroll()
        
        let visibleCellIndexesUnordered = collectionView.indexPathsForVisibleItems
        guard visibleCellIndexesUnordered.isEmpty == false else { return proposedContentOffset }
        
        let contentXOffset = collectionView.contentOffset.x
        let fullCellWidth = self.cellSize.width + self.cellMargin
        
        func distanceToMiddle(_ cell: UICollectionViewCell) -> CGFloat {
            let bannerViewMiddleOffset = contentXOffset + collectionView.frame.width / 2
            return abs(cell.frame.midX - bannerViewMiddleOffset)
        }
        let centerCell = visibleCellIndexesUnordered
            .compactMap {
                collectionView.cellForItem(at: $0)
            }.max(by: {
                distanceToMiddle($0) > distanceToMiddle($1)
            })!
        var nextScollViewOffset = CGPoint(x: centerCell.frame.midX - collectionView.frame.width / 2, y: 0)
        
        // 스크롤 방향(velocity)와 반대로 nextOffset이 설정되면 부자연스러움
        if velocity.x > 0 && nextScollViewOffset.x < contentXOffset {
            nextScollViewOffset.x += fullCellWidth
        } else if velocity.x < 0 && contentXOffset < nextScollViewOffset.x {
            nextScollViewOffset.x -= fullCellWidth
        }
        
        // 스크롤 속도에 따라 멀리까지 가도록
        nextScollViewOffset.x += CGFloat(Int(velocity.x / 2.5)) * fullCellWidth
        
        return nextScollViewOffset
    }
}
