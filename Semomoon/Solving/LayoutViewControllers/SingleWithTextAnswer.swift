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
    @IBOutlet var star: UIButton!
    
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
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("객관식 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureProblem()
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("객관식 didAppear")
        self.configureImageView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("객관식 : disappear")
    }
    
    // 주관식 입력 부분
    @IBAction func solveInputChanged(_ sender: UITextField) {
        guard let input = sender.text,
              let problem = self.problem else { return }
        problem.solved = input
        saveCoreData()
    }
    

    @IBAction func toggleStar(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }

    @IBAction func showAnswer(_ sender: Any) {

    }

    @IBAction func showExplanation(_ sender: Any) {

    }

    @IBAction func nextProblem(_ sender: Any) {
        self.delegate?.nextPage()
    }
}


extension SingleWithTextAnswer {
    func configureProblem() {
        self.problem = self.pageData?.problems[0] ?? nil
    }
    
    func configureUI() {
        self.configureCheckInput()
        self.configureStar()
    }
    
    func configureCheckInput() {
        solveInput.layer.cornerRadius = 17.5
        solveInput.clipsToBounds = true
        solveInput.layer.borderWidth = 1
        solveInput.layer.borderColor = UIColor(named: "mint")?.cgColor
        if let solved = self.problem?.solved {
            solveInput.text = solved
        } else {
            solveInput.text = ""
        }
    }
    
    func configureStar() {
        self.star.isSelected = self.problem?.star ?? false
    }
    
    func configureCanvasView() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        canvasView.delegate = self
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
