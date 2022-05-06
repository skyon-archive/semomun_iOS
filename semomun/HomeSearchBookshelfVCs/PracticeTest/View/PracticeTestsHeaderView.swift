//
//  PracticeTestsHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/06.
//

import UIKit

class PracticeTestsHeaderView: UICollectionReusableView {
    static let identifier = "PracticeTestsHeaderView"
    
    @IBOutlet weak var headerText: UILabel!
    
    func configure(to text: String) {
        self.headerText.text = text
    }
}
