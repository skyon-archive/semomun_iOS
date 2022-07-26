//
//  SingleWithTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

/// form == 0 && type == 1
final class SingleWithTextAnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWithTextAnswerVC"
    static let storyboardName = "Study"
    var viewModel: SingleWithTextAnswerVM?
    /* private */
    private let answerView = StudyShortTextAnswerView()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answerView.configureDelegate(delegate: self)
        self.view.addSubview(self.answerView)
        self.answerView.textField.addTarget(self, action: #selector(updateAnswer), for: .editingChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCheckViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer:  viewModel.answerStringForUser())
            self.toolbarView.configureDelegate(self)
        }
        self.updateUIIfTerminated()
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
        return StudyShortTextAnswerView.size(terminated: self.viewModel?.problem?.terminated ?? false, isCorrect: self.viewModel?.problem?.correct ?? false).height
    }
    /* 상위 class를 위하여 override가 필요한 메소드들 */
    override func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}

// MARK: Updates
extension SingleWithTextAnswerVC {
    private func updateUIIfTerminated() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated == true {
            self.showResultImage(to: problem.correct)
        }
    }
}

// MARK: CheckView
extension SingleWithTextAnswerVC {
    private func updateCheckViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = StudyShortTextAnswerView.size(terminated: self.viewModel?.problem?.terminated ?? false, isCorrect: self.viewModel?.problem?.correct ?? false)
        self.answerView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateCheckView() {
        guard let userAnswer = self.viewModel?.problem?.solved,
              let terminated = self.viewModel?.problem?.terminated else {
            self.answerView.configureUserAnswer("")
            return
        }
        
        self.answerView.configureUserAnswer(userAnswer)
        
        guard terminated == true, let answer = self.viewModel?.problem?.answer else { return }
        self.answerView.terminate(answer: answer, userAnswer: userAnswer)
    }
}

extension SingleWithTextAnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWithTextAnswerVC: UITextFieldDelegate {
    @objc private func updateAnswer() {
        if let text = self.answerView.textField.text {
            self.viewModel?.updateSolved(withSelectedAnswer: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateAnswer()
        textField.resignFirstResponder()
        return true
    }
}

extension SingleWithTextAnswerVC: StudyToolbarViewDelegate {
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
