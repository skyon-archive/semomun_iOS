//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWith5Cell: UICollectionViewCell, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWith5Cell"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: CollectionCellDelegate?
    
    var toolPicker: PKToolPicker?
    lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
        print("\(Self.identifier) awakeFromNib")
    }
    
    override func prepareForReuse() {
        self.configureUI()
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        toolPicker?.removeObserver(canvasView)
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.problem else { return }
        if problem.terminated { return }
        
        let input: Int = sender.tag
        self.updateSolved(problem: problem, input: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
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
    
    // MARK: Configure
    private func configureUI() {
        self.resultImageView.removeFromSuperview()
        self.checkImageView.removeFromSuperview()
        self.answerBT.isHidden = false
        self.timerView.removeFromSuperview()
        self.answerView.removeFromSuperview()
        self.shadowView.addShadow(direction: .top)
    }
    
    // MARK: - Configure Reuse
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ superWidth: CGFloat, _ toolPicker: PKToolPicker?) {
        self.configureProblem(problem)
        self.configureUI(contentImage, superWidth)
        self.toolPicker = toolPicker
        self.configureCanvasView()
    }
    
    func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    func configureUI(_ contentImage: UIImage?, _ superWidth: CGFloat) {
        self.configureImageView(contentImage)
        self.configureHeight(superWidth)
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureImageView(_ contentImage: UIImage?) {
        guard let contentImage = contentImage else { return }
        if contentImage.size.width > 0 && contentImage.size.height > 0 {
            self.contentImage = contentImage
        } else {
            self.contentImage = UIImage(.warning)
        }
        self.imageView.image = self.contentImage
    }
    
    func configureHeight(_ superWidth: CGFloat) {
        guard let contentImage = self.contentImage else { return }
        let height = contentImage.size.height*(superWidth/contentImage.size.width)
        
        imageView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        canvasHeight.constant = height
    }
    
    func configureCheckButtons() {
        guard let problem = self.problem else { return }
        
        // 일단 모든 버튼 표시 구현
        for bt in checkNumbers {
            bt.backgroundColor = UIColor.white
            bt.setTitleColor(UIColor(.darkMainColor), for: .normal)
        }
        // 사용자 체크한 데이터 표시
        if let solved = problem.solved {
            guard let targetIndex = Int(solved) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(.darkMainColor)
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
    
    func createCheckImage(to index: Int) {
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
    
    func configureTimerView() {
        guard let time = self.problem?.time else { return }
        
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func showResultImage(to: Bool) {
        let imageName: String = to ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        
        self.contentView.addSubview(self.resultImageView)
        self.resultImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.resultImageView.widthAnchor.constraint(equalToConstant: 50),
            self.resultImageView.heightAnchor.constraint(equalToConstant: 50),
            self.resultImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            self.resultImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 70)
        ])
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.darkMainColor), for: .normal)
        if self.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.darkMainColor), for: .normal)
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureCanvasView() {
        self.configureCanvasViewData()
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
//        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
//        toolPicker?.setVisible(true, forFirstResponder: canvasView)
        toolPicker?.addObserver(canvasView)
        
        canvasView.delegate = self
    }
    
    func configureCanvasViewData() {
        if let pkData = self.problem?.drawing {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
    }
    
    func updateSolved(problem: Problem_Core, input: String) {
        guard let pName = problem.pName else { return }
        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = input == answer
            problem.setValue(correct, forKey: "correct")
            self.delegate?.updateWrong(btName: pName, to: !correct) // 하단 표시 데이터 업데이트
        }
    }
}

extension MultipleWith5Cell {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.problem?.setValue(self.canvasView.drawing.dataRepresentation(), forKey: "drawing")
    }
}
