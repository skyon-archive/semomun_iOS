//
//  ProblemNameCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit

class ProblemNameCell: UICollectionViewCell {
    static let identifier = "ProblemNameCell"
    
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var outerFrame: UIView!
    private lazy var triangleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "yellow")
        return view
    }()
    
    override func awakeFromNib() {
        self.outerFrame.layer.cornerRadius = 5
        self.outerFrame.clipsToBounds = true
        self.outerFrame.translatesAutoresizingMaskIntoConstraints = false
        self.configureTriangleView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.outerFrame.backgroundColor = .white
        self.num.textColor = .black
        self.num.text = ""
        self.outerFrame.transform = CGAffineTransform.identity
    }
    
    func configure(to num: String, isStar: Bool, isTerminated: Bool, isWrong: Bool, isCheckd: Bool) {
        self.num.text = num
        
        if isStar {
            self.triangleView.isHidden = false
        } else {
            self.triangleView.isHidden = true
        }
        
        if isTerminated {
            if isWrong {
                self.outerFrame.backgroundColor = UIColor(named: "colorRed")
                self.num.textColor = .white
            } else {
                self.num.textColor = .black
            }
            return
        }
        
        if isCheckd {
            self.num.textColor = UIColor(named: "mint")
        }
    }
    
    func configureSize(isSelect: Bool) {
        if isSelect {
            self.outerFrame.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }
    
    private func configureTriangleView() {
        self.triangleView.translatesAutoresizingMaskIntoConstraints = false
        self.outerFrame.addSubview(self.triangleView)
        NSLayoutConstraint.activate([
            self.triangleView.widthAnchor.constraint(equalToConstant: 18),
            self.triangleView.heightAnchor.constraint(equalToConstant: 18),
            self.triangleView.centerXAnchor.constraint(equalTo: self.outerFrame.trailingAnchor),
            self.triangleView.centerYAnchor.constraint(equalTo: self.outerFrame.topAnchor)
        ])
        self.triangleView.transform = CGAffineTransform(rotationAngle: .pi/4)
    }
    
//    private func setUpTriangle() {
//        let heightWidth = triangleView.frame.size.width
//        let path = CGMutablePath()
//
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x:heightWidth, y: 0))
//        path.addLine(to: CGPoint(x:heightWidth, y:heightWidth))
//        path.addLine(to: CGPoint(x:0, y:0))
//
//        let shape = CAShapeLayer()
//        shape.path = path
//        shape.fillColor = UIColor.yellow.cgColor
//
//        triangleView.layer.insertSublayer(shape, at: 0)
//    }
}
