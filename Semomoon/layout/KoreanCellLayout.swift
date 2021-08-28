//
//  KoreanCellLayout.swift
//  KoreanCellLayout
//
//  Created by qwer on 2021/08/28.
//

import UIKit

protocol KoreanLayoutDelegate: AnyObject {
    // cell 크기를 정하기 전에 view의 image 크기를 받아 전달하는 메소드
  func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class KoreanCellLayout: UICollectionViewLayout {
    weak var delegate: KoreanLayoutDelegate?

    private let numberOfColumns = 1     //한 줄에 1개씩
    private let cellPadding: CGFloat = 10        //셀 간의 패딩값

    // prepare를 호출 할 때 모든 항목의 속성을 계산하여 캐시에 추가한다.
    // 나중에 컬렉션뷰에서 레이아웃 속성을 요청하면 다시 계산해야하니까 캐시를 사용해서 효과적으로 다룸
    private var cache: [UICollectionViewLayoutAttributes] = []      //어트리뷰트 리턴할 배열

    //콘텐츠 높이는 사진때문에 늘어나는 것이고
    //가로는 collectionView 자체 크기에서 오른쪽왼쪽 Inset 뺀 값
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // MARK: - collectionViewContentSize
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // MARK: - prepare
    override func prepare() {
        // cache = colletionviewLayoutAttributes 가 비어있어야지
        // 그리고 콜렉션뷰가존재해야지 레이아웃을 준비할 수 있음.
        guard
            cache.isEmpty,
            let collectionView = collectionView
        else {
            return
        }
        
        // xOffset에다가 x 좌표를 넣는 과정.
        // 먼저 columWith 로 하나의 셀 가로를 정하고 각 좌표를 계산해서 배열에 넣어줌
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        //yOffset은 0으로 일단 다 초기화 (첫 열에 2개가 들어가는데 둘 다 시작은 0포인트이니까)
        //이후 y 는 첫 column (열)에 각 컨텐츠가 들어간 이후에 컨텐츠 사이즈에 따라서 다음 행의 y 포인트를 계산할 수 있겠지?
        // cuz 다이나믹한 세로길이니까!!!
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        
        // 모든 아이템에 대해서 ~ (여기서는 1개의 섹션밖에 없기때문에 inSectoin: 0 에 대한 모든 아이템~ )
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)        //indexPath 지정.
            
            // 이제 프레임을 정해줌. Delegate를 이용해서 사진 자체의 높이를 받아오고
            // 셀의 높이는 photoHeight + top&bottom 의 패딩값(미리 정해둔 것)을 더해서 높이를 지정
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            
            // 이제 attributes 를 만든다. (Frame 에 대한 attribute)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            
            // contentHiehgt 를 지정해주고
            // y 시작지점을 y 지점 + height 로 해서 다음 시작지점을 만들어줌
            // (이래서 처음에 yOffest 을 다 0으로 초기화시킨 것)
            // 어차피 내 y Point 는 내 윗 열의 컨텐츠 높이에 따라서 결정되니까
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            
            //다음 column 지정
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    // MARK: - layoutAttributesForElements
    //prepare 다음에 불리는 주어진 사각형에 어떤것이 보일지를 결정하도록한다.
    //attribute 를 임의로 만들어줬기 때문에 화면에 보이는 부분만 그릴 수 있도록 반환해야함. (교차하는 것)
    override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {      //교차하면 true
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    // MARK: - layoutAttributesForItem
    // 각 indexPAth.row 에 맞춰서 cache 를 반환할 수 있도록
    override func layoutAttributesForItem(at indexPath: IndexPath)
    -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
