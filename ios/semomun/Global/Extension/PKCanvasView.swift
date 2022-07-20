//
//  PKCanvasView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import PencilKit

extension PKCanvasView {
    /// 캔버스의 레이아웃에 변화가 가해진 후 호출하면 변화를 반영하여 필기의 크기 및 위치를 조절
    /// - Parameters:
    ///   - previousContentSize: 레이아웃 변화 이전 content 크기
    ///   - previousContentOffset: 레이아웃 변화 이전 contentOffset
    ///   - contentRatio: 스크롤뷰의 높이/너비
    func adjustDrawingLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint, contentRatio: CGFloat) {
        // 필기 크기 조절
        let scaleFactor: CGFloat = self.frame.width/previousCanvasSize.width
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        self.drawing.transform(using: transform)
        
        self.adjustContentLayout(previousContentOffset: previousContentOffset, contentRatio: contentRatio)
    }
}

extension UIScrollView {
    /// UIScrollView의 레이아웃에 변화가 가해진 후 호출하면 변화를 반영하여 content의 크기 및 위치를 조절
    /// - Parameters:
    ///   - previousContentSize: 레이아웃 변화 이전 content 크기
    ///   - previousContentOffset: 레이아웃 변화 이전 contentOffset
    ///   - contentRatio: 스크롤뷰의 높이/너비
    func adjustContentLayout(previousContentOffset: CGPoint, contentRatio: CGFloat) {
        let canvasWidth = self.frame.width
        
        // 아래에서 크기를 조절하기 전에 원래 contentSize 기록
        let previousContentSize = self.contentSize
        
        // imageView와 canvasView의 크기 조절
        self.contentSize = CGSize(width: canvasWidth * self.zoomScale, height: canvasWidth * contentRatio * self.zoomScale)
        
        // 바뀐 크기에 맞게 이전과 같은 좌상단을 가지도록 contentOffset 조절
        if previousContentSize.height != 0 && previousContentSize.width != 0 {
            let relativeContentXOffset = previousContentOffset.x/previousContentSize.width
            let relativeContentYOffset = previousContentOffset.y/previousContentSize.height
            
            let contentXOffset = self.contentSize.width*relativeContentXOffset
            let contentYOffset = self.contentSize.height*relativeContentYOffset
            self.contentOffset = .init(contentXOffset, contentYOffset)
            
            // 가로의 최하단 상태에서 세로로 변경 시, 좌상단이 그대로 고정되어있다면 하단에 여백이 보일 수 있는 것 처리
            if self.zoomScale >= 1 && self.contentOffset.y + self.frame.height > self.contentSize.height {
                let bottommostOffset = self.contentSize.height - self.frame.height
                if bottommostOffset > 0 {
                    self.contentOffset.y = bottommostOffset
                }
            }
        }
        
        // zoomScale이 1 미만일 시 content가 화면 중앙으로 오도록 조절
        let offsetX = max((self.bounds.width - self.contentSize.width) * 0.5, 0)
        let offsetY = max((self.bounds.height - self.contentSize.height) * 0.5, 0)
        self.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    /// 두 번 탭했을 때 기본 크기로 돌아가는 제스처를 추가
    /// - TODO: 탭 한 위치를 중심으로
    func addDoubleTabGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func doubleTapped() {
        UIView.animate(withDuration: 0.25) {
            self.zoomScale = 1.0
        }
    }
}
