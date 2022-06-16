//
//  CircularProgressView.swift
//  semomun
//
//  Created by Kang Minsang on 2020/07/17.
//  Copyright © 2020 FDEE. All rights reserved.
//

import UIKit

final class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var progressWidth = CGFloat(15.0) {
        didSet {
            trackLayer.lineWidth = progressWidth
            progressLayer.lineWidth = progressWidth
        }
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float, from: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    func changeCircleShape(center: CGPoint, startAngle: CGFloat, endAngle: CGFloat) {
        let circlePath = UIBezierPath(arcCenter: center, radius: (frame.size.width-1.5)/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.trackLayer.path = circlePath.cgPath
        self.progressLayer.path = circlePath.cgPath
    }
    
    private func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width-1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = self.progressWidth
        trackLayer.strokeEnd = 1.0
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = self.progressWidth
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }
}
