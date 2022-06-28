//
//  SearchResultHeaderView.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/28.
//

import UIKit

class SearchResultHeaderView: UICollectionReusableView {
    static let identifier = "SearchResultHeaderView"
    
    @IBOutlet weak var headerText: UILabel!
    
    func updateLabel(to text: String) {
        self.headerText.text = text
    }
}
