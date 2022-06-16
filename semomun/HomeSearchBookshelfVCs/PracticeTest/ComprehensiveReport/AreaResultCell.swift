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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundedBackgroundView.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
