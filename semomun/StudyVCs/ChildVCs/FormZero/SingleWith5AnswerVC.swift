//
//  SingleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWith5AnswerVC: FormZero {
    static let identifier = "SingleWith5AnswerVC" // form == 0 && type == 5
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var checkButtons: [UIButton]!
    
    var viewModel: SingleWith5AnswerVM?
    
    private lazy var checkImageViews: [UIImageView] = (0..<self.checkNumbers.count).map { _ in
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "check")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        
        return imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTimerViewLayout()
        self.configureCheckButtonLayout()
        self.configureAnswerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateCheckButtons()
        self.updateBookmarkBT()
        self.updateAnswerBT()
        self.updateExplanationBT()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
    }
    
    @IBAction func selectAnswer(_ sender: UIButton) {
        guard self.viewModel?.problem?.terminated == false else { return }
        self.updateSelectedButton(tag: sender.tag)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        self.viewModel?.updateStar(to: self.bookmarkBT.isSelected)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        if self.shouldShowExplanation {
            self.closeExplanation()
        } else {
            guard let imageData = self.viewModel?.problem?.explanationImage else { return }
            let explanationImage = UIImage(data: imageData)
            self.showExplanation(to: explanationImage)
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answerStringForUser() else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer)
        self.view.addSubview(self.answerView)
        self.answerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.answerView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 2) { [weak self] in
                self?.answerView.alpha = 0
            }
        }
    }
    
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
}

// MARK: - Configure
extension SingleWith5AnswerVC {
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
    
    private func configureAnswerViewLayout() {
        self.view.addSubview(self.answerView)
        
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor)
        ])
    }
}

// MARK: Update
extension SingleWith5AnswerVC {
    private func setViewToDefault() {
        self.timerView.removeFromSuperview()
        self.answerView.removeFromSuperview()
        self.checkImageViews.forEach { $0.isHidden = true }
    }
    
    private func updateSelectedButton(tag: Int) {
        guard let vm = self.viewModel else { return }
        
        if vm.shouldChooseMultipleAnswer {
            self.checkNumbers[tag-1].isSelected.toggle()
        } else {
            self.checkNumbers.forEach { $0.isSelected = false }
            self.checkNumbers[tag-1].isSelected = true
        }
        self.updateButtonUI()
        
        // Solved값 업데이트
        let selectedButtonTags = self.checkNumbers.filter(\.isSelected).map(\.tag)
        vm.updateSolved(withSelectedAnswers: selectedButtonTags)
    }
    
    private func configureUI() {
        self.loadSelectedButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    private func loadSelectedButtons() {
        self.checkNumbers.forEach { $0.isSelected = false }
        self.viewModel?.savedSolved.forEach { self.checkNumbers[$0-1].isSelected = true }
        self.updateButtonUI()
        self.updateUIIfTerminated()
    }
    
    /// 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
    private func updateUIIfTerminated() {
        guard let problem = self.viewModel?.problem else { return }
        
        if problem.terminated {
            self.answerBT.isHidden = true
            self.viewModel?.answer.forEach {
                self.checkImageViews[$0-1].isHidden = false
            }
        } else {
            self.answerBT.isHidden = false
        }
    }
    
    private func updateButtonUI() {
        self.checkNumbers.forEach { button in
            if button.isSelected {
                button.backgroundColor = UIColor(.deepMint)
                button.setTitleColor(UIColor.white, for: .normal)
            } else {
                button.backgroundColor = UIColor.white
                button.setTitleColor(UIColor(.deepMint), for: .normal)
            }
        }
    }
    
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
    
    private func configureCheckButtonLayout() {
        zip(self.checkNumbers, self.checkImageViews).forEach { button, imageView in
            button.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 75),
                imageView.heightAnchor.constraint(equalToConstant: 75),
                imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor, constant: 10),
                imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10)
            ])
        }
    }
    
    private func updateBookmarkBT() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func updateAnswerBT() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
}

extension SingleWith5AnswerVC {
    private func createCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.view.addSubview(self.checkImageView)
        self.checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 75),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 75),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkButtons[index].centerXAnchor, constant: 10),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkButtons[index].centerYAnchor, constant: -10)
        ])
    }
}

extension SingleWith5AnswerVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWith5AnswerVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data, width: Double(self.canvasView.frame.width))
    }
}
