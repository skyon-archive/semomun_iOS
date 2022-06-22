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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.rankContainerBackgroundView.addAccessibleShadow(direction: .bottom, shadowRadius: 5)
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
}

// MARK: Private
extension ScoreResultView {
    private func commonInit() {
        self.setupFromNib()
    }
    
    /// - Note: UI업데이트와 content 설정을 동시에 하기 위해 updateForNoInternet과 달리 의도적으로 외부에서 접근 불가능하게 설정
    private func updateForInternet() {
        self.noInternetLabel.isHidden = true
        self.rankLabel.isHidden = false
    }
}
