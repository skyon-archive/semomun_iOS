//
//  MultipleWithNoAnswerCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithNoAnswerCell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWithNoAnswerCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return StudyToolbarView.height + 16
    }
    override var internalTopViewHeight: CGFloat {
        return StudyToolbarView.height + 16
    }
    /* private */
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.toolbarView.updateUI(mode: self.mode, problem: problem, answer: .none)
    }
}
