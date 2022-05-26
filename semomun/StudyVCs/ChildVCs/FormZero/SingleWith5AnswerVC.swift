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
    @IBOutlet var checkNumbers: [UIButton]!
    
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    var viewModel: SingleWith5AnswerVM?
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    private lazy var timerView = ProblemTimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setViewToDefault()
        self.configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 didAppear")
        
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 willDisappear")
        self.setViewToDefault()
        self.viewModel?.endTimeRecord()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .bottom)
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.viewModel?.problem,
              problem.terminated == false else { return }
        
        let input: Int = sender.tag
        self.viewModel?.updateSolved(withSelectedAnswer: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage else { return }
        let explanationImage = UIImage(data: imageData)
        self.showExplanation.toggle()
        
        if self.showExplanation {
            self.showExplanation(to: explanationImage)
        } else {
            self.closeExplanation()
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answer() else { return }
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
    
    override var _topViewTrailingConstraint: NSLayoutConstraint? {
        return self.topViewTrailingConstraint
    }
    
    override var topHeight: CGFloat {
        self.topView.frame.height
    }
    
    override var problemResult: Bool? {
        if let problem = self.viewModel?.problem, problem.terminated && problem.answer != nil {
            return problem.correct
        } else {
            return nil
        }
    }
    
    override var drawing: Data? {
        self.viewModel?.problem?.drawing
    }
    
    override var drawingWidth: CGFloat? {
        CGFloat(self.viewModel?.problem?.drawingWidth ?? 0)
    }
    
    override func previousPage() {
        self.viewModel?.delegate?.beforePage()
    }
    
    override func nextPage() {
        self.viewModel?.delegate?.nextPage()
    }
    
    override func savePencilData(data: Data, width: CGFloat) {
        self.viewModel?.updatePencilData(to: data, width: Double(width))
    }

// MARK: - Configures
    private func setViewToDefault() {
        self.checkImageView.removeFromSuperview()
        self.timerView.removeFromSuperview()
        self.answerView.removeFromSuperview()
    }
    
    private func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    private func configureCheckButtons() {
        guard let problem = self.viewModel?.problem else { return }
        
        // 일단 모든 버튼 표시 구현
        for bt in checkNumbers {
            bt.backgroundColor = UIColor.white
            bt.setTitleColor(UIColor(.deepMint), for: .normal)
        }
        // 사용자 체크한 데이터 표시
        if let solved = problem.solved {
            guard let targetIndex = Int(solved) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(.deepMint)
            self.checkNumbers[targetIndex-1].setTitleColor(UIColor.white, for: .normal)
        }
        // 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
        if let answer = self.viewModel?.answer(),
           problem.terminated == true {
            self.answerBT.isHidden = true
            if answer != "복수",
               let targetIndex = Int(answer) {
                self.createCheckImage(to: targetIndex-1)
                self.configureTimerView()
            }
        } else {
            self.answerBT.isHidden = false
        }
    }
    
    private func createCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.view.addSubview(self.checkImageView)
        self.checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 75),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 75),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkNumbers[index].centerXAnchor, constant: 10),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkNumbers[index].centerYAnchor, constant: -10)
        ])
    }
    
    private func configureTimerView() {
        guard let time = self.viewModel?.problem?.time else { return }
        
        self.view.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
}
