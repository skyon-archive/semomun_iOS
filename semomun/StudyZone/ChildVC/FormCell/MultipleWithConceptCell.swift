//
//  MultipleWithConceptCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithConceptCell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWithConceptCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return 51
    }
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    /* private */
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var topView: UIView!

    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.configureStar()
    }
}

// MARK: Update
extension MultipleWithConceptCell {
    private func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
}
