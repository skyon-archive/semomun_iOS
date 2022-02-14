//
//  SearchResultTagCell.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/26.
//

import UIKit

class SearchResultTagCell: UITableViewCell {
    static let identifier = "SearchResultTagCell"
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.title.text = ""
    }
    
    func configure(tag: String) {
        self.title.text = "#\(tag)"
    }
}
