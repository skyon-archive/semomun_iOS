//
//  FormTwo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class FormTwo: UIViewController {
    /* public */
    var mainImage: UIImage?
    var toolPicker: PKToolPicker? = PKToolPicker()
    let subproblemCollectionView = SubproblemCollectionView()
    // MARK: 자식 클래스에서 접근이 필요한 canvasView의 속성들
    var canvasViewDrawing: Data {
        return self.canvasView.drawing.dataRepresentation()
    }
    var canvasViewContentWidth: CGFloat {
        return self.canvasView.contentSize.width
    }
    /* private */
    private var explanationId: Int?
    private var canvasDrawingLoaded = false
    private var pagePencilData: Data?
    private var pagePencilDataWidth: Double?
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    private let canvasView = RotationableCanvasView()
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    private lazy var explanationView = ExplanationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLoader()
        self.configureSubViews()
        self.configureCollectionView()
        self.configureGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideUpdatingViews()
        self.updateToolPicker()
        self.updateMainImage()
        self.subproblemCollectionView.reloadData()
        self.canvasView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adjustLayouts(frameUpdate: true)
        self.updateCanvasViewDataAndDelegate()
        self.showUpdatingViews()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.canvasView.setDefaults()
        self.subproblemCollectionView.setDefaults()
        self.canvasDrawingLoaded = false
        self.closeExplanation()
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
    
    deinit {
        self.toolPicker?.setVisible(false, forFirstResponder: self.canvasView)
        self.toolPicker?.removeObserver(self.canvasView)
    }
    
    // MARK: 자식 클래스에서 설정 필수
    func configureCellRegisters(identifiers: [String]) {
        identifiers.forEach { identifier in
            let cellNib = UINib(nibName: identifier, bundle: nil)
            self.subproblemCollectionView.register(cellNib, forCellWithReuseIdentifier: identifier)
        }
    }
    // MARK: 자식 클래스에서 설정 필수
    func configurePagePencilData(data: Data?, width: Double?) {
        self.pagePencilData = data
        self.pagePencilDataWidth = width
    }
}

// MARK: Override 필요
extension FormTwo: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PKCanvasViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assertionFailure("override error: numberOfItemsInSection")
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assertionFailure("override error: cellForItemAt")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        assertionFailure("override error: sizeForItemAt")
        return CGSize()
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        assertionFailure("error: canvasViewDrawingDidChange")
    }
}

// MARK: Configure
extension FormTwo {
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
        self.view.addSubviews(self.canvasView, self.subproblemCollectionView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
    }
    
    private func configureCollectionView() {
        self.subproblemCollectionView.delegate = self
        self.subproblemCollectionView.dataSource = self
    }
    
    private func configureGesture() {
        self.canvasView.addDoubleTabGesture()
        self.addPageSwipeGesture()
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

// MARK: Update
extension FormTwo {
    private func hideUpdatingViews() {
        self.subproblemCollectionView.isHidden = true
        self.canvasView.isHidden = true
    }
    
    private func updateToolPicker() {
        self.toolPicker?.setVisible(true, forFirstResponder: self.canvasView)
        self.toolPicker?.addObserver(self.canvasView)
    }
    
    private func updateMainImage() {
        guard let mainImage = self.mainImage,
              mainImage.size.hasValidSize else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
            return
        }
        self.imageView.image = mainImage
    }
    
    private func updateCanvasViewDataAndDelegate() {
        guard self.canvasDrawingLoaded == false else { return }
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer {
            self.canvasView.delegate = self
            self.canvasDrawingLoaded = true
        }
        // 필기데이터 ratio 조절 후 표시
        self.canvasView.loadDrawing(to: self.pagePencilData, lastWidth: self.pagePencilDataWidth)
    }
    
    private func showUpdatingViews() {
        self.subproblemCollectionView.isHidden = false
        self.canvasView.isHidden = false
    }
}

// MARK: Layout
extension FormTwo {
    private func adjustLayouts(frameUpdate: Bool) {
        let shouldShowExplanation = self.explanationId != nil
        let contentSize = self.view.frame.size
        
        self.updateCanvasView(frameUpdate: frameUpdate)
        
        if frameUpdate {
            self.subproblemCollectionView.updateFrame(formTwoContentSize: contentSize)
            if shouldShowExplanation {
                self.explanationView.updateFrame(formTwoContentSize: contentSize)
            }
        }
        
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
    }
    
    private func updateCanvasView(frameUpdate: Bool) {
        guard let imageSize = self.mainImage?.size else {
            assertionFailure("image 가 존재하지 않습니다.")
            return
        }
        
        let contentSize = self.view.frame.size
        if frameUpdate {
            self.canvasView.updateDrawingRatioAndFrame(formTwoContentSize: contentSize, imageSize: imageSize)
        } else {
            self.canvasView.updateDrawingRatio(imageSize: imageSize)
        }
    }
}

extension FormTwo: ExplanationRemovable {
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension FormTwo: ExplanationSelectable {
    func selectExplanation(image: UIImage?, pid: Int) {
        if let explanationId = self.explanationId {
            if explanationId == pid {
                self.closeExplanation()
            } else {
                self.explanationId = pid
                self.explanationView.configureImage(to: image)
            }
        } else {
            self.explanationId = pid
            self.showExplanation(image: image)
        }
    }
    
    private func showExplanation(image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        
        self.adjustLayouts(frameUpdate: true)
        
        self.explanationView.configureImage(to: image)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 1
        }
    }
}

// MARK: Zooming
extension FormTwo: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayouts(frameUpdate: false)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
