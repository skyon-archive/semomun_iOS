//
//  SingleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWith5AnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWith5AnswerVC" // form == 0 && type == 5
    var viewModel: SingleWith5AnswerVM?
    /* private */
    private let answerCheckView = Study5AnswerCheckView()
    
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
        return Study5AnswerCheckView.size.height+16
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: CheckView
extension SingleWith5AnswerVC {
    private func updateCheckViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = Study5AnswerCheckView.size
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

// MARK: StudyToolbar
extension SingleWith5AnswerVC: StudyToolbarViewDelegate {
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

extension SingleWith5AnswerVC: AnswerCheckDelegate {
    func selectAnswer(to answer: String) {
        self.viewModel?.updateSolved(userAnswer: answer)
    }
}

extension SingleWith5AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
