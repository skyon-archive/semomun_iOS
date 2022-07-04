//
//  AreaResultCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/16.
//

import UIKit

final class TestSubjectResultCell: UITableViewCell {
    /* public */
    static let identifier = "TestSubjectResultCell"
    /* private */
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var rawScoreLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var percentileLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundedBackgroundView.cornerRadius = 10
    }
}

extension TestSubjectResultCell {
    func prepareForReuse(index: Int, info: PrivateTestResultOfDB) {
        self.indexLabel.text = "\(index)"
        self.subjectLabel.text = info.subject
        self.rawScoreLabel.text = "\(info.rawScore)"
        self.deviationLabel.text = "\(info.standardScore)"
        self.percentileLabel.text = "\(info.percentile)"
    }
}
