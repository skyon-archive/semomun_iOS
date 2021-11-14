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
    var pageData: PageData?
    var problem: Problem_Core?
    weak var delegate: PageDelegate?
    
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
        self.configureProblem()
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("5다선지 didAppear")
        self.configureImageView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("5다선지 : disappear")
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        guard let problem = self.problem else { return }
        problem.solved = String(num)
        saveCoreData()
        for bt in checkNumbers {
            if(bt.tag == num) {
                bt.backgroundColor = UIColor(named: "mint")
                bt.setTitleColor(UIColor.white, for: .normal)
            } else {
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
        }
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
        guard let imageData = self.problem?.explanationImage else { return }
        guard let explanationVC = self.storyboard?.instantiateViewController(withIdentifier: ExplanationViewController.identifier) as? ExplanationViewController else { return }
        let explanationImage = UIImage(data: imageData)
        explanationVC.explanationImage = explanationImage
        self.present(explanationVC, animated: true, completion: nil)
    }
    
    @IBAction func nextProblem(_ sender: Any) {
        self.delegate?.nextPage()
    }
}


extension SingleWith5Answer {
    func configureProblem() {
        self.problem = self.pageData?.problems[0] ?? nil
    }
    
    func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureCheckButtons() {
        if let solved = self.problem?.solved {
            for bt in checkNumbers {
                bt.layer.cornerRadius = 17.5
                if String(bt.tag) == solved {
                    bt.backgroundColor = UIColor(named: "mint")
                    bt.setTitleColor(UIColor.white, for: .normal)
                } else {
                    bt.backgroundColor = UIColor.white
                    bt.setTitleColor(UIColor(named: "mint"), for: .normal)
                }
            }
        } else {
            for bt in checkNumbers {
                bt.layer.cornerRadius = 17.5
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
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
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
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
        self.problem?.setValue(self.canvasView.drawing.dataRepresentation(), forKey: "drawing")
        saveCoreData()
    }
}
