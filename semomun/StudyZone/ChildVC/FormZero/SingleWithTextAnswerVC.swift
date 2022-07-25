//
//  SingleWithTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWithTextAnswerVC: FormZero {
    /* public */
    static let identifier = "SingleWithTextAnswerVC" // form == 0 && type == 1
    static let storyboardName = "Study"
    var viewModel: SingleWithTextAnswerVM?
    /* private */
//    @IBOutlet weak var solveInput: UITextField!
    
    private lazy var answerResultView: ProblemTextResultView = {
        let answerResultView = ProblemTextResultView()
        answerResultView.translatesAutoresizingMaskIntoConstraints = false
        return answerResultView
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateSolved()
        self.updateUIIfTerminated()
        if let viewModel = viewModel {
            self.toolbarView.updateUI(mode: viewModel.mode, problem: viewModel.problem, answer: .some( viewModel.answerStringForUser()))
            self.toolbarView.configureDelegate(self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.answerResultView.removeFromSuperview()
        self.endTimeRecord()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.solveInput.layer.addBorder([.bottom], color: UIColor(.blueRegular) ?? .black, width: 1)
    }
    
    // 주관식 입력 부분
    @IBAction func solveInputChanged(_ sender: UITextField) {
        guard let input = sender.text else { return }
        self.viewModel?.updateSolved(withSelectedAnswer: "\(input)")
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage else { return }
        let explanationImage = UIImage(data: imageData)
        
        if self.explanationShown {
            self.closeExplanation()
        } else {
            self.showExplanation(to: explanationImage)
        }
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


// MARK: Configures
extension SingleWithTextAnswerVC {
    private func configureTextField() {
//        self.solveInput.delegate = self
//        self.solveInput.addTarget(self, action: #selector(updateAnswer), for: .editingChanged)
    }
}

// MARK: Updates
extension SingleWithTextAnswerVC {
    private func updateSolved() {
//        guard let problem = self.viewModel?.problem else { return }
//        self.solveInput.text = problem.solved ?? ""
    }
    
    private func updateUIIfTerminated() {
//        guard let problem = self.viewModel?.problem else { return }
//        if problem.terminated, let answer = problem.answer {
//            self.solveInput.isHidden = true
//            self.configureResultView(answer: answer)
//            self.showResultImage(to: problem.correct)
//        }
    }
}

extension SingleWithTextAnswerVC {
    private func configureResultView(answer: String) {
//        self.view.addSubview(self.answerResultView)
//
//        NSLayoutConstraint.activate([
//            self.answerResultView.heightAnchor.constraint(equalToConstant: 32),
//            self.answerResultView.centerYAnchor.constraint(equalTo: self.solveInput.centerYAnchor),
//            self.answerResultView.trailingAnchor.constraint(equalTo: self.solveInput.trailingAnchor)
//        ])
//
//        if let solved = self.viewModel?.problem?.solved {
//            self.answerResultView.configureSolvedAnswer(to: solved)
//        } else {
//            self.answerResultView.configureSolvedAnswer(to: "미기입")
//        }
//        self.answerResultView.configureAnswer(to: answer)
    }
}

extension SingleWithTextAnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWithTextAnswerVC: UITextFieldDelegate {
    @objc private func updateAnswer() {
//        guard let solved = self.solveInput.text else { return }
//        self.viewModel?.updateSolved(withSelectedAnswer: solved)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.updateAnswer()
//        self.solveInput.resignFirstResponder()
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
