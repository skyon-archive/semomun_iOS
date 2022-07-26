//
//  SingleWith4AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

/// form == 0 && type == 4
final class SingleWith4AnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWith4AnswerVC"
    var viewModel: SingleWith4AnswerVM?
    /* private */
    private let answerCheckView = Study4AnswerCheckView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerCheckView.configureDelegate(delegate: self)
        self.view.addSubview(self.answerCheckView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCheckViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer: viewModel.answerStringForUser())
            self.toolbarView.configureDelegate(self)
        }
        self.updateCheckView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    /* 상위 class를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
//        return self.topView.frame.height
        return 72
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: CheckView
extension SingleWith4AnswerVC {
    private func updateCheckViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = Study4AnswerCheckView.size
        self.answerCheckView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateCheckView() {
        guard let userAnswer = self.viewModel?.savedSolved,
              let terminated = self.viewModel?.problem?.terminated,
              let shouldMultipleAnswer = self.viewModel?.shouldChooseMultipleAnswer else { return }
        self.answerCheckView.configureUserAnswer(userAnswer, terminated, shouldMultipleAnswer: shouldMultipleAnswer)
        
        guard terminated == true, let answer = self.viewModel?.answer else { return }
        self.answerCheckView.terminate(answer: answer, userAnswer: userAnswer)
    }
}

extension SingleWith4AnswerVC: StudyToolbarViewDelegate {
    func toggleBookmark() {
        self.viewModel?.updateStar(to: self.toolbarView.bookmarkSelected)
    }
    
    func toggleExplanation() {
        if self.explanationShown {
            self.closeExplanation()
        } else {
            guard let imageData = self.viewModel?.problem?.explanationImage else { return }
            self.showExplanation(to: UIImage(data: imageData))
        }
    }
}

extension SingleWith4AnswerVC: AnswerCheckDelegate {
    func selectAnswer(to answer: String) {
        self.viewModel?.updateSolved(userAnswer: answer)
    }
}

extension SingleWith4AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
