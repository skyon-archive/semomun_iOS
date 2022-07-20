//
//  AveragePercentileGraphView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/21.
//

import UIKit

/// 평균 백분위를 나타내는 정규분포 그래프
final class AveragePercentileGraphView: UIView {
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
    /// 아래의 CALayer들을 묶는 frame layer
    private let graphFrameLayer = CALayer()
    /// 그래프 내부를 채우는 layer
    private let graphFillLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.getSemomunColor(.border).cgColor
        return layer
    }()
    /// 그래프의 세로 격자선과 x축을 나타내는 layer
    private let graphGridLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.getSemomunColor(.lightGray).cgColor
        layer.lineWidth = 2
        layer.position = .zero
        layer.fillColor = UIColor.blue.cgColor
        return layer
    }()
    /// 그래프의 곡선을 나타내는 layer
    private let graphOutlineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.getSemomunColor(.darkGray).cgColor
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    /// 사용자 백분율 부분에 파란 선을 표시하는 layer
    private let blueLineLayer: CAShapeLayer = {
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
        return self.percentileLabel.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor)
    }()
    /// 0과 1 사이의 비율 값
    private var percentile: Double = 0
    private let graphSize = CGSize(600, 292)
    /// path 확대에 사용되는 transform값
    private lazy var scale = CGAffineTransform(scaleX: self.graphSize.width, y: self.graphSize.height)
    
    convenience init() {
        self.init(frame: .zero)
        self.configureLayout()
        // layer 추가
        self.backgroundView.layer.addSublayer(self.graphFrameLayer)
        self.graphFrameLayer.addSublayer(self.graphFillLayer)
        self.graphFrameLayer.addSublayer(self.graphGridLineLayer)
        self.graphFrameLayer.addSublayer(self.graphOutlineLayer)
        self.graphFrameLayer.addSublayer(self.blueLineLayer)
        // layer path 설정
        self.graphFillLayer.path = self.createGraphOutlinePath()
        self.graphOutlineLayer.path = self.createGraphOutlinePath()
        self.graphGridLineLayer.path = self.createGridLinePath()
        self.maskToGraphLine(self.graphGridLineLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // graph 중앙 정렬
        let graphXPos = (self.backgroundView.frame.width - self.graphSize.width)/2
        self.graphFrameLayer.position = .init(graphXPos, 55)
        // percentile값에 따른 fillLayer의 크기 설정
        self.removeRightArea(layer: self.graphFillLayer, percentile: 1-self.percentile)
        // percentile값에 따른 blueLine의 위치 설정
        self.blueLineLayer.path = self.createBlueLinePath()
        self.maskToGraphLine(self.blueLineLayer)
        // 라벨이 blueLine 바로 아래에 오도록 설정, 라벨 중앙에 선이 위치하도록 위해 라벨 width의 절반을 뺀다.
        self.percentileLabelLeadingConstraint.constant = graphXPos + self.graphSize.width * CGFloat(self.percentile) - self.percentileLabel.frame.width / 2
    }
    
    /// - Parameter percentile: 0이상 1이하의 값
    func configurePercentile(to percentile: Double) {
        self.percentile = percentile
        self.percentileLabel.text = String(format: "%.2f%", percentile*100) + "%"
        self.setNeedsLayout()
    }
}

extension AveragePercentileGraphView {
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

// 모든 BezierPath는 일단 크기 1의 정사각형 내에서 그려지고, 이후 scale을 통해 확장된다
extension AveragePercentileGraphView {
    private func createGraphOutlinePath() -> CGPath {
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
        path.apply(self.scale)
        return path.cgPath
    }
    
    private func createGridLinePath() -> CGPath {
        let path = UIBezierPath()
        for i in stride(from: 1.0, through: 8.0, by: 1.0) {
            path.move(to: .init(i/9, 1))
            path.addLine(to: .init(i/9, 0))
        }
        path.move(to: .init(0, 1))
        path.addLine(to: .init(1, 1))
        path.apply(self.scale)
        return path.cgPath
    }
    
    private func createBlueLinePath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: .init(self.percentile, 0))
        path.addLine(to: .init(self.percentile, 1))
        path.apply(self.scale)
        return path.cgPath
    }
    
    /// layer를 그래프 선 밖으로 튀어나가지 않도록 자른다
    private func maskToGraphLine(_ layer: CALayer) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = self.createGraphOutlinePath()
        layer.mask = maskLayer
    }
    
    /// layer에서 우측 percentile만큼을 제거한다.
    private func removeRightArea(layer: CALayer, percentile: Double) {
        let path = UIBezierPath(rect: .init(0, 0, 1-percentile, 1))
        path.apply(self.scale)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
