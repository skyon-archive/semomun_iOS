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
    @IBOutlet weak var scoreResultCollectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupFromNib()
    }
}
