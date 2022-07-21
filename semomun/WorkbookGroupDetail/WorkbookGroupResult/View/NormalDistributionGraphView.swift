//
//  NormalDistributionGraphView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

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
        layer.strokeColor = UIColor.getSemomunColor(.lightGray).cgColor
        layer.lineWidth = 2
        layer.position = .init(x: 24, y: 55)
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    private let graphFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.position = .init(x: 24, y: 55)
        layer.fillColor = UIColor.getSemomunColor(.border).cgColor
        return layer
    }()
    
    init() {
        super.init(frame: .zero)
        self.configureLayout()
        self.backgroundView.layer.addSublayer(self.graphFillLayer)
        self.backgroundView.layer.addSublayer(self.graphOutlineLayer)
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
        
        let path = UIBezierPath(rect: .init(0, 0, 0.6, 1))
        path.apply(scale)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.graphFillLayer.mask = maskLayer
    }
}

extension NormalDistributionGraphView {
    private func configureLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviews(self.backgroundView, self.titleLabel)
        NSLayoutConstraint.activate([
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
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
        path.close()
        
        return path
    }
}
