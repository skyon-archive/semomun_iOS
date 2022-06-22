//
//  ScoreResultView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/21.
//

import UIKit

@IBDesignable
class ScoreResultView: UIView, NibLoadable {
    /* private */
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankContainerBackgroundView: UIView!
    @IBOutlet weak var rawScoreLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var percentileLabel: UILabel!
    @IBOutlet weak var noInternetLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
}

// MARK: Update - 네트워크 상황에 따라 표시 여부가 실시간으로 달라질 수 있음
extension ScoreResultView {
    func updateContent(title: String, scoreResult: ScoreResult, rankContainerBackgroundColor: UIColor) {
        self.updateForInternet()
        
        self.sectionTitleLabel.text = title
        self.rankLabel.text = "\(scoreResult.rank)"
        self.rankContainerBackgroundView.backgroundColor = rankContainerBackgroundColor
        
        self.rawScoreLabel.text = "\(scoreResult.rawScore)"
        self.deviationLabel.text = "\(scoreResult.deviation)"
        self.percentileLabel.text = "\(scoreResult.percentile)"
    }
    
    func updateForNoInternet() {
        self.noInternetLabel.isHidden = false
        self.rankLabel.isHidden = true
        self.rankContainerBackgroundView.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    private func updateForInternet() {
        self.noInternetLabel.isHidden = true
        self.rankLabel.isHidden = false
    }
}

// MARK: Private
extension ScoreResultView {
    private func commonInit() {
        self.setupFromNib()
        self.configureRankContainerShadow()
    }
    
    private func configureRankContainerShadow() {
        self.rankContainerBackgroundView.addAccessibleShadow()
    }
}

