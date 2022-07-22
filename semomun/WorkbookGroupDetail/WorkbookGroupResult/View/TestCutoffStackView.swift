//
//  TestCutoffStackView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/22.
//

import UIKit

final class TestCutoffStackView: UIStackView {
    init() {
        super.init(frame: .zero)
        self.configureUI()
        self.configureTopLegend()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContent(_ cutoffs: [Cutoff]) {
        cutoffs.prefix(8).forEach { cutoff in
            let rankStackView = UIStackView()
            rankStackView.translatesAutoresizingMaskIntoConstraints = false
            rankStackView.distribution = .fillEqually
            rankStackView.backgroundColor = .getSemomunColor(.white)
            
            let label = UILabel()
            label.font = UIFont(name: UIFont.boldFont, size: 12)
            label.textColor = .getSemomunColor(.black)
            label.text = cutoff.rank + "등급"
            label.textAlignment = .center
            rankStackView.addArrangedSubview(label)
            
            [cutoff.rawScore, cutoff.percentile, cutoff.standardScore].forEach { num in
                let label = UILabel()
                label.font = .smallStyleParagraph
                label.textColor = .getSemomunColor(.black)
                label.text = "\(num)"
                label.textAlignment = .center
                rankStackView.addArrangedSubview(label)
            }
            
            self.addArrangedSubview(rankStackView)
        }
    }
}

extension TestCutoffStackView {
    private func configureUI() {
        self.axis = .vertical
        self.spacing = 0
        self.distribution = .fillEqually
        self.borderWidth = 1
        self.borderColor = .getSemomunColor(.border)
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
    }
    
    private func configureTopLegend() {
        let legendStackView = UIStackView()
        legendStackView.translatesAutoresizingMaskIntoConstraints = false
        legendStackView.distribution = .fillEqually
        legendStackView.backgroundColor = .getSemomunColor(.background)
        ["등급", "원점수", "백분위", "표준점수"].forEach { legendText in
            let label = UILabel()
            label.font = .smallStyleParagraph
            label.textColor = .getSemomunColor(.black)
            label.text = legendText
            label.textAlignment = .center
            legendStackView.addArrangedSubview(label)
        }
        self.addArrangedSubview(legendStackView)
    }
}
