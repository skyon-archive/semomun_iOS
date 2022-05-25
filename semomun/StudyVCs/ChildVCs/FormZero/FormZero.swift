//
//  FormZero.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/22.
//

import UIKit
import PencilKit

/// 상단에 바가 있는 form = 0
class FormZero: UIViewController, PKToolPickerObserver {
    private var canvasView = PKCanvasView()
    private let imageView = UIImageView()
    
    var showExplanation = false
    
    var image: UIImage?
    
    private let toolPicker = PKToolPicker()
    
    lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        self.imageView.addSubview(imageView)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLoader()
        self.configureGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
        self.configureBasicUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureCanvasView()
        self.configureCanvasViewData()
        self.configureImageView()
        self.showResultImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configureUI()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setViewToDefault()
        CoreDataManager.saveCoreData()
    }
    
    /// 상단 바 높이
    var topHeight: CGFloat { return 0 }
    
    /// 채점 결과. nil이면 미채점
    var problemResult: Bool? { return nil }
    
    var _topViewTrailingConstraint: NSLayoutConstraint? { return nil }
    
    var drawing: Data? { return nil }
    
    func previousPage() { }
    func nextPage() { }
    
    func savePencilData(data: Data, width: CGFloat) { }
    
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
        
        self.resultImageView.isHidden = false
    }
    
    /// View의 frame이 정해진 후 UI를 구성
    private func configureUI() {
        self.canvasView.frame = .init(origin: .init(0, self.topHeight), size: self.contentSize)
        self.adjustLayout()
    }
}

extension FormZero {
    /// 단 한 번만 필요한 UI 설정을 수행
    private func configureBasicUI() {
        self.view.addSubview(self.canvasView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        self.imageView.backgroundColor = .white
        self.view.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    private func showResultImage() {
        guard let result = self.problemResult else { return }
        
        let imageName = result ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        self.resultImageView.isHidden = false
    }
    
    private func configureCanvasView() {
        self.canvasView.isOpaque = false
        self.canvasView.backgroundColor = .clear
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
        
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
    }
    
    private func configureCanvasViewData() {
        if let pkData = self.drawing {
            do {
                try self.canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            self.canvasView.drawing = PKDrawing()
        }
        self.canvasView.delegate = self
    }
    
    private func configureImageView() {
        guard let mainImage = self.image else { return }
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
        }
    }
    
    private func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

// MARK: - 레이아웃 관련
extension FormZero {
    /// topView를 제외한 나머지 view의 사이즈
    private var contentSize: CGSize {
        return CGSize(self.view.frame.width, self.view.frame.height - self.topHeight)
    }
    
    func showExplanation(to image: UIImage?) {
        self.showExplanation = true
        
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
    
    // 화면이 회전할 때 실행
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 회전 이전
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        
        coordinator.animate { _ in
            // 회전 도중
            UIView.performWithoutAnimation {
                if self.showExplanation {
                    self.layoutExplanation()
                } else {
                    self.canvasView.frame.size = self.contentSize
                    self._topViewTrailingConstraint?.constant = 0
                }
                self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
            }
        }
    }
    
    /// ExplanationView의 frame을 상황에 맞게 수정
    private func layoutExplanation() {
        let width = self.contentSize.width
        let height = self.contentSize.height
        let topViewHeight = self.topHeight
        
        if UIWindow.isLandscape {
            self.canvasView.frame.size.width = width/2
            self.canvasView.frame.size.height = height
            self._topViewTrailingConstraint?.constant = width/2
            self.explanationView.frame = .init(width/2, 0, width/2, height+topViewHeight)
        } else {
            self.canvasView.frame.size.width = width
            self.canvasView.frame.size.height = height/2
            self._topViewTrailingConstraint?.constant = 0
            self.explanationView.frame = .init(0, height/2+topViewHeight, width, height/2)
        }
    }
    
    /// CanvasView의 크기가 바뀐 후 이에 맞게 필기/이미지 레이아웃을 수정
    private func adjustLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint) {
        guard let image = self.imageView.image else {
            assertionFailure("CanvasView의 크기를 구할 이미지 정보 없음")
            return
        }
        
        let ratio = image.size.height/image.size.width
        self.canvasView.adjustDrawingLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
        
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        
        // 채점 이미지 크기 설정
        let imageViewWidth = self.imageView.frame.width
        
        self.resultImageView.frame = .init(imageViewWidth/10, imageViewWidth/10, imageViewWidth*150/834, imageViewWidth*150/834)
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
    private func configureGesture() {
        self.canvasView.addDoubleTabGesture()
        self.configureSwipeGesture()
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
        self.showExplanation = false
        
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
        self.adjustLayout()
    }
}
