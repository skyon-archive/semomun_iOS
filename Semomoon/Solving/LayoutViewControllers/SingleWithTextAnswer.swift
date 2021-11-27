//
//  test_1ViewController.swift
//  test_1ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class SingleWithTextAnswer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "SingleWithTextAnswer" // form == 0 && type == 1

    @IBOutlet var solveInput: UITextField!
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
    var viewModel: SingleWithTextAnswerViewModel?
    
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
        print("객관식 willAppear")
        
        self.viewModel?.configureObserver()
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("객관식 didAppear")
        
        self.configureImageView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("객관식 willDisappear")
        
        self.viewModel?.cancelObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("객관식 : disappear")
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.removeObserver(canvasView)
        print("객관식 deinit")
    }
    
    // 주관식 입력 부분
    @IBAction func solveInputChanged(_ sender: UITextField) {
        guard let problem = self.viewModel?.problem,
              let input = sender.text else { return }
        
        if problem.terminated {
            if let solved = problem.solved {
                sender.text = solved
            }
            return
        }
        
        self.viewModel?.updateSolved(input: "\(input)")
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


extension SingleWithTextAnswer {
    func configureUI() {
        self.configureCheckInput()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureCheckInput() {
        solveInput.layer.cornerRadius = 17.5
        solveInput.clipsToBounds = true
        solveInput.layer.borderWidth = 1
        solveInput.layer.borderColor = UIColor(named: "mint")?.cgColor
        
        if let solved = self.viewModel?.problem?.solved {
            solveInput.text = solved
        } else {
            solveInput.text = ""
        }
    }
    
    func configureStar() {
        self.star.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureAnswer() {
        guard let problem = self.viewModel?.problem else { return }
        self.answer.setTitle("정답", for: .normal)
        self.answer.isSelected = false
        if problem.answer == nil {
            self.answer.isUserInteractionEnabled = false
            self.answer.setTitleColor(UIColor.gray, for: .normal)
        } else {
            if problem.terminated,
               problem.correct == false {
                self.answer.isUserInteractionEnabled = true
                self.answer.setTitleColor(UIColor(named: "colorRed"), for: .normal)
                self.answer.setTitle(problem.answer, for: .normal)
            } else {
                self.answer.isUserInteractionEnabled = true
                self.answer.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
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

extension SingleWithTextAnswer {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}
