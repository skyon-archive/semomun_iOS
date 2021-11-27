//
//  MultipleWith5Cell.swift
//  Semomoon
//
//  Created by qwer on 2021/11/06.
//

import UIKit
import PencilKit

class MultipleWith5Cell: UICollectionViewCell, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWith5Cell"
    
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var answer: UIButton!
    @IBOutlet weak var explanation: UIButton!
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var solvInputFrame: UIView!
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: CollectionCellDelegate?
    
    var toolPicker: PKToolPicker?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBaseUI()
        print("\(Self.identifier) awakeFromNib")
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
    
    @IBAction func toggleStar(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        self.answer.isSelected.toggle()
        if self.answer.isSelected {
            self.answer.setTitle(answer, for: .normal)
        } else {
            self.answer.setTitle("정답", for: .normal)
        }
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let explanationImage = UIImage(data: imageData) else { return }
        self.delegate?.showExplanation(image: explanationImage)
    }
    
    @IBAction func nextProblem(_ sender: Any) {
        self.delegate?.nextPage()
    }
    
    // MARK: - Configure
    func configureBaseUI() {
        solvInputFrame.layer.cornerRadius = 27
        checkNumbers.forEach { $0.layer.cornerRadius = 15 }
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
        self.configureImage(contentImage)
        self.configureHeight(superWidth)
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureImage(_ contentImage: UIImage?) {
        guard let contentImage = contentImage else { return }
        self.contentImage = contentImage
        self.imageView.image = contentImage
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
            bt.layer.cornerRadius = 17.5
            bt.backgroundColor = UIColor.white
            bt.setTitleColor(UIColor(named: "mint"), for: .normal)
        }
        // 사용자 체크한 데이터 표시
        if let solved = problem.solved {
            guard let targetIndex = Int(solved) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(named: "mint")
            self.checkNumbers[targetIndex-1].setTitleColor(UIColor.white, for: .normal)
        }
        // 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
        if let answer = problem.answer,
           let solved = problem.solved,
           answer != solved,
           problem.terminated == true {
            guard let targetIndex = Int(answer) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(named: "colorRed")
            self.checkNumbers[targetIndex-1].setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func configureStar() {
        self.star.isSelected = self.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answer.setTitle("정답", for: .normal)
        self.answer.isSelected = false
        if self.problem?.answer == nil {
            self.answer.isUserInteractionEnabled = false
            self.answer.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.answer.isUserInteractionEnabled = true
            self.answer.setTitleColor(UIColor(named: "mint"), for: .normal)
        }
    }
    
    func configureExplanation() {
        if self.problem?.explanationImage == nil {
            self.explanation.isUserInteractionEnabled = false
            self.explanation.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanation.isUserInteractionEnabled = true
            self.explanation.setTitleColor(UIColor(named: "mint"), for: .normal)
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
        saveCoreData()
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = input == answer
            problem.setValue(correct, forKey: "correct")
            saveCoreData()
            self.delegate?.updateWrong(btName: pName, to: !correct) // 하단 표시 데이터 업데이트
        }
    }
}

extension MultipleWith5Cell {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.problem?.setValue(self.canvasView.drawing.dataRepresentation(), forKey: "drawing")
        saveCoreData()
    }
}
