//
//  RotationableCanvasView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/27.
//

import UIKit
import PencilKit

final class RotationableCanvasView: PKCanvasView {
    convenience init() {
        self.init(frame: CGRect())
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.minimumZoomScale = 0.5
        self.maximumZoomScale = 2.0
        self.isOpaque = false
        self.drawingPolicy = .pencilOnly
    }
    
    /// FormCell zoom 시 실행
    /// FormZero zoom 시 실행
    func updateDrawingRatio(imageSize: CGSize) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        let ratio = imageSize.height / imageSize.width
        self.adjustDrawingLayout(previousCanvasSize: previousSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
    }
    /// FormCell 회전시 실행
    /// FormZero exp 없이 회전시 실행
    /// FormZero exp 제거시 실행
    func updateDrawingRatioAndFrame(contentSize: CGSize, topHeight: CGFloat, imageSize: CGSize) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        let newSize = CGSize(width: contentSize.width, height: contentSize.height - topHeight)
        self.frame = .init(origin: CGPoint(0, topHeight), size: newSize)
        
        let ratio = imageSize.height / imageSize.width
        self.adjustDrawingLayout(previousCanvasSize: previousSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
    }
    /// FormZero: exp 있는 상태로 회전시 실행
    /// FormZero: exp 표시시 실행
    func updateDrawingRatioAndFrameWithExp(contentSize: CGSize, topHeight: CGFloat, imageSize: CGSize) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        if UIWindow.isLandscape {
            let newSize = CGSize(width: contentSize.width/2, height: contentSize.height - topHeight)
            self.frame = .init(origin: CGPoint(0, topHeight), size: newSize)
        } else {
            let newSize = CGSize(width: contentSize.width, height: (contentSize.height - topHeight)/2)
            self.frame = .init(origin: CGPoint(0, topHeight), size: newSize)
        }
        
        let ratio = imageSize.height / imageSize.width
        self.adjustDrawingLayout(previousCanvasSize: previousSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
    }
    
    func updateDrawingRatioAndFrame(formOneContentSize contentSize: CGSize, imageSize: CGSize) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        self.frame = .init(origin: .zero, size: .init(contentSize.width/2, contentSize.height))
        let ratio = imageSize.height / imageSize.width
        self.adjustDrawingLayout(previousCanvasSize: previousSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
    }
    
    func loadDrawing(to savedData: Data?, lastWidth: Double?) {
        guard let savedData = savedData,
              let lastWidth = lastWidth else {
            self.drawing = PKDrawing()
            return
        }
        
        guard let savedDrawing = try? PKDrawing(data: savedData) else {
            print("Error loading drawing object")
            self.drawing = PKDrawing()
            return
        }
        
        guard lastWidth > 0 else {
            self.drawing = savedDrawing
            return
        }
        
        let currentWidth = self.frame.width
        let scale = currentWidth / CGFloat(lastWidth)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        self.drawing = savedDrawing.transformed(using: transform)
    }
    
    func setDefaults() {
        self.setContentOffset(.zero, animated: false)
        self.zoomScale = 1.0
        self.contentInset = .zero
        self.delegate = nil
    }
}
