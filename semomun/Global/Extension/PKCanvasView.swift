//
//  PKCanvasView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import PencilKit

extension PKCanvasView {
    /// CanvasView의 레이아웃에 변화가 가해진 후 호출하면 변화를 반영하여 필기 크기 및 위치를 조절
    /// - Parameters:
    ///   - previousCanvasSize: 레이아웃 변화 이전 캔버스 크기
    ///   - previousContentOffset: 레이아웃 변화 이전 contentOffset
    ///   - ratio: 캔버스의 높이/너비
    func adjustContentLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint, contentRatio: CGFloat) {
        let canvasWidth = self.frame.width
        
        // 필기 크기 조절
        let scaleFactor: CGFloat = canvasWidth/previousCanvasSize.width
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        self.drawing.transform(using: transform)
        
        // 아래에서 크기를 조절하기 전에 원래 contentSize 기록
        let previousContentSize = self.contentSize
        
        // imageView와 canvasView의 크기 조절
        self.contentSize = CGSize(width: canvasWidth * self.zoomScale, height: canvasWidth * contentRatio * self.zoomScale)
        
        // 바뀐 크기에 맞게 이전과 같은 좌상단를 가지도록 contentOffset 조절
        if previousContentSize.height != 0 && previousContentSize.width != 0 {
            let relativeContentXOffset = previousContentOffset.x/previousContentSize.width
            let relativeContentYOffset = previousContentOffset.y/previousContentSize.height
            
            let contentXOffset = self.contentSize.width*relativeContentXOffset
            let contentYOffset = self.contentSize.height*relativeContentYOffset
            self.contentOffset = .init(contentXOffset, contentYOffset)
            
            // 최하단에서 가로->세로 변경 시 여백이 보일 수 있는 점 고려
            if self.contentOffset.y + self.frame.height > self.contentSize.height {
                self.contentOffset.y = self.contentSize.height - self.frame.height
            }
        }
        
        // zoomScale이 1 미만일 시 content가 화면 중앙으로 오도록 조절
        let offsetX = max((self.bounds.width - self.contentSize.width) * 0.5, 0)
        let offsetY = max((self.bounds.height - self.contentSize.height) * 0.5, 0)
        self.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
