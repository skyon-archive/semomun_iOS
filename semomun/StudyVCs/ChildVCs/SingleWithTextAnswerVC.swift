//
//  SingleWithTextVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class SingleWithTextAnswerVC: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "SingleWithTextAnswerVC" // form == 0 && type == 1
    static let storyboardName = "Study"

    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet weak var solveInput: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    private var width: CGFloat!
    private var height: CGFloat!
    var image: UIImage?
    var viewModel: SingleWithTextAnswerVM?
    
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
    private lazy var explanationView: ExplanationView = {
        let explanationView = ExplanationView()
        explanationView.alpha = 0
        return explanationView
    }()
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    private lazy var timerView = ProblemTimerView()
    private lazy var answerResultView = ProblemTextResultView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("객관식 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
        self.scrollView.zoomScale = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("객관식 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.showResultImage()
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("객관식 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
        self.resultImageView.removeFromSuperview()
        self.imageView.image = nil
        self.solveInput.isHidden = false
        self.answerBT.isHidden = false
        self.answerResultView.removeFromSuperview()
        self.timerView.removeFromSuperview()
        self.explanationView.removeFromSuperview()
        self.answerView.removeFromSuperview()
        self.scrollViewBottomConstraint.constant = 0
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
        self.viewModel?.updateSolved(withSelectedAnswer: "\(input)")
    }

    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage else { return }
        let explanationImage = UIImage(data: imageData)
        self.explanationBT.isSelected.toggle()
        
        if self.explanationBT.isSelected {
            self.showExplanation(to: explanationImage)
        } else {
            self.closeExplanation()
        }
    }

    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.problem?.answer else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer.circledAnswer)
        self.view.addSubview(self.answerView)
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
}


extension SingleWithTextAnswerVC {
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
    
    private func configureScrollView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.delegate = self
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
    }
    
    func configureCheckInput() {
        if let solved = self.viewModel?.problem?.solved {
            solveInput.text = solved
        } else {
            solveInput.text = ""
        }
        
        if let answer = self.viewModel?.problem?.answer,
           self.viewModel?.problem?.terminated == true {
            self.answerBT.isHidden = true
            self.configureTimerView()
            self.configureResultView(answer: answer)
        }
    }
    
    func configureTimerView() {
        guard let time = self.viewModel?.timeSpentOnPage else { return }
        
        self.view.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func configureResultView(answer: String) {
        self.solveInput.isHidden = true
        self.view.addSubview(self.answerResultView)
        self.answerResultView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerResultView.heightAnchor.constraint(equalToConstant: 32),
            self.answerResultView.centerYAnchor.constraint(equalTo: self.solveInput.centerYAnchor),
            self.answerResultView.trailingAnchor.constraint(equalTo: self.solveInput.trailingAnchor)
        ])
        
        if let solved = self.viewModel?.problem?.solved {
            self.answerResultView.configureSolvedAnswer(to: solved)
        } else {
            self.answerResultView.configureSolvedAnswer(to: "미기입")
        }
        self.answerResultView.configureAnswer(to: answer)
    }
    
    func showResultImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated && problem.answer != nil {
            let imageName: String = problem.correct ? "correct" : "wrong"
            self.resultImageView.image = UIImage(named: imageName)
            
            self.imageView.addSubview(self.resultImageView)
            self.resultImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let autoLeading: CGFloat = 65*self.width/CGFloat(834)
            let autoTop: CGFloat = 0*self.width/CGFloat(834)
            let autoSize: CGFloat = 150*self.width/CGFloat(834)
            NSLayoutConstraint.activate([
                self.resultImageView.widthAnchor.constraint(equalToConstant: autoSize),
                self.resultImageView.heightAnchor.constraint(equalToConstant: autoSize),
                self.resultImageView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: autoLeading),
                self.resultImageView.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: autoTop)
            ])
        }
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
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
            let worningImage = UIImage(.warning)
            imageView.image = worningImage
            height = worningImage.size.height*(width/worningImage.size.width)
        }
        
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
    }
    
    private func showExplanation(to image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        self.explanationView.translatesAutoresizingMaskIntoConstraints = false
        let height = self.view.frame.height/2
        
        NSLayoutConstraint.activate([
            self.explanationView.heightAnchor.constraint(equalToConstant: height),
            self.explanationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.explanationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.explanationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.explanationView.configureImage(to: image)
        self.setShadow(with: self.explanationView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.scrollViewBottomConstraint.constant = height
            self?.explanationView.alpha = 1
        }
    }
}

extension SingleWithTextAnswerVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

extension SingleWithTextAnswerVC: ExplanationRemover {
    func closeExplanation() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
            self?.scrollViewBottomConstraint.constant = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension SingleWithTextAnswerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
