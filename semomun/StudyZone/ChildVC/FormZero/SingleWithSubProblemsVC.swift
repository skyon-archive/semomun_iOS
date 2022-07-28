//
//  SingleWithSubProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit
import Kingfisher
import Combine

final class SingleWithSubProblemsVC: FormZero {
    /* public */
    static let identifier = "SingleWithSubProblemsVC"
    var viewModel: SingleWithSubProblemsVM?
    /* private */
    private let answerView = StudySubProblemsAnswerView()
    private var isTextFieldEditing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNotification()
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
    
    private func configureNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: Update
extension SingleWithSubProblemsVC {
    private func updateCorrectImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension SingleWithSubProblemsVC {
    private func updateAnswerViewFrame() {
        guard let problem = self.problem else { return }
        let terminated = problem.terminated
        let problemCount = Int(problem.subProblemsCount)
        let wrongCount = StudySubProblemsAnswerView.wrongCount(problem: problem)
        
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = StudySubProblemsAnswerView.size(terminated: terminated, problemCount: Int(problemCount), wrongCount: wrongCount)
        self.answerView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateAnswerView() {
        guard let problem = self.viewModel?.problem else { return }
        self.answerView.configureUserAnswer(problem: problem)
        
        guard problem.terminated == true else { return }
        self.answerView.terminate()
    }
}

// MARK: StudyToolbar
extension SingleWithSubProblemsVC: StudyToolbarViewDelegate {
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

extension SingleWithSubProblemsVC: SubproblemsAnswerViewDelegate {
    func selectAnswer(to answer: String) {
        guard let problem = self.problem else { return }
        let count = Int(problem.subProblemsCount)
        let correctCount = count - StudySubProblemsAnswerView.wrongCount(problem: problem)
        self.viewModel?.updateSolved(userAnswer: answer, correctCount: correctCount)
    }
}

extension SingleWithSubProblemsVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.answerView.changeToNextTextField()
        self.answerView.saveUserAnswer()
        return true
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        guard self.isTextFieldEditing == false else { return }
        self.isTextFieldEditing = true
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.answerView.frame.origin.y -= frame.height
    }
    
    @objc func keyboardWillDisappear() {
        self.updateAnswerViewFrame()
        self.isTextFieldEditing = false
    }
}
