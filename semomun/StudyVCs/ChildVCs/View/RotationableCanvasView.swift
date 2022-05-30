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
        self.becomeFirstResponder()
        self.drawingPolicy = .pencilOnly
    }
    
    func updateFrameAndRatio(contentSize: CGSize, topHeight: CGFloat, imageSize: CGSize, rotate: Bool = false) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        if rotate {
            let newSize = CGSize(width: contentSize.width, height: contentSize.height - topHeight)
            self.frame = .init(0, topHeight, newSize.width, newSize.height)
        }
        
        let ratio = imageSize.height / imageSize.width
        self.adjustDrawingLayout(previousCanvasSize: previousSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
    }
    
    func updateFrameAndRatioWithExp(contentSize: CGSize, topHeight: CGFloat, imageSize: CGSize, rotate: Bool = false) {
        let previousSize = self.frame.size
        let previousContentOffset = self.contentOffset
        
        if rotate {
            if UIWindow.isLandscape {
                let newSize = CGSize(width: contentSize.width/2, height: contentSize.height - topHeight)
                self.frame = . init(0, topHeight, newSize.width, newSize.height)
            } else {
                let newSize = CGSize(width: contentSize.width, height: (contentSize.height - topHeight)/2)
                self.frame = . init(0, topHeight, newSize.width, newSize.height)
            }
        }
        
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
}
