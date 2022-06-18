//
//  AreaResultCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/16.
//

import UIKit

class AreaResultCell: UITableViewCell {
    /* public */
    static let identifier = "AreaResultCell"
    /* private */
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var areaTitleLabel: UILabel!
    @IBOutlet weak var rawScoreLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var percentileLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundedBackgroundView.cornerRadius = 10
    }
}

extension AreaResultCell {
    func prepareForReuse(index: Int, areaTitle: String, rawScore: Int, deviation: Int, percentile: Int) {
        self.indexLabel.text = "\(index)."
        self.areaTitleLabel.text = areaTitle
        self.rawScoreLabel.text = "\(rawScore)"
        self.deviationLabel.text = "\(deviation)"
        self.percentileLabel.text = "\(percentile)"
    }
}
