//
//  FormZero.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import UIKit
import PencilKit

class FormZero: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    /* VC 내에서만 설정가능한 View 들*/
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.color = UIColor.gray
        loader.startAnimating()
        return loader
    }()
    private lazy var explanationView = ExplanationView()
    /* 자식 VC에서 접근가능한 View */
    private(set) var canvasView = RotationableCanvasView()
    /* 자식 VC에서 설정가능한 View들 */
    let answerView = AnswerView()
    let timerView = ProblemTimerView()
    let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var correctImageView: CorrectImageView = {
        let imageView = CorrectImageView()
        self.imageView.addSubview(imageView)
        return imageView
    }()
    
    private(set) var shouldShowExplanation = false
    private var canvasDrawingLoaded: Bool = false
    
    /* 외부에서 주입 가능한 property */
    var toolPicker: PKToolPicker?
    var image: UIImage?
    
    /* 자식 VC에서 override 해야 하는 Property들 */
    var problem: Problem_Core? { return nil }
    var topViewHeight: CGFloat {
        assertionFailure()
        return 51
    }
    var topViewTrailingConstraint: NSLayoutConstraint? { return nil }
    
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
        self.correctImageView.isHidden = true
        self.timerView.isHidden = true
        self.canvasDrawingLoaded = false
        self.shouldShowExplanation = false
        self.answerView.alpha = 0
        self.checkImageView.removeFromSuperview()
        self.closeExplanation()
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
        NotificationCenter.default.post(name: .previousPage, object: nil)
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
    private func adjustLayouts(frameUpdate: Bool, showExplanation: Bool? = nil) {
        if let showExplanation = showExplanation {
            self.shouldShowExplanation = showExplanation
        }
        // canvasView 크기 및 ratio 조절 및 필요시 frame update
        self.updateCanvasView(frameUpdate: frameUpdate)
        // explanation 크기 및 ratio 조절
        if self.shouldShowExplanation, frameUpdate {
            self.explanationView.updateFrame(contentSize: self.view.frame.size, topHeight: self.topViewHeight)
        }
        // explanation 여부에 따른 topViewTrailing 조절
        self.updateTopViewTrailing()
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        // 채점 이미지 크기 설정
        self.correctImageView.adjustLayoutForZero(imageViewWidth: self.imageView.frame.width)
    }
    
    private func updateCanvasView(frameUpdate: Bool) {
        let contentSize = self.view.frame.size
        guard let imageSize = self.image?.size else {
            assertionFailure("image 가 존재하지 않습니다.")
            return
        }
        
        if self.shouldShowExplanation && frameUpdate {
            self.canvasView.updateDrawingRatioAndFrameWithExp(contentSize: contentSize, topHeight: self.topViewHeight, imageSize: imageSize)
        } else {
            if frameUpdate {
                self.canvasView.updateDrawingRatio(imageSize: imageSize)
            } else {
                self.canvasView.updateDrawingRatioAndFrame(contentSize: contentSize, topHeight: self.topViewHeight, imageSize: imageSize)
            }
        }
    }
    
    private func updateTopViewTrailing() {
        if self.shouldShowExplanation && UIWindow.isLandscape {
            self.topViewTrailingConstraint?.constant = self.view.frame.width/2
        } else {
            self.topViewTrailingConstraint?.constant = 0
        }
    }
    
    private func configureCanvasViewDataAndDelegate() {
        guard self.canvasDrawingLoaded == false else { return }
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer { self.canvasView.delegate = self }
        
        let savedData = self.problem?.drawing
        let lastWidth = self.problem?.drawingWidth
        // 필기데이터 ratio 조절 후 표시
        self.canvasView.loadDrawing(to: savedData, lastWidth: lastWidth)
        self.canvasDrawingLoaded = true
    }
}

// MARK: Child Accessible
extension FormZero {
    func showResultImage(to: Bool) {
        self.correctImageView.show(isCorrect: to)
    }
    
    func showExplanation(to image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        self.explanationView.configureImage(to: image)
        self.adjustLayouts(frameUpdate: true, showExplanation: true)
        
        UIView.animate(withDuration: 0.15) {
            self.explanationView.alpha = 1
        }
    }
}

extension FormZero: ExplanationRemover {
    func closeExplanation() {
        self.adjustLayouts(frameUpdate: true, showExplanation: false)
        UIView.animate(withDuration: 0.15) {
            self.explanationView.alpha = 0
        } completion: { _ in
            self.explanationView.removeFromSuperview()
        }
    }
}

extension FormZero: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayouts(frameUpdate: false)
    }
}
