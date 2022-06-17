//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

final class MultipleWith5Cell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "MultipleWith5Cell"
    static func topViewHeight(with problem: Problem_Core) -> CGFloat {
        return 51
    }
    override var internalTopViewHeight: CGFloat {
        return 51
    }
    /* private */
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var checkNumbers: [UIButton]!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hideCheckImage()
    }

    @IBAction func selectAnswer(_ sender: UIButton) {
        guard let problem = self.problem,
        problem.terminated == false else { return }
        
        let selectedAnswer: Int = sender.tag
        self.updateSolved(input: "\(selectedAnswer)")
        
        self.updateCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.selectExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        let answerConverted = answer.split(separator: "$").joined(separator: ", ")
        self.answerView.configureAnswer(to: answerConverted)
        
        self.contentView.addSubview(self.answerView)
        NSLayoutConstraint.activate([
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor),
            self.answerView.leadingAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
        ])
        self.answerView.showShortTime()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        self.updateCheckButtons()
        self.updateCorrectImage()
        self.updateStar()
        self.updateAnswer()
        self.updateExplanationBT()
    }
    
    // MARK: override 구현
    override func configureTimerLayout() {
        self.contentView.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
    }
    
    override func addTopShadow() {
        self.topView.addAccessibleShadow()
        self.topView.clipAccessibleShadow(at: .exceptTop)
    }
    
    override func removeTopShadow() {
        self.topView.removeAccessibleShadow()
    }
}

// MARK: Configure
extension MultipleWith5Cell {
    
}

// MARK: Update
extension MultipleWith5Cell {
    private func updateCheckButtons() {
        guard let problem = self.problem else { return }
        
        // 일단 모든 버튼 표시 구현
        for bt in checkNumbers {
            bt.backgroundColor = UIColor.white
            bt.setTitleColor(UIColor(.deepMint), for: .normal)
        }
        
        // 사용자 체크한 버튼 선택 표시
        if let solved = problem.solved {
            guard let targetIndex = Int(solved) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(.deepMint)
            self.checkNumbers[targetIndex-1].setTitleColor(UIColor.white, for: .normal)
        }
        
        // 채점이 완료된 경우 해설 버튼 숨기고 정답에 체크 이미지 추가
        if let answer = problem.answer, problem.terminated {
            self.answerBT.isHidden = true
            guard let targetIndex = Int(answer) else { return }
            self.showCheckImage(to: targetIndex-1)
        }
    }
    
    /// 정답 여부를 OX 이미지로 표시
    private func updateCorrectImage() {
        guard let problem = self.problem, problem.terminated else { return }
        
        self.showCorrectImage(isCorrect: problem.correct)
    }
    
    private func updateStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    private func updateAnswer() {
        if self.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.answerBT.isUserInteractionEnabled = true
            self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
    
    private func updateExplanationBT() {
        self.explanationBT.isSelected = false
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanationBT.isUserInteractionEnabled = true
            self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        }
    }
}

extension MultipleWith5Cell {
    private func showCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.checkNumbers[index].addSubview(self.checkImageView)
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 70),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 70),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkNumbers[index].centerXAnchor, constant: 9),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkNumbers[index].centerYAnchor, constant: -9)
        ])
    }
    private func hideCheckImage() {
        self.checkImageView.removeFromSuperview()
    }
}
