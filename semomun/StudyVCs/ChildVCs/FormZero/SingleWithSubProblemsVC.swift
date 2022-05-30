//
//  SingleWithSubProblemsVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit
import Kingfisher

class SingleWithSubProblemsVC: FormZero {
    static let identifier = "SingleWithSubProblemsVC"
    static let storyboardName = "Study"
    
    var viewModel: SingleWithSubProblemsVM?
    
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
    
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.savedAnswerView.delegate = self
        self.savedAnswerView.dataSource = self
        self.realAnswerView.delegate = self
        self.realAnswerView.dataSource = self
        self.answerTF.delegate = self
        
        self.savedAnswerView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        self.realAnswerView.register(SavedAnswerCell.self, forCellWithReuseIdentifier: SavedAnswerCell.identifier)
        
        self.configureTimerViewLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.answerTF.addAccessibleShadow()
        
        guard let subProblemCount = self.viewModel?.problem?.subProblemsCount, subProblemCount > 0 else { return }
        guard let problem = self.viewModel?.problem else { return }
        
        // 부분문제 개수에 맞게 선택 버튼 추가
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 0..<Int(subProblemCount) {
            let button = SubProblemCheckButton(size: 32, fontSize: 16, index: i, delegate: self)
            self.stackView.addArrangedSubview(button)
            // 초기 UI: 첫번째 버튼이 클릭된 상태
            if problem.solved == nil && i == 0 {
                button.isSelected = true
                button.select()
            }
        }
        
        // 사용자 답안 불러와서 적용
        if let solved = problem.solved {
            self.solvings = solved.components(separatedBy: "$").map {
                $0 == "" ? nil : $0
            }
            self.solvings += .init(repeating: nil, count: Int(subProblemCount) - self.solvings.count)
            self.hideTextField()
        } else {
            self.solvings = .init(repeating: nil, count: Int(subProblemCount))
        }
        
        if problem.terminated == false {
            self.currentProblemIndex = 0
            self.resultView.isHidden = true
        } else {
            self.currentProblemIndex = nil
            self.resultView.isHidden = false
            self.hideTextField()
        }
        
        if problem.terminated == true {
            self.configureAfterTermination()
            self.resultImageView.isHidden = false
            self.hideTextField(animation: true)
        } else {
            self.showTextField(animation: false)
        }
        
        self.answerBT.isHidden = problem.terminated
        self.configureStar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTimeRecord()
        self.answerBT.isHidden = false
    }
    
    override var problem: Problem_Core? {
        return self.viewModel?.problem
    }
    override var internalTopViewHeight: CGFloat {
        return self.topView.frame.height
    }
    
    // textField 의 width 값
    private let savedAnswerWidth: CGFloat = 250+10
    
    private var currentProblemIndex: Int? = nil {
        didSet {
            guard let currentProblemIndex = self.currentProblemIndex else { return }
            self.answerTF.text = solvings[currentProblemIndex]
        }
    }
    
    private var solvings: [String?] = [] {
        didSet {
            // 입력된 사용자 답안이 없는 경우 '내 답안' 라벨 숨김
            self.savedAnswerLabel.isHidden = self.viewModel?.problem?.terminated != true && self.solvings.allSatisfy { $0 == nil }
            
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.answerTF.layer.addBorder([.bottom], color: UIColor(.deepMint) ?? .black, width: 1)
        self.answerTF.clipAccessibleShadow(at: .exceptLeft)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage,
            let image = UIImage(data: imageData) else { return }
        self.explanationBT.isSelected.toggle()
        if self.explanationBT.isSelected {
            self.showExplanation(to: image)
        } else {
            self.closeExplanation()
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.problem?.answer else { return }
        self.answerView.removeFromSuperview()
        
        let answerConverted = answer.split(separator: "$").joined(separator: ", ")
        self.answerView.configureAnswer(to: answerConverted)
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
    
    @IBAction func returnButtonAction(_ sender: Any) {
        self.returnAction()
    }
    
    private func configureAfterTermination() {
        guard let answer = self.viewModel?.problem?.answer else { return }
        
        // 선택지 터치 불가하게
        self.stackView.arrangedSubviews.forEach {
            $0.isUserInteractionEnabled = false
        }
        
        let answerConverted = answer.split(separator: "$").map { String($0) }
        self.answer = answerConverted
        
        for (idx, zipped) in zip(self.solvings, answerConverted).enumerated() {
            
            guard let button = self.stackView.arrangedSubviews[idx] as? SubProblemCheckButton else { return }
            
            guard let solving = zipped.0 else {
                button.wrong()
                continue
            }
            
            if solving != zipped.1 {
                button.wrong()
            } else {
                button.deselect()
            }
        }
    }
}

extension SingleWithSubProblemsVC: SubProblemCheckObservable {
    func checkButton(index: Int) {
        guard let targetButton = self.stackView.arrangedSubviews[safe: index] as? SubProblemCheckButton else {
            assertionFailure()
            return
        }
        targetButton.isSelected.toggle()
        
        if targetButton.isSelected {
            // 켜짐
            self.currentProblemIndex = index
            targetButton.select()
            self.showTextField(animation: true)
        } else {
            // 꺼짐
            self.currentProblemIndex = nil
            targetButton.deselect()
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
            .forEach { $0.isSelected = false; $0.deselect() }
    }
}

extension SingleWithSubProblemsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            if self.viewModel?.problem?.terminated == true {
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
            if self.viewModel?.problem?.terminated == true {
                let text = self.getSavedCellTitleAfterTermination(at: indexPath.item)
                cell.configureText(to: text)
                
                if self.solvings[indexPath.item] != self.answer[indexPath.item] {
                    cell.makeWrong()
                } else {
                    cell.makeCorrect()
                }
            } else {
                let text = self.getSavedCellTitle(at: indexPath.item)
                cell.makeCorrect()
                cell.configureText(to: text)
            }
        } else if collectionView == self.realAnswerView {
            let text = self.getAnswerCellTitle(at: indexPath.item)
            cell.configureText(to: text)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.viewModel?.problem?.terminated == false else { return }
        guard collectionView == self.savedAnswerView else { return }
        self.currentProblemIndex = indexPath.item
        
        self.showTextField(animation: true)
        let subProblemIndex = self.getSolvingIndex(from: indexPath.item)
        self.answerTF.text = self.solvings[subProblemIndex]
        guard let targetButton = self.stackView.arrangedSubviews[safe: subProblemIndex] as? SubProblemCheckButton else { return }
        targetButton.isSelected = true
        targetButton.select()
        self.updateStackview(except: targetButton)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text: String
        if collectionView == self.savedAnswerView {
            if self.viewModel?.problem?.terminated == true {
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

extension SingleWithSubProblemsVC: UITextFieldDelegate {
    // TODO: 빈 문자열 입력시 입력된 답안 제거?
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
        self.viewModel?.updateSolved(withSelectedAnswer: solvingConverted)
        self.updateCorrectPoints()
        // 현재문제 deselect
        guard let subCount = self.viewModel?.problem?.subProblemsCount,
              let currentButton = self.subProblemButton(index: currentProblemIndex) else { return }
        currentButton.isSelected = false
        currentButton.deselect()
        // 다음문제 있는 경우 다음문제 select
        if currentProblemIndex+1 < Int(subCount),
           let nextButton = self.subProblemButton(index: currentProblemIndex+1) {
            self.currentProblemIndex = currentProblemIndex+1
            nextButton.isSelected = true
            nextButton.select()
            self.updateStackview(except: nextButton)
        }
        // 마지막 문제인 경우 keyboard 내림
        else if currentProblemIndex+1 == Int(subCount) {
            self.currentProblemIndex = nil
            self.hideTextField(animation: true)
            self.view.endEditing(true)
        }
    }
}

extension SingleWithSubProblemsVC {
    private func subProblemButton(index: Int) -> SubProblemCheckButton? {
        return self.stackView.arrangedSubviews[safe: index] as? SubProblemCheckButton ?? nil
    }
    
    private func updateCorrectPoints() {
        guard let answer = self.viewModel?.problem?.answer else {
            self.viewModel?.problem?.setValue(0, forKey: Problem_Core.Attribute.correctPoints.rawValue)
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
        self.viewModel?.problem?.setValue(points, forKey: Problem_Core.Attribute.correctPoints.rawValue)
    }
}

extension SingleWithSubProblemsVC: TimeRecordControllable {
    func endTimeRecord() {
        self.viewModel?.endTimeRecord()
    }
}

extension SingleWithSubProblemsVC {
    private func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func configureTimerViewLayout() {
        self.view.addSubview(self.timerView)
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
    }
}
