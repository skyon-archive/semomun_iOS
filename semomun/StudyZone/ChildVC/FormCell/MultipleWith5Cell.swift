//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

final class MultipleWith5Cell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWith5Cell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return Study5AnswerCheckView.size.height+16
    }
    override var internalTopViewHeight: CGFloat {
        return Study5AnswerCheckView.size.height+16
    }
    /* private */
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let answerCheckView = Study5AnswerCheckView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode?) {
        super.prepareForReuse(contentImage, problem, toolPicker, mode)
        
        let answer = self.problem?.answer?.split(separator: "$").joined(separator: ", ")
        self.toolbarView.updateUI(mode: self.mode, problem: problem, answer: answer)
        self.updateCheckView(problem: problem)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureCheckView()
    }
}

// MARK: CheckView
extension MultipleWith5Cell {
    private func configureCheckView() {
        self.answerCheckView.configureDelegate(delegate: self)
        self.contentView.addSubview(self.answerCheckView)
        let rightCorner = CGPoint(self.contentView.frame.maxX, 0)
        let size = Study5AnswerCheckView.size
        let rightMargin: CGFloat = UIWindow.isLandscape ? 32 : 16
        self.answerCheckView.frame = CGRect(origin: CGPoint(rightCorner.x - rightMargin - size.width, rightCorner.y + 16), size: size)
    }
    
    private func updateCheckView(problem: Problem_Core?) {
        guard let problem = problem else { return }
        let userAnswer = problem.solved != nil ? [problem.solved!] : []
        let terminated = problem.terminated
        self.answerCheckView.configureUserAnswer(userAnswer, terminated, shouldMultipleAnswer: false)
        
        guard terminated == true, let answer = problem.answer else { return }
        self.answerCheckView.terminate(answer: [answer], userAnswer: userAnswer)
    }
}

extension MultipleWith5Cell: AnswerCheckDelegate {
    func selectAnswer(to answer: String) {
        self.updateSolved(input: answer)
    }
}
