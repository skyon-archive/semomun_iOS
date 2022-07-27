//
//  SingleWithLongTextAnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/07/27.
//

import UIKit
import PencilKit

/// form == 0 && type == 2
final class SingleWithLongTextAnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWithLongTextAnswerVC"
    var viewModel: SingleWithLongTextAnswerVM?
    /* private */
    private let answerView = StudyLongTextAnswerView()
    private var isTextFieldEditing: Bool = false
    
    // MARK: View lifecycle
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: Update
extension SingleWithLongTextAnswerVC {
    private func updateCorrectImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated == true {
            self.updateCorrectImage(isCorrect: problem.correct)
        }
    }
}

// MARK: AnswerView
extension SingleWithLongTextAnswerVC {
    private func updateAnswerViewFrame() {
        let bottomPoint = CGPoint(self.view.frame.maxX, self.view.frame.maxY)
        let size = StudyLongTextAnswerView.size
        self.answerView.frame = CGRect(origin: CGPoint(bottomPoint.x - 16 - size.width, bottomPoint.y - 16 - size.height), size: size)
    }
    
    private func updateAnswerView() {
        let userAnswer = self.viewModel?.problem?.solved
        self.answerView.configureUserAnswer(userAnswer)
        guard self.problem?.terminated == true else { return }
        self.answerView.terminate()
    }
}

// MARK: StudyToolbar
extension SingleWithLongTextAnswerVC: StudyToolbarViewDelegate {
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

// MARK: AnswerView
extension SingleWithLongTextAnswerVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = self.answerView.textView.text {
            self.viewModel?.updateSolved(answer: text)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == StudyLongTextAnswerView.placeholderTextColor {
            textView.text = ""
            textView.textColor = UIColor.getSemomunColor(.black)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = StudyLongTextAnswerView.placeholderTextColor
            textView.text = StudyLongTextAnswerView.placeHolder
        }
    }
}

// MARK: Keyboard
extension SingleWithLongTextAnswerVC {
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

extension SingleWithLongTextAnswerVC: TimerTerminateable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}
