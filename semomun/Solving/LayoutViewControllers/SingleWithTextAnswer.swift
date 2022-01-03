//
//  SingleWithTextAnswer.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class SingleWithTextAnswer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "SingleWithTextAnswer" // form == 0 && type == 1

    @IBOutlet weak var solveFrameView: UIView!
    @IBOutlet weak var solveInput: UITextField!
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
    lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    private lazy var answerResultView: ProblemTextResultView = {
        let resultView = ProblemTextResultView()
        resultView.layer.borderWidth = 1
        resultView.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
        resultView.layer.cornerRadius = 12
        resultView.clipsToBounds = true
        return resultView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("객관식 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("객관식 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.showResultImage()
        self.viewModel?.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("객관식 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.cancelObserver()
        self.resultImageView.removeFromSuperview()
        self.imageView.image = nil
        self.solveInput.isHidden = false
        self.answer.isHidden = false
        self.answerResultView.removeFromSuperview()
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
        guard let input = sender.text else { return }
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
    func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    func configureSwipeGesture() {
        let rightSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightDragged))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(rightSwipeGesture)
        
        let leftSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftDragged))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(leftSwipeGesture)
    }
    
    @objc func rightDragged() {
        self.viewModel?.delegate?.beforePage()
    }
    
    @objc func leftDragged() {
        self.viewModel?.delegate?.nextPage()
    }
    
    func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
    
    func configureUI() {
        self.configureCheckInput()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
        self.configureResultView()
    }
    
    func configureCheckInput() {
        solveInput.layer.cornerRadius = 17.5
        solveInput.clipsToBounds = true
        solveInput.layer.borderWidth = 1
        solveInput.layer.borderColor = UIColor(named: SemomunColor.mainColor)?.cgColor
        
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
            self.answer.isUserInteractionEnabled = true
            self.answer.setTitleColor(UIColor(named: SemomunColor.mainColor), for: .normal)
        }
    }
    
    func configureResultView() {
        guard let problem = self.viewModel?.problem,
              let time = self.viewModel?.time else { return }
        
        if let answer = problem.answer, problem.terminated == true {
            self.solveInput.isHidden = true
            self.answer.isHidden = true
            self.view.addSubview(self.answerResultView)
            self.answerResultView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.answerResultView.heightAnchor.constraint(equalToConstant: 40),
                self.answerResultView.centerYAnchor.constraint(equalTo: self.solveFrameView.centerYAnchor),
                self.answerResultView.leadingAnchor.constraint(equalTo: self.solveFrameView.leadingAnchor)
            ])
            
            if let solved = problem.solved {
                self.answerResultView.configureSolvedAnswer(to: solved)
            } else {
                self.answerResultView.configureSolvedAnswer(to: "미기입")
            }
            self.answerResultView.configureAnswer(to: answer)
            self.answerResultView.configureTime(to: time)
        }
    }
    
    func showResultImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated && problem.answer != nil {
            let imageName: String = problem.correct ? "correct" : "wrong"
            self.resultImageView.image = UIImage(named: imageName)
            
            self.imageView.addSubview(self.resultImageView)
            self.resultImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let autoLeading: CGFloat = 65*self.width/CGFloat(834)
            let autoTop: CGFloat = -25*self.width/CGFloat(834)
            let autoSize: CGFloat = 150*self.width/CGFloat(834)
            NSLayoutConstraint.activate([
                self.resultImageView.widthAnchor.constraint(equalToConstant: autoSize),
                self.resultImageView.heightAnchor.constraint(equalToConstant: autoSize),
                self.resultImageView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: autoLeading),
                self.resultImageView.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: autoTop)
            ])
        }
    }
    
    func configureExplanation() {
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanation.isUserInteractionEnabled = false
            self.explanation.setTitleColor(UIColor.gray, for: .normal)
        } else {
            self.explanation.isUserInteractionEnabled = true
            self.explanation.setTitleColor(UIColor(named: SemomunColor.mainColor), for: .normal)
        }
    }
    
    func configureCanvasView() {
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
        guard let mainImage = self.image else { return }
        height = mainImage.size.height*(width/mainImage.size.width)
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            imageView.image = mainImage
        } else {
            let worningImage = UIImage(named: "warningWithNoImage")!
            imageView.image = worningImage
            height = worningImage.size.height*(width/worningImage.size.width)
        }
        
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
