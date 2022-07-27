//
//  SingleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

/// form == 0 && type == 5
final class SingleWith5AnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWith5AnswerVC"
    var viewModel: SingleWith5AnswerVM?
    /* private */
    private let answerView = Study5AnswerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerView.configureDelegate(delegate: self)
        self.view.addSubview(self.answerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateAnswerViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer: viewModel.answerStringForUser())
            self.toolbarView.configureDelegate(self)
        }
        self.updateAnswerView()
        self.updateCorrectImage()
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
        return StudyToolbarView.height + 16
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: Update
extension SingleWith5AnswerVC {
    private func updateCorrectImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension SingleWith5AnswerVC {
    private func updateAnswerViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = Study5AnswerView.size
        self.answerView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateAnswerView() {
        guard let userAnswer = self.viewModel?.savedSolved,
              let terminated = self.viewModel?.problem?.terminated,
              let shouldMultipleAnswer = self.viewModel?.shouldChooseMultipleAnswer else { return }
        self.answerView.configureUserAnswer(userAnswer, terminated, shouldMultipleAnswer: shouldMultipleAnswer)
        
        guard terminated == true, let answer = self.viewModel?.answer else { return }
        self.answerView.terminate(answer: answer, userAnswer: userAnswer)
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

extension SingleWith5AnswerVC: AnswerViewDelegate {
    func selectAnswer(to answer: String) {
        self.viewModel?.updateSolved(userAnswer: answer)
    }
}

extension SingleWith5AnswerVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
