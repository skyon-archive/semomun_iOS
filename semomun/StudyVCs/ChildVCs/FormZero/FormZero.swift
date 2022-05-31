//
//  FormZero.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import UIKit
import PencilKit
import Alamofire

class FormZero: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    var canvasView = RotationableCanvasView()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.gray
        loader.startAnimating()
        return loader
    }()
    lazy var explanationView: ExplanationView = {
        let explanationView = ExplanationView()
        self.view.addSubview(self.explanationView)
        return explanationView
    }()
    lazy var resultImageView: CorrectImageView = {
        let imageView = CorrectImageView()
        self.imageView.addSubview(imageView)
        return imageView
    }()
    let timerView: ProblemTimerView = {
        let timerView = ProblemTimerView()
        timerView.isHidden = true
        timerView.translatesAutoresizingMaskIntoConstraints = false
        return timerView
    }()
    let answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private(set) var shouldShowExplanation = false
    private var isCanvasDrawingLoaded: Bool = false
    
    /* 외부에서 주입 가능한 property */
    var toolPicker: PKToolPicker?
    var image: UIImage?
    
    /* 자식 VC에서 override 해야 하는 Property들 */
    var problem: Problem_Core? { return nil }
    var internalTopViewHeight: CGFloat {
        assertionFailure()
        return 51
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLoader()
        self.configureSubViews()
        self.configureSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImageView()
        self.updateToolPicker()
        self.updateTimerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adjustLayouts(frameUpdate: true)
        self.configureCanvasViewDataAndDelegate()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canvasView.setDefaults()
        self.explanationView.setDefaults()
        self.resultImageView.isHidden = true
        self.timerView.isHidden = true
        self.isCanvasDrawingLoaded = false
        self.shouldShowExplanation = false
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            UIView.performWithoutAnimation {
                self.adjustLayouts(frameUpdate: true)
                self.configureCanvasViewDataAndDelegate()
            }
        }
    }
}

// MARK: Configure
extension FormZero {
    private func configureLoader() {
        self.view.addSubview(self.loader)
        
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    private func configureSubViews() {
        self.view.backgroundColor = UIColor(.lightGrayBackgroundColor)
        self.view.addSubview(self.canvasView)
        
        self.canvasView.addDoubleTabGesture()
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
    }
    
    private func configureSwipeGesture() {
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
        NotificationCenter.default.post(name: .beforePage, object: nil)
    }
    
    @objc func leftDragged() {
        NotificationCenter.default.post(name: .nextPage, object: nil)
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

// MARK: Update
extension FormZero {
    private func updateImageView() {
        guard let contentImage = self.image,
              contentImage.size.width > 0, contentImage.size.height > 0 else {
            self.imageView.image = UIImage(.warning)
            return
        }
        self.imageView.image = contentImage
    }
    
    private func updateToolPicker() {
        self.toolPicker?.setVisible(true, forFirstResponder: self.canvasView)
        self.toolPicker?.addObserver(self.canvasView)
    }
    
    private func updateTimerView() {
        guard let problem = self.problem else { return }
        
        if problem.terminated {
            self.timerView.configureTime(to: problem.time)
            self.timerView.isHidden = false
        } else {
            self.timerView.isHidden = true
        }
    }
}

// MARK: Rotate
extension FormZero {
    private func adjustLayouts(frameUpdate: Bool = false, showExplanation: Bool? = nil) {
        if let showExplanation = showExplanation {
            self.shouldShowExplanation = showExplanation
        }
        // canvasView 크기 및 ratio 조절
        self.updateCanvasView(frameUpdate: frameUpdate)
        // explanation 크기 조절
        self.updateExplanationView(frameUpdate: frameUpdate)
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        // 채점 이미지 크기 설정
        self.resultImageView.adjustLayoutForZero(imageViewWidth: self.imageView.frame.width)
    }
    
    private func updateCanvasView(frameUpdate: Bool) {
        let contentSize = self.view.frame.size
        guard let imageSize = self.image?.size else {
            assertionFailure("image 가 존재하지 않습니다.")
            return
        }
        
        if self.shouldShowExplanation && frameUpdate {
            self.canvasView.updateDrawingRatioAndFrameWithExp(contentSize: contentSize, topHeight: self.internalTopViewHeight, imageSize: imageSize)
        } else {
            self.canvasView.updateDrawingRatioAndFrame(contentSize: contentSize, topHeight: self.internalTopViewHeight, imageSize: imageSize, frameUpdate: frameUpdate)
        }
    }
    
    private func updateExplanationView(frameUpdate: Bool) {
        guard self.shouldShowExplanation, frameUpdate else { return }
        self.explanationView.updateFrame(contentSize: self.view.frame.size, topHeight: self.internalTopViewHeight)
    }
    
    private func configureCanvasViewDataAndDelegate() {
        guard self.isCanvasDrawingLoaded == false else { return }
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer { self.canvasView.delegate = self }
        
        let savedData = self.problem?.drawing
        let lastWidth = self.problem?.drawingWidth
        // 필기데이터 ratio 조절 후 표시
        self.canvasView.loadDrawing(to: savedData, lastWidth: lastWidth)
        self.isCanvasDrawingLoaded = true
    }
}

// MARK: Child Accessible
extension FormZero {
    func showResultImage(to: Bool) {
        self.resultImageView.show(isCorrect: to)
    }
    
    func showExplanation(to image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.explanationView.configureImage(to: image)
        self.adjustLayouts(frameUpdate: true, showExplanation: true)
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 1
        }
    }
}

extension FormZero: ExplanationRemover {
    func closeExplanation() {
        self.adjustLayouts(frameUpdate: true, showExplanation: false)
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 0
        }
    }
}

extension FormZero: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayouts()
    }
}
