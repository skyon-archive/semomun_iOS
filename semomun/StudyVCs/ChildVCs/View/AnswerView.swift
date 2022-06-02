//
//  AnswerView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/02/07.
//

import UIKit

final class AnswerView: UIView {
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    private let blurBackground: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.cornerRadius = 10
        blurEffectView.clipsToBounds = true
        
        return blurEffectView
    }()
    
    private let triangle: TriangleView = {
        let view = TriangleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    convenience init() {
        self.init(frame: CGRect())
        self.configureLayout()
        self.alpha = 0
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureLayout() {
        self.addSubviews(self.answerLabel, self.blurBackground, self.triangle)
        self.sendSubviewToBack(self.blurBackground)
        self.sendSubviewToBack(self.triangle)

        NSLayoutConstraint.activate([
            self.blurBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            self.blurBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.answerLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            self.answerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            self.answerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
        ])
        
        
        NSLayoutConstraint.activate([
            self.answerLabel.topAnchor.constraint(equalTo: self.blurBackground.topAnchor, constant: 10),
            self.answerLabel.leadingAnchor.constraint(equalTo: self.blurBackground.leadingAnchor, constant: 10),
            self.answerLabel.trailingAnchor.constraint(equalTo: self.blurBackground.trailingAnchor, constant: -10),
            self.answerLabel.bottomAnchor.constraint(equalTo: self.blurBackground.bottomAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            self.triangle.topAnchor.constraint(equalTo: self.topAnchor),
            self.triangle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.triangle.heightAnchor.constraint(equalToConstant: 21),
            self.triangle.widthAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    func configureAnswer(to answer: String) {
        self.answerLabel.text = answer
    }
}

class TriangleView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        let blurEffect = UIBlurEffect(style: .systemMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        let path = UIBezierPath(ovalIn: rect)
        blurEffectView.frame = path.bounds
        self.insertSubview(blurEffectView, at: 0)

        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        trianglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        trianglePath.addLine(to: CGPoint(x: 0, y: 0))

        let maskImage = CAShapeLayer()
        maskImage.path = trianglePath.cgPath
        maskImage.fillRule = .evenOdd
        self.layer.mask = maskImage
    }
}
