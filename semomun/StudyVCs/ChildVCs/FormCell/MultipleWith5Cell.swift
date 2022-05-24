//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

protocol CellLayoutable {
    static var identifier: String { get }
    static func topViewHeight(with problem: Problem_Core) -> CGFloat
}

class MultipleWith5Cell: FormCell, CellLayoutable {
    static let identifier = "MultipleWith5Cell"
    static func topViewHeight(with problem: Problem_Core) -> CGFloat {
        return 51
    }
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet weak var topView: UIView!
    
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .bottom)
    }

    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.problem else { return }
        if problem.terminated { return }
        
        let input: Int = sender.tag
        self.updateSolved(input: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.showExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer.circledAnswer)
        self.contentView.addSubview(self.answerView)
        self.answerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerView.widthAnchor.constraint(equalToConstant: 146),
            self.answerView.heightAnchor.constraint(equalToConstant: 61),
            self.answerView.centerXAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor,constant: 5)
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.answerView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 2) { [weak self] in
                self?.answerView.alpha = 0
            }
        }
    }
    
    override func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.configureReuse(contentImage, problem, toolPicker)
        self.configureUI()
    }
    
    // MARK: Configure
    private func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanationBT()
    }
    
    private func configureCheckButtons() {
        guard let problem = self.problem else { return }
        
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
        if let answer = problem.answer,
           problem.terminated == true {
            self.answerBT.isHidden = true
            guard let targetIndex = Int(answer) else { return }
            // 체크 이미지 표시
            self.showResultImage(to: problem.correct)
            self.createCheckImage(to: targetIndex-1)
            self.configureTimerView()
        }
    }
    
    private func createCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.contentView.addSubview(self.checkImageView)
        self.checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 70),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 70),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkNumbers[index].centerXAnchor, constant: 9),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkNumbers[index].centerYAnchor, constant: -9)
        ])
    }
    
    private func configureTimerView() {
        guard let time = self.problem?.time else { return }
        
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    private func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func configureExplanationBT() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
}
