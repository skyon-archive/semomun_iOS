//
//  SingleWithNoAnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import Foundation
import UIKit
import PencilKit

class SingleWithNoAnswerVC: UIViewController, PKToolPickerObserver {
    static let identifier = "SingleWithNoAnswerVC" // form == 0 && type == 0
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    private var width: CGFloat!
    private var height: CGFloat!
    var image: UIImage!
    var viewModel: SingleWithNoAnswerVM?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
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
    private lazy var timerView = ProblemTimerView()
    
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
        print("답없는 단일형 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
        self.scrollView.zoomScale = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("답없는 단일형 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.viewModel?.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("답없는 단일형 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.cancelObserver()
        self.imageView.image = nil
        self.timerView.removeFromSuperview()
        self.explanationView.removeFromSuperview()
        self.scrollViewBottomConstraint.constant = 0
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
    
    @IBAction func toggleBookmark(_ sender: Any) {
        guard let problem = self.viewModel?.problem,
              let pName = problem.pName else { return }
        
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(btName: pName, to: status)
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
}

extension SingleWithNoAnswerVC {
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
        self.configureStar()
        self.configureExplanation()
        self.configureTimerView()
    }
    
    func configureTimerView() {
        guard let problem = self.viewModel?.problem,
              let time = self.viewModel?.time else { return }
        
        if problem.terminated {
            self.view.addSubview(self.timerView)
            self.timerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
                self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
            ])
            
            self.timerView.configureTime(to: time)
        }
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.darkMainColor), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
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
            let worningImage = UIImage(.warning)
            self.imageView.image = worningImage
            self.height = worningImage.size.height*(width/worningImage.size.width)
        }
        
        self.imageView.clipsToBounds = true
        self.imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.imageHeight.constant = height
        self.canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.canvasHeight.constant = height
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

extension SingleWithNoAnswerVC: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

extension SingleWithNoAnswerVC: ExplanationRemover {
    func closeExplanation() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
            self?.scrollViewBottomConstraint.constant = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension SingleWithNoAnswerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
