//
//  SingleWithNoAnswer.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/01/15.
//

import Foundation
import UIKit
import PencilKit

class SingleWithNoAnswer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "SingleWithNoAnswer"
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var explanation: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var innerView: UIView!
    
    private var width: CGFloat!
    private var height: CGFloat!
    var image: UIImage!
    var viewModel: SingleWithNoAnswerViewModel?
    
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
    lazy var checkImageView: UIImageView = {
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
    private lazy var timerView = ProblemTimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("답없는 단일형 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("답없는 단일형 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.showResultImage()
        self.viewModel?.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("답없는 단일형 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.cancelObserver()
        self.resultImageView.removeFromSuperview()
        self.imageView.image = nil
        self.checkImageView.removeFromSuperview()
        self.timerView.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("답없는 단일형 : disappear")
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.removeObserver(canvasView)
        print("답없는 단일형 deinit")
    }
    
    @IBAction func toggleStar(_ sender: Any) {
        guard let problem = self.viewModel?.problem,
              let pName = problem.pName else { return }
        
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.viewModel?.updateStar(btName: pName, to: status)
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

extension SingleWithNoAnswer {
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
        self.configureInnerViewRadius()
        self.configureStar()
        self.configureExplanation()
    }
    
    private func configureInnerViewRadius() {
        self.innerView.layer.cornerRadius = 25
    }
    
    func configureTimerView() {
        guard let time = self.viewModel?.time else { return }
        
        self.view.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
//        NSLayoutConstraint.activate([
//            self.timerView.centerYAnchor.constraint(equalTo: self.checkNumbers[3].centerYAnchor),
//            self.timerView.leadingAnchor.constraint(equalTo: self.checkNumbers[3].trailingAnchor, constant: 25)
//        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func showResultImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated && problem.answer != nil {
            let imageName: String = problem.correct ? "correct" : "wrong"
            self.resultImageView.image = UIImage(named: imageName)
            
            self.imageView.addSubview(self.resultImageView)
            self.resultImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let autoLeading: CGFloat = 90*self.width/CGFloat(834)
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
        self.star.isSelected = self.viewModel?.problem?.star ?? false
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
        self.canvasView.isOpaque = false
        self.canvasView.backgroundColor = .clear
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
        
        self.canvasView.subviews[0].addSubview(imageView)
        self.canvasView.subviews[0].sendSubviewToBack(imageView)
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
        
        self.canvasView.delegate = self
    }
    
    func configureCanvasViewData() {
        if let pkData = self.viewModel?.problem?.drawing {
            do {
                try self.canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            self.canvasView.drawing = PKDrawing()
        }
    }
    
    func configureImageView() {
        self.width = canvasView.frame.width
        guard let mainImage = self.image else { return }
        self.height = mainImage.size.height*(width/mainImage.size.width)
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let worningImage = UIImage(named: SemomunImage.warning)!
            self.imageView.image = worningImage
            self.height = worningImage.size.height*(width/worningImage.size.width)
        }
        
        self.imageView.clipsToBounds = true
        self.imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.imageHeight.constant = height
        self.canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.canvasHeight.constant = height
    }
}

extension SingleWithNoAnswer {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

