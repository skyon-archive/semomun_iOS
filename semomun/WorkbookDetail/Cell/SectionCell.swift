//
//  SectionCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/14.
//

import UIKit

final class SectionCell: UITableViewCell {
    static let identifier = "SectionCell"
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = ""
    }
    
    func configureCell(title: String) {
        self.nameLabel.text = title
    }
}
