//
//  test_1ViewController.swift
//  test_1ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class SingleWith5Answer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "SingleWith5Answer" // form == 0 && type == 5

    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var answer: UIButton!
    @IBOutlet weak var explanation: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var image: UIImage?
    var viewModel: SingleWith5AnswerViewModel?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("5다선지 didAppear")
        
        self.viewModel?.configureObserver()
        self.configureImageView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 willDisappear")
        
        self.viewModel?.cancelObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("5다선지 : disappear")
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.removeObserver(canvasView)
        print("5다선지 deinit")
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated { return }
        
        let input: Int = sender.tag
        self.viewModel?.updateSolved(input: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleStar(_ sender: Any) {
        guard let problem = self.viewModel?.problem,
              let pName = problem.pName else { return }
        
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.viewModel?.updateStar(btName: pName, to: status)
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.problem?.answer else { return }
        
        self.answer.isSelected.toggle()
        if self.answer.isSelected {
            self.answer.setTitle(answer, for: .normal)
        } else {
            self.answer.setTitle("정답", for: .normal)
        }
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage else { return }
        
        guard let explanationVC = self.storyboard?.instantiateViewController(withIdentifier: ExplanationViewController.identifier) as? ExplanationViewController else { return }
        let explanationImage = UIImage(data: imageData)
        explanationVC.explanationImage = explanationImage
        self.present(explanationVC, animated: true, completion: nil)
    }
    
    @IBAction func nextProblem(_ sender: Any) {
        self.viewModel?.delegate?.nextPage()
    }
}


extension SingleWith5Answer {
    func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureCheckButtons() {
        guard let problem = self.viewModel?.problem else { return }
        
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
        self.star.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answer.setTitle("정답", for: .normal)
        self.answer.isSelected = false
        if self.viewModel?.problem?.answer == nil {
            self.answer.isUserInteractionEnabled = false
            self.answer.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.answer.isUserInteractionEnabled = true
            self.answer.setTitleColor(UIColor(named: "mint"), for: .normal)
        }
    }
    
    func configureExplanation() {
        if self.viewModel?.problem?.explanationImage == nil {
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
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        canvasView.delegate = self
    }
    
    func configureCanvasViewData() {
        if let pkData = self.viewModel?.problem?.drawing {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
    }
    
    func configureImageView() {
        width = canvasView.frame.width
        guard let image = self.image else { return }
        height = image.size.height*(width/image.size.width)
        
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
    }
}



extension SingleWith5Answer {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}
