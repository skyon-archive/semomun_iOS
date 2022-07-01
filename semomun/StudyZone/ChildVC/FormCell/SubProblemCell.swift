//
//  SubProblemCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class SubProblemCell: FormCell, CellLayoutable {
    /* public */
    static let identifier = "SubProblemCell"
    static func topViewHeight(with problem: Problem_Core?) -> CGFloat {
        return 99 + (problem?.terminated ?? false ? 30 : 0)
    }
    override var internalTopViewHeight: CGFloat {
        guard let problem = self.problem else { return 99 }
        
        return 99 + (problem.terminated ? 30 : 0)
    }
    /* private */
    private var solvings: [String?] = [] {
        didSet {
            // 입력된 사용자 답안이 없는 경우 '내 답안' 라벨 숨김
            self.savedAnswerLabel.isHidden = self.problem?.terminated != true && self.solvings.allSatisfy { $0 == nil }
            
            // 사용자가 쓴 답안에 맞게 UI 수정
            if let currentProblemIndex = self.currentProblemIndex {
                self.answerTF.text = solvings[currentProblemIndex]
            }
            
            self.savedAnswerView.reloadData()
        }
    }
    private var answer: [String] = [] {
        didSet { self.realAnswerView.reloadData() }
    }
    private var currentProblemIndex: Int? = nil {
        didSet {
            guard let currentProblemIndex = self.currentProblemIndex else { return }
            self.answerTF.text = solvings[currentProblemIndex]
        }
    }
    /// textField 의 width 값
    private let savedAnswerWidth: CGFloat = 250+10
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var answerTF: UITextField!
    
    @IBOutlet weak var savedAnswerView: UICollectionView!
    @IBOutlet weak var savedAnswerLabel: UILabel!
    @IBOutlet weak var savedAnswersTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var realAnswerView: UICollectionView!
    @IBOutlet weak var returnButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.answerTF.delegate = self
        self.savedAnswerView.delegate = self
        self.savedAnswerView.dataSource = self
        self.realAnswerView.delegate = self
        self.realAnswerView.dataSource = self
        
        self.savedAnswerView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        self.realAnswerView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        
        self.answerTF.addAccessibleShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.answerTF.layer.addBorder([.bottom], color: UIColor(.deepMint) ?? .black, width: 1)
        self.answerTF.clipAccessibleShadow(at: .exceptLeft)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.answerBT.isHidden = false
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
        self.answerView.removeFromSuperview()
        
        let answerConverted = answer.split(separator: "$").joined(separator: ", ")
        self.answerView.configureAnswer(to: answerConverted)
        self.contentView.addSubview(self.answerView)
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
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.returnAction()
    }
    
    override func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        super.prepareForReuse(contentImage, problem, toolPicker)
        
        guard let subProblemCount = problem?.subProblemsCount, subProblemCount > 0 else { return }
        
        // 부분문제 개수에 맞게 선택 버튼 추가
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<Int(subProblemCount) {
            let button = SubProblemCheckButton(size: 30, fontSize: 14, index: i, delegate: self)
            self.stackView.addArrangedSubview(button)
            // 초기 UI: 첫번째 버튼이 클릭된 상태
            if problem?.solved == nil && i == 0 {
                button.isSelected = true
            }
        }
        
        // 사용자 답안 불러와서 적용
        if let solved = problem?.solved {
            self.solvings = solved.components(separatedBy: "$").map {
                $0 == "" ? nil : $0
            }
            self.solvings += .init(repeating: nil, count: Int(subProblemCount) - self.solvings.count)
            self.hideTextField()
        } else {
            self.solvings = .init(repeating: nil, count: Int(subProblemCount))
        }
        
        if self.problem?.terminated == false {
            self.currentProblemIndex = 0
            self.resultView.isHidden = true
        } else {
            self.currentProblemIndex = nil
            self.resultView.isHidden = false
            self.hideTextField()
        }
        
        if self.problem?.terminated == true {
            self.configureAfterTermination()
            self.showCorrectImage(isCorrect: self.problem?.correct ?? false)
            self.answerBT.isHidden = true
        }
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
    
    private func configureAfterTermination() {
        guard let answer = problem?.answer else { return }
        
        // 선택지 터치 불가하게
        self.stackView.arrangedSubviews.forEach {
            $0.isUserInteractionEnabled = false
        }
        
        let answerConverted = answer.split(separator: "$").map { String($0) }
        self.answer = answerConverted
        
        for (idx, zipped) in zip(self.solvings, answerConverted).enumerated() {
            
            guard let button = self.stackView.arrangedSubviews[idx] as? SubProblemCheckButton else { return }
            
            guard let solving = zipped.0 else {
                button.setWrongUI()
                continue
            }
            
            if solving != zipped.1 {
                button.setWrongUI()
            } else {
                button.isSelected = false
            }
        }
    }
}

extension SubProblemCell: SubProblemCheckObservable {
    func checkButton(index: Int) {
        guard let targetButton = self.stackView.arrangedSubviews[safe: index] as? SubProblemCheckButton else {
            assertionFailure()
            return
        }
        targetButton.isSelected.toggle()
        
        if targetButton.isSelected {
            // 켜짐
            self.currentProblemIndex = index
            self.showTextField(animation: true)
        } else {
            // 꺼짐
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
        }
        
        self.updateStackview(except: targetButton)
    }
    
    private func showTextField(animation: Bool = false) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.savedAnswersTrailing.constant = self.savedAnswerWidth
            self.answerTF.alpha = 1
            self.returnButton.alpha = 1
        }
    }
    
    private func hideTextField(animation: Bool = false) {
        UIView.animate(withDuration: animation ? 0.15 : 0) {
            self.savedAnswersTrailing.constant = 0
            self.answerTF.alpha = 0
            self.returnButton.alpha = 0
        }
    }
    
    private func updateStackview(except button: SubProblemCheckButton) {
        self.stackView.arrangedSubviews
            .filter { $0 != button }
            .compactMap { $0 as? SubProblemCheckButton }
            .forEach { $0.isSelected = false; }
    }
}

extension SubProblemCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// 내 답안 collectionview 인덱스 -> 실제 문제 인덱스
    private func getSolvingIndex(from itemIdx: Int) -> Int {
        var subProblemIdx = 0
        var cnt = 0
        for (n, x) in self.solvings.enumerated() {
            if x != nil { cnt += 1 }
            if cnt == itemIdx+1 {
                subProblemIdx = n
                break
            }
        }
        return subProblemIdx
    }
    
    private func getSubproblemName(from itemIdx: Int) -> String {
        let subProblemIdx = self.getSolvingIndex(from: itemIdx)
        guard let subproblemCheckButton = self.stackView.arrangedSubviews[safe: subProblemIdx] as? SubProblemCheckButton,
              let subproblemName = subproblemCheckButton.titleLabel?.text else {
            return ""
        }
        return subproblemName
    }
    
    private func getSavedCellTitle(at itemIdx: Int) -> String {
        let subproblemName = self.getSubproblemName(from: itemIdx)
        
        guard let solved = self.solvings.compactMap({$0})[safe: itemIdx] else { return "" }
        
        return "\(subproblemName): \(solved)"
    }
    
    private func getAnswerCellTitle(at itemIdx: Int) -> String {
        guard let button = self.stackView.arrangedSubviews[itemIdx] as? SubProblemCheckButton else {
            return ""
        }
        guard let buttonTitle = button.titleLabel?.text else {
            return ""
        }
        return "\(buttonTitle): \(self.answer[itemIdx])"
    }
    
    private func getSavedCellTitleAfterTermination(at itemIdx: Int) -> String {
        guard let button = self.stackView.arrangedSubviews[itemIdx] as? SubProblemCheckButton else {
            return ""
        }
        let buttonTitle = button.titleLabel?.text ?? ""
        let solved = self.solvings[itemIdx] ?? "미기입"
        return "\(buttonTitle): \(solved)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.savedAnswerView {
            if self.problem?.terminated == true {
                return self.answer.count
            } else {
                return self.solvings.compactMap({$0}).count
            }
        } else {
            return self.answer.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SavedAnswerCell.identifier, for: indexPath) as? SavedAnswerCell else { return UICollectionViewCell() }
        
        if collectionView == self.savedAnswerView {
            if self.problem?.terminated == true {
                let text = self.getSavedCellTitleAfterTermination(at: indexPath.item)
                cell.configureText(to: text)
                
                if self.solvings[indexPath.item] != self.answer[indexPath.item] {
                    cell.makeWrong()
                } else {
                    cell.makeCorrect()
                }
            } else {
                let text = self.getSavedCellTitle(at: indexPath.item)
                cell.configureText(to: text)
                cell.makeCorrect()
            }
        } else if collectionView == self.realAnswerView {
            let text = self.getAnswerCellTitle(at: indexPath.item)
            cell.configureText(to: text)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.problem?.terminated == false else { return }
        guard collectionView == self.savedAnswerView else { return }
        self.currentProblemIndex = indexPath.item
        
        self.showTextField(animation: true)
        let subProblemIndex = self.getSolvingIndex(from: indexPath.item)
        self.answerTF.text = self.solvings[subProblemIndex]
        guard let targetButton = self.stackView.arrangedSubviews[safe: subProblemIndex] as? SubProblemCheckButton else { return }
        targetButton.isSelected = true
        self.updateStackview(except: targetButton)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text: String
        if collectionView == self.savedAnswerView {
            if self.problem?.terminated == true {
                text = self.getSavedCellTitleAfterTermination(at: indexPath.item)
            } else {
                text = self.getSavedCellTitle(at: indexPath.item)
            }
        } else {
            text = self.getAnswerCellTitle(at: indexPath.item)
        }
        
        let itemSize = text.size(withAttributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .medium)
        ])
        return .init(itemSize.width+20, 30)
    }
}

extension SubProblemCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.returnAction()
        return true
    }
    
    private func returnAction() {
        guard let currentProblemIndex = self.currentProblemIndex else { return }
        self.solvings[currentProblemIndex] = (self.answerTF.text == "" ? nil : self.answerTF.text)
        
        // 답안 저장. 엔터를 눌렀을 경우에만 updateSolved해야함.
        let solvingConverted = self.solvings
            .map { $0 ?? "" }
            .joined(separator: "$")
        self.updateSolved(input: solvingConverted)
        self.updateCorrectPoints()
        // 현재문제 deselect
        guard let subCount = self.problem?.subProblemsCount,
              let currentButton = self.subProblemButton(index: currentProblemIndex) else { return }
        currentButton.isSelected = false
        // 다음문제 있는 경우 다음문제 select
        if currentProblemIndex+1 < Int(subCount),
           let nextButton = self.subProblemButton(index: currentProblemIndex+1) {
            self.currentProblemIndex = currentProblemIndex+1
            nextButton.isSelected = true
            self.updateStackview(except: nextButton)
        }
        // 마지막 문제인 경우 keyboard 내림
        else if currentProblemIndex+1 == Int(subCount) {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
            self.endEditing(true)
        }
    }
}

extension SubProblemCell {
    private func subProblemButton(index: Int) -> SubProblemCheckButton? {
        return self.stackView.arrangedSubviews[safe: index] as? SubProblemCheckButton ?? nil
    }
    
    private func updateCorrectPoints() {
        guard let answer = self.problem?.answer else {
            self.problem?.setValue(0, forKey: Problem_Core.Attribute.correctPoints.rawValue)
            return
        }
        let answers = answer.split(separator: "$").map { String($0) }
        var points: Int64 = 0
        for i in 0..<answers.count {
            if let input = self.solvings[safe: i],
               input == answers[i] {
                points += 1
            }
        }
        self.problem?.setValue(points, forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
}
