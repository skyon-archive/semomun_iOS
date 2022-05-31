//
//  FormZero.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import UIKit
import PencilKit

class FormZero: UIViewController, PKToolPickerObserver {
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
    let explanationView: ExplanationView = {
        let explanationView = ExplanationView()
        explanationView.alpha = 0
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateImageView()
        self.updateToolPicker()
        self.updateTimerView()
        self.showResultImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configureUI()
        self.configureCanvasViewData()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canvasView.delegate = nil
        self.resultImageView.isHidden = true
        self.timerView.isHidden = true
        
        self.setViewToDefault()
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            UIView.performWithoutAnimation {
                self.adjustLayouts(frameUpdate: true)
            }
        }
    }
    
    /// 각 view들의 상태를 VC가 처음 보여졌을 때의 것으로 초기화
    private func setViewToDefault() {
        self.canvasView.setContentOffset(.zero, animated: false)
        self.canvasView.zoomScale = 1.0
        self.canvasView.contentInset = .zero
        self.closeExplanation()

        // 필기 남는 버그 우회, canvasView 객체를 다시 설정
        self.canvasView.removeFromSuperview()
        self.canvasView = PKCanvasView()
        self.view.addSubview(self.canvasView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        self.configureScrollView()
        self.configureGesture()
        
        // 각종 subView들 제거
        self.explanationView.removeFromSuperview()
    }
    
    /// View의 frame이 정해진 후 UI를 구성
    private func configureUI() {
        self.canvasView.frame = .init(origin: .init(0, self.topHeight), size: self.contentSize)
        self.adjustLayout()
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
        
        self.configureSwipeGesture()
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
        guard rotate && self.showExplanation else { return }
        self.explanationView.updateFrame(contentSize: self.view.frame.size, topHeight: self.internalTopViewHeight)
    }
}

extension FormZero {
    /// 단 한 번만 필요한 UI 설정을 수행
    private func showResultImage() {
        guard let result = self.problemResult else {
            self.resultImageView.isHidden = true
            return
        }
        
        let imageName = result ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        self.resultImageView.isHidden = false
    }
    
    private func configureCanvasViewData() {
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer { self.canvasView.delegate = self }
        
        guard let pkData = self.drawing,
              let drawingWidth = self.drawingWidth else {
            self.canvasView.drawing = PKDrawing()
            return
        }
        
        guard let drawing = try? PKDrawing(data: pkData) else {
            print("Error loading drawing object")
            self.canvasView.drawing = PKDrawing()
            return
        }
        
        
        if drawingWidth > 0 {
            let scale = self.canvasView.frame.width / CGFloat(drawingWidth)
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            let drawingConverted = drawing.transformed(using: transform)
            self.canvasView.drawing = drawingConverted
        } else {
            self.canvasView.drawing = drawing
        }
    }
    
    
    
    
    
    
    
    
}

// MARK: - 레이아웃 관련
extension FormZero {
    func showExplanation(to image: UIImage?) {
        self.shouldShowExplanation = true
        
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        self.explanationView.configureImage(to: image)
        self.explanationView.addShadow()
        
        self.adjustLayout {
            self.layoutExplanation()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 1
        }
    }
    
    
    
    
    
    
    
    /// action 전/후 레이아웃 변경을 저장해주는 편의 함수
    private func adjustLayout(_ action: (() -> ())? = nil) {
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        action?()
        self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
    }
}

// MARK: - 제스쳐 설정
extension FormZero {
    
    
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
        self.previousPage()
    }
    
    @objc func leftDragged() {
        self.nextPage()
    }
}

// MARK: - Protocols
extension FormZero: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.savePencilData(data: data, width: self.canvasView.frame.width)
    }
}

extension FormZero: ExplanationRemover {
    func closeExplanation() {
        self.shouldShowExplanation = false
        
        self.explanationView.alpha = 0
        self.explanationView.removeFromSuperview()
        self._topViewTrailingConstraint?.constant = 0
        
        self.adjustLayout {
            self.canvasView.frame.size = self.contentSize
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
