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
        self.configureNotification()
        self.answerView.configureDelegate(delegate: self)
        self.answerView.textField.addTarget(self, action: #selector(updateAnswer), for: .editingChanged)
        self.view.addSubview(self.answerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateAnswerViewFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewModel = viewModel {
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer:  viewModel.answerStringForUser())
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
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

// MARK: Update
extension SingleWithTextAnswerVC {
    private func updateCorrectImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension SingleWithTextAnswerVC {
    private func updateAnswerViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = StudyShortTextAnswerView.size(terminated: self.viewModel?.problem?.terminated ?? false, isCorrect: self.viewModel?.problem?.correct ?? false)
        self.answerView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateAnswerView() {
        let terminated = self.viewModel?.problem?.terminated ?? false
        let userAnswer = self.viewModel?.problem?.solved
        self.answerView.configureUserAnswer(userAnswer)
        
        guard terminated == true, let answer = self.viewModel?.problem?.answer else { return }
        self.answerView.terminate(answer: answer, userAnswer: userAnswer)
    }
}

// MARK: StudyToolbar
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

extension SingleWithTextAnswerVC: UITextFieldDelegate {
    @objc private func updateAnswer() {
        if let text = self.answerView.textField.text {
            self.viewModel?.updateSolved(answer: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateAnswer()
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = StudyShortTextAnswerView.size(terminated: self.viewModel?.problem?.terminated ?? false, isCorrect: self.viewModel?.problem?.correct ?? false)
        let defaultAnswerViewFrame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
        
        if defaultAnswerViewFrame.origin.y == self.answerView.frame.origin.y {
            self.answerView.frame.origin.y -= frame.height
        } else {
            self.answerView.frame = defaultAnswerViewFrame
        }
    }
}

extension SingleWithTextAnswerVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
