//
//  SingleWithTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class SingleWithTextAnswerVC: FormZero {
    static let identifier = "SingleWithTextAnswerVC" // form == 0 && type == 1
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var solveInput: UITextField!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTrailing: NSLayoutConstraint!
    
    var viewModel: SingleWithTextAnswerVM?
    
    private lazy var answerResultView: ProblemTextResultView = {
        let answerResultView = ProblemTextResultView()
        answerResultView.translatesAutoresizingMaskIntoConstraints = false
        return answerResultView
    }()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField()
        self.configureTimerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateSolved()
        self.updateUIIfTerminated()
        self.updateBookmark()
        self.updateAnswerBT()
        self.updateExplanationBT()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.solveInput.isHidden = false
        self.answerBT.isHidden = false
        self.answerResultView.removeFromSuperview()
        self.endTimeRecord()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.solveInput.layer.addBorder([.bottom], color: UIColor(.deepMint) ?? .black, width: 1)
    }
    
    // 주관식 입력 부분
    @IBAction func solveInputChanged(_ sender: UITextField) {
        guard let input = sender.text else { return }
        self.viewModel?.updateSolved(withSelectedAnswer: "\(input)")
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
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
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answerStringForUser() else { return }
        self.answerView.configureAnswer(to: answer)
        
        self.view.addSubview(self.answerView)
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor)
        ])
        self.answerView.showShortTime()
    }
    
    /* 상위 class를 위하여 override가 필요한 Property들 */
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var topViewHeight: CGFloat {
        return self.topView.frame.height
    }
    override var topViewTrailingConstraint: NSLayoutConstraint? {
        return self.topViewTrailing
    }
}


// MARK: Configures
extension SingleWithTextAnswerVC {
    private func configureTextField() {
        self.solveInput.delegate = self
        self.solveInput.addTarget(self, action: #selector(updateAnswer), for: .editingChanged)
    }
    
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
}

// MARK: Updates
extension SingleWithTextAnswerVC {
    private func updateSolved() {
        guard let problem = self.viewModel?.problem else { return }
        self.solveInput.text = problem.solved ?? ""
    }
    
    private func updateUIIfTerminated() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated, let answer = problem.answer {
            self.solveInput.isHidden = true
            self.answerBT.isHidden = true
            self.configureResultView(answer: answer)
            self.showResultImage(to: problem.correct)
        }
    }
    
    private func updateBookmark() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func updateAnswerBT() {
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.answerBT.isUserInteractionEnabled = true
            self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
    
    private func updateExplanationBT() {
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanationBT.isUserInteractionEnabled = true
            self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
}

extension SingleWithTextAnswerVC {
    private func configureResultView(answer: String) {
        self.view.addSubview(self.answerResultView)
        
        NSLayoutConstraint.activate([
            self.answerResultView.heightAnchor.constraint(equalToConstant: 32),
            self.answerResultView.centerYAnchor.constraint(equalTo: self.solveInput.centerYAnchor),
            self.answerResultView.trailingAnchor.constraint(equalTo: self.solveInput.trailingAnchor)
        ])
        
        if let solved = self.viewModel?.problem?.solved {
            self.answerResultView.configureSolvedAnswer(to: solved)
        } else {
            self.answerResultView.configureSolvedAnswer(to: "미기입")
        }
        self.answerResultView.configureAnswer(to: answer)
    }
}

extension SingleWithTextAnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWithTextAnswerVC: UITextFieldDelegate {
    @objc private func updateAnswer() {
        guard let solved = self.solveInput.text else { return }
        self.viewModel?.updateSolved(withSelectedAnswer: solved)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateAnswer()
        self.solveInput.resignFirstResponder()
        return true
    }
}
