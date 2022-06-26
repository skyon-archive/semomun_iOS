//
//  WorkbookGroupDetailHeaderView.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/06.
//

import UIKit

class WorkbookGroupDetailHeaderView: UICollectionReusableView {
    static let identifier = "WorkbookGroupDetailHeaderView"
    
    @IBOutlet weak var headerText: UILabel!
    
    func updateLabel(to text: String) {
        self.headerText.text = text
    }
}
