//
//  NormalDistributionGraphView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

// 그래프 폭은 600 고정
final class NormalDistributionGraphView: UIView {
    /* private */
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .getSemomunColor(.white)
        view.layer.cornerRadius = .cornerRadius12
        view.layer.cornerCurve = .continuous
        view.layer.masksToBounds = true
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .heading4
        label.textColor = .getSemomunColor(.darkGray)
        label.text = "평균 백분위"
        return label
    }()
    private let graphOutlineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.getSemomunColor(.darkGray).cgColor
        layer.lineWidth = 2
        layer.position = .init(x: 24, y: 55)
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    private let graphGridLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.getSemomunColor(.lightGray).cgColor
        layer.lineWidth = 2
        layer.position = .zero
        layer.fillColor = UIColor.blue.cgColor
        return layer
    }()
    private let graphFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.position = .init(x: 24, y: 55)
        layer.fillColor = UIColor.getSemomunColor(.border).cgColor
        return layer
    }()
    private let percentileBlueLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.position = .zero
        layer.strokeColor = UIColor.getSemomunColor(.blueRegular).cgColor
        layer.lineWidth = 2
        return layer
    }()
    private let percentileLabel: UILabel = {
        let label = UILabel()
        label.font = .heading5
        label.textColor = .getSemomunColor(.white)
        label.backgroundColor = .getSemomunColor(.blueRegular)
        label.widthAnchor.constraint(equalToConstant: 59).isActive = true
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        label.textAlignment = .center
        label.layer.cornerRadius = .cornerRadius4
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var percentileLabelLeadingConstraint: NSLayoutConstraint = {
        return self.percentileLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    }()
    private var percentage: Double = 0
    
    init() {
        super.init(frame: .zero)
        self.configureLayout()
        self.backgroundView.layer.addSublayer(self.graphFillLayer)
        self.backgroundView.layer.addSublayer(self.graphOutlineLayer)
        self.graphOutlineLayer.addSublayer(self.graphGridLineLayer)
        self.graphOutlineLayer.addSublayer(self.percentileBlueLineLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        let scale = CGAffineTransform(scaleX: self.frame.width-48, y: self.frame.height-126)
        
        let newPath = self.createGraphBezierPath()
        newPath.apply(scale)
        self.graphOutlineLayer.path = newPath.cgPath
        self.graphFillLayer.path = newPath.cgPath
        
        let gridPath = self.createGridLine()
        gridPath.apply(scale)
        self.graphGridLineLayer.path = gridPath.cgPath
        let gridPathMaskLayer = CAShapeLayer()
        gridPathMaskLayer.path = newPath.cgPath
        self.graphGridLineLayer.mask = gridPathMaskLayer
        
        let path = UIBezierPath(rect: .init(0, 0, self.percentage/100, 1))
        path.apply(scale)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.graphFillLayer.mask = maskLayer
        
        let blueLinePath = self.createBlueLine()
        blueLinePath.apply(scale)
        self.percentileBlueLineLayer.path = blueLinePath.cgPath
        let blueLineMaskLayer = CAShapeLayer()
        blueLineMaskLayer.path = newPath.cgPath
        self.percentileBlueLineLayer.mask = blueLineMaskLayer
        
        self.percentileLabelLeadingConstraint.constant = 24 + (self.frame.width-48) * CGFloat(self.percentage) / 100 - 30
    }
    
    func configurePercentage(to percentage: Double) {
        self.percentage = percentage
        self.percentileLabel.text = String(format: "%.2f%", percentage) + "%"
        self.setNeedsLayout()
    }
}

extension NormalDistributionGraphView {
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviews(self.backgroundView, self.titleLabel, self.percentileLabel)
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            
            self.percentileLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -38),
            self.percentileLabelLeadingConstraint
        ])
    }
}

extension NormalDistributionGraphView {
    private func createGraphBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .init(0, 1))
        path.addCurve(
            to: .init(x: 0.5, y: 0),
            controlPoint1: .init(x: 0.35, y: 1),
            controlPoint2: .init(x: 0.35, y: 0)
        )
        path.addCurve(
            to: .init(x: 1, y: 1),
            controlPoint1: .init(x: 0.65, y: 0),
            controlPoint2: .init(x: 0.65, y: 1)
        )
        
        return path
    }
    
    private func createGridLine() -> UIBezierPath {
        let path = UIBezierPath()
        for i in stride(from: 1.0, through: 8.0, by: 1.0) {
            path.move(to: .init(i/9, 1))
            path.addLine(to: .init(i/9, 0))
        }
        path.move(to: .init(0, 1))
        path.addLine(to: .init(1, 1))
        return path
    }
    
    private func createBlueLine() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .init(self.percentage/100, 0))
        path.addLine(to: .init(self.percentage/100, 1))
        return path
    }
}
