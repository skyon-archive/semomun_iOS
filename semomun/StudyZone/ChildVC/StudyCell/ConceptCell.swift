//
//  ConceptCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class ConceptCell: StudyCell, CellLayoutable, CellRegisterable {
    /* public */
    static let identifier = "ConceptCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return StudyToolbarView.height + 16
    }
    override var internalTopViewHeight: CGFloat {
        return StudyToolbarView.height + 16
    }
    /* private */
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.toolbarView.updateUI(problem: problem, answer: .none)
    }
}
