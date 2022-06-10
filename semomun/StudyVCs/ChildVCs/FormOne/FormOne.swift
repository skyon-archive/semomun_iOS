//
//  FormOne.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/06/10.
//

import UIKit
import PencilKit

class FormOne: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    var mainImage: UIImage?
    var explanationShown: Bool {
        self.explanationId != nil
    }
    var canvasViewDrawing: Data {
        return self.canvasView.drawing.dataRepresentation()
    }
    var canvasViewContentWidth: CGFloat {
        return self.canvasView.contentSize.width
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    private let canvasView: RotationableCanvasView = {
        let view = RotationableCanvasView()
        view.addDoubleTabGesture()
        return view
    }()
    private(set) var collectionView = SubproblemCollectionView()
    private(set) var toolPicker = PKToolPicker()
    
    /// Cell 에서 받은 explanation 의 pid 저장
    private var explanationId: Int?
    private var canvasDrawingLoaded = false
    
    private let loader: UIActivityIndicatorView = {
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
        self.view.backgroundColor = UIColor(.lightGrayBackgroundColor)
        self.configureSubViews()
        self.configureSwipeGesture()
        self.configureDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateToolPicker()
        self.updateCanvasViewDataAndDelegate()
        self.updateImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adjustLayouts(frameUpdate: true)
        self.collectionView.reloadData()
        self.updateCanvasViewDataAndDelegate()
        self.canvasView.isHidden = false
        self.collectionView.isHidden = false
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canvasView.setDefaults()
        self.canvasDrawingLoaded = false
        self.explanationId = nil
        self.canvasView.isHidden = true
        self.collectionView.isHidden = true
        self.closeExplanation()
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            UIView.performWithoutAnimation {
                self.adjustLayouts(frameUpdate: true)
                self.updateCanvasViewDataAndDelegate()
            }
        }
    }
    
    deinit {
        self.toolPicker.setVisible(false, forFirstResponder: self.canvasView)
        self.toolPicker.removeObserver(self.canvasView)
    }
    
    /* 자식 VC에서 override 해야 하는 Property들 */
    var problem: Problem_Core? { return nil }
}

// MARK: Override 필요
extension FormOne: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return .init()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
}

// MARK: CONFIGURES
extension FormOne {
    private func configureDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.canvasView.delegate = self
    }
    
    private func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loader.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loader.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        self.loader.startAnimating()
    }
    
    private func configureSubViews() {
        self.view.addSubviews(self.canvasView, self.collectionView)
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
        self.canvasView.isHidden = false
        self.collectionView.isHidden = false
    }
}

// MARK: UPDATES
extension FormOne {
    private func updateToolPicker() {
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
    }
    
    private func updateCanvasViewDataAndDelegate() {
        guard self.canvasDrawingLoaded == false else { return }
        guard let problem = self.problem else { return }
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer {
            self.canvasView.delegate = self
            self.canvasDrawingLoaded = true
        }
        // 필기데이터 ratio 조절 후 표시
        self.canvasView.loadDrawing(to: problem.drawing, lastWidth: problem.drawingWidth)
    }
    
    private func updateImage() {
        guard let mainImage = self.mainImage,
              mainImage.size.width > 0, mainImage.size.height > 0 else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
            return
        }
        self.imageView.image = mainImage
    }
}

// MARK: LAYOUT
extension FormOne {
    private func adjustLayouts(frameUpdate: Bool, showExplanation: Bool? = nil) {
        // canvasView 크기 및 ratio 조절 및 필요시 frame update
        self.updateCanvasView(frameUpdate: frameUpdate)
        // explanation 크기 및 ratio 조절
        if self.explanationShown, frameUpdate {
            self.explanationView.updateFrame(contentSize: self.view.frame.size, topHeight: 0)
        }
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        
        if frameUpdate {
            self.collectionView.updateFrame(contentRect: self.view.frame)
        }
    }
    
    private func updateCanvasView(frameUpdate: Bool) {
        let contentSize = self.view.frame.size
        guard let imageSize = self.mainImage?.size else {
            assertionFailure("image 가 존재하지 않습니다.")
            return
        }
        
        if frameUpdate {
            self.canvasView.updateDrawingRatioAndFrame(formOneContentSize: contentSize, imageSize: imageSize)
        } else {
            self.canvasView.updateDrawingRatio(imageSize: imageSize)
        }
    }
}

extension FormOne: ExplanationRemover {
    func showExplanation(image: UIImage?, pid: Int) {
        if let explanationId = self.explanationId {
            if explanationId == pid {
                self.explanationId = nil
                self.closeExplanation()
            } else {
                self.explanationId = pid
                self.explanationView.configureImage(to: image)
            }
        } else {
            self.explanationId = pid
            self.explanationView.configureDelegate(to: self)
            self.view.addSubview(self.explanationView)
            self.explanationView.configureImage(to: image)
            self.explanationView.frame = self.canvasView.frame
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.explanationView.alpha = 1
            }
        }
    }
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension FormOne: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayouts(frameUpdate: false)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
