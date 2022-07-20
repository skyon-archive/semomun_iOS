//
//  TestCutoffStackView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/07/22.
//

import UIKit

/// 등급별 원점수, 백분위, 표준점수를 나타내는 표
final class TestCutoffStackView: UIStackView {
    /* private */
    /// 등급을 나타내는 굵은 라벨
    private class RankLabel: UILabel {
        convenience init(text: String) {
            self.init(frame: .zero)
            self.font = UIFont(name: UIFont.boldFont, size: 12)
            self.textColor = .getSemomunColor(.black)
            self.text = text + "등급"
            self.textAlignment = .center
        }
    }
    private class RegularLabel: UILabel {
        convenience init(text: String) {
            self.init(frame: .zero)
            self.font = .smallStyleParagraph
            self.textColor = .getSemomunColor(.black)
            self.text = text
            self.textAlignment = .center
        }
    }
    /// 최상단 범례를 위한 수평 stackView
    private class LegendStackView: UIStackView {
        convenience init() {
            self.init(frame: .zero)
            self.distribution = .fillEqually
            self.backgroundColor = .getSemomunColor(.background)
        }
    }
    /// LegendStackView 아래로 이어지는 등급별 정보를 표시하는 수평 stackView
    private class RankStackView: UIStackView {
        convenience init() {
            self.init(frame: .zero)
            self.distribution = .fillEqually
            self.backgroundColor = .getSemomunColor(.white)
        }
        func configureOrangeBorder() {
            let borderView = UIView()
            borderView.translatesAutoresizingMaskIntoConstraints = false
            borderView.layer.borderColor = UIColor.getSemomunColor(.orangeRegular).cgColor
            borderView.layer.borderWidth = 1
            borderView.layer.cornerRadius = .cornerRadius4
            borderView.layer.cornerCurve = .continuous
            borderView.layer.masksToBounds = true
            self.addSubview(borderView)
            NSLayoutConstraint.activate([
                borderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
                borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
                borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
                borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            ])
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        self.configureUI()
        self.configureTopLegend()
    }
    
    func configureContent(cutoffs: [Cutoff], userRank: String) {
        cutoffs.prefix(8).forEach { cutoff in
            let rankStackView = RankStackView()
            
            let rankLabel = RankLabel(text: cutoff.rank)
            rankStackView.addArrangedSubview(rankLabel)
            
            [cutoff.rawScore, cutoff.percentile, cutoff.standardScore].forEach { num in
                let label = RegularLabel(text: "\(num)")
                rankStackView.addArrangedSubview(label)
            }
            
            if userRank == cutoff.rank {
                rankStackView.configureOrangeBorder()
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
        let legendStackView = LegendStackView()
        ["등급", "원점수", "백분위", "표준점수"].forEach { legendText in
            let label = RegularLabel(text: legendText)
            legendStackView.addArrangedSubview(label)
        }
        self.addArrangedSubview(legendStackView)
    }
}
