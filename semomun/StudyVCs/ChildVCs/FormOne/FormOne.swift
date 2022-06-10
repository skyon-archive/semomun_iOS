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
    var canvasViewDrawing: Data {
        return self.canvasView.drawing.dataRepresentation()
    }
    var canvasViewContentWidth: CGFloat {
        return self.canvasView.contentSize.width
    }
    let toolPicker = PKToolPicker()
    
    /// Cell 에서 받은 explanation 의 pid 저장
    private var explanationId: Int?
    private var canvasDrawingLoaded = false
    
    private let collectionView = SubproblemCollectionView()
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
        self.configureSubViews()
        self.configureDelegate()
        self.addPageSwipeGesture()
        self.view.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideUpdatingViews()
        self.updateToolPicker()
        self.updateImage()
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.adjustLayouts(frameUpdate: true)
        self.updateCanvasViewDataAndDelegate()
        self.showUpdatingViews()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.canvasView.setDefaults()
        self.collectionView.setDefaults()
        self.setDefaults()
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
        self.toolPicker.setVisible(false, forFirstResponder: self.canvasView)
        self.toolPicker.removeObserver(self.canvasView)
    }
    
    /* 자식 VC에서 override 해야 하는 Property들 */
    var pagePencilData: Data? {
        assertionFailure()
        return nil
    }
    var pagePencilDataWidth: Double? {
        assertionFailure()
        return nil
    }
    
    /* 자식에서 호출이 필요한 메소드 */
    func configureCellRegister(nibName: String, reuseIdentifier: String) {
        let cellNib = UINib(nibName: nibName, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: Override 필요
extension FormOne: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assertionFailure()
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        assertionFailure()
        return .init()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        assertionFailure()
        return .zero
    }
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        assertionFailure()
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
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
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
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer {
            self.canvasView.delegate = self
            self.canvasDrawingLoaded = true
        }
        // 필기데이터 ratio 조절 후 표시
        guard let drawing = self.pagePencilData, let width = self.pagePencilDataWidth else { return }
        self.canvasView.loadDrawing(to: drawing, lastWidth: width)
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
    
    private func hideUpdatingViews() {
        self.collectionView.isHidden = true
        self.canvasView.isHidden = true
    }
    
    private func showUpdatingViews() {
        self.collectionView.isHidden = false
        self.canvasView.isHidden = false
    }
    
    private func setDefaults() {
        self.canvasDrawingLoaded = false
        self.explanationId = nil
        self.closeExplanation()
    }
}

// MARK: LAYOUT
extension FormOne {
    private func adjustLayouts(frameUpdate: Bool) {
        self.updateCanvasView(frameUpdate: frameUpdate)
        if frameUpdate {
            self.collectionView.updateFrame(contentRect: self.view.frame)
            // explanation 크기 및 ratio 조절
            if self.explanationId != nil {
                self.explanationView.updateFrame(contentSize: self.view.frame.size, topHeight: 0)
            }
        }
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
    }
    
    /// canvasView 크기 및 ratio 조절 및 필요시 frame update
    private func updateCanvasView(frameUpdate: Bool) {
        guard let imageSize = self.mainImage?.size else {
            assertionFailure("image 가 존재하지 않습니다.")
            return
        }
        let contentSize = self.view.frame.size
        if frameUpdate {
            self.canvasView.updateDrawingRatioAndFrame(formOneContentSize: contentSize, imageSize: imageSize)
        } else {
            self.canvasView.updateDrawingRatio(imageSize: imageSize)
        }
    }
}

// MARK: Protocol Conformanace
extension FormOne: ExplanationRemovable {
    func selectExplanation(image: UIImage?, pid: Int) {
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
