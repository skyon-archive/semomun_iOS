//
//  FormTwo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class FormTwo: UIViewController {
    /* 자식 VC에서 접근가능한 property들 */
    var mainImage: UIImage?
    var canvasViewDrawing: Data {
        return self.canvasView.drawing.dataRepresentation()
    }
    var canvasViewContentWidth: CGFloat {
        return self.canvasView.contentSize.width
    }
    let toolPicker = PKToolPicker()
    /* VC 내에서만 접근가능한 property들 */
    private var explanationId: Int?
    private var canvasDrawingLoaded = false
    /* VC 내에서만 접근가능한 View들 */
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let imageView = UIImageView()
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
        explanationView.configureDelegate(to: self)
        return explanationView
    }()
    // 추후 자식VC로 이동될 property
    var subImages: [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCollectionView()
        self.configureScrollView()
        self.configureLoader()
        self.configureGesture()
        
        self.configureBasicUI()
        self.collectionView.showsVerticalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureCanvasView()
        self.configureMainImageView() // MARK: width, height 를 제외한 이미지 반영만 있는 로직을 수정
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configureUI()
        self.configureCanvasViewData() // 가로<->세로 모드 대응을 위해 현재 frame 사이즈가 필요하기에 configureUI 이후 실행
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setViewToDefault()
    }
    
    // 아래 프로퍼티/메소드들은 override가 필요
    var pagePencilData: Data? { return nil }
    
    var pagePencilDataWidth: CGFloat { return self.canvasView.frame.size.width }
    
    func updatePagePencilData(data: Data, width: CGFloat) { }
    
    func previousPage() { }
    
    func nextPage() { }
}

// MARK: Public functions
extension FormTwo {
    // 추후 여러 cell 들을 등록하기 위한 아이디어
    func configureCellRegisters(identifiers: [String]) {
        identifiers.forEach { identifier in
            let cellNib = UINib(nibName: identifier, bundle: nil)
            self.collectionView.register(cellNib, forCellWithReuseIdentifier: identifier)
        }
    }
}

// MARK: - FormTwo의 Cell 부분 동작을 위해 override가 필요
extension FormTwo: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension FormTwo: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        let image = subImages?[indexPath.row] ?? UIImage(.warning)
        let height = image.size.height * (width/image.size.width)
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Private 메소드
extension FormTwo {
    /// 각 view들의 상태를 VC가 처음 보여졌을 때의 것으로 초기화
    private func setViewToDefault() {
        self.canvasView.setContentOffset(.zero, animated: false)
        self.canvasView.zoomScale = 1.0
        self.explanationView.removeFromSuperview()
    }
    
    /// View의 frame이 정해진 후 UI를 구성
    private func configureUI() {
        self.layoutSplitView()
        self.adjustLayout()
    }
    
    private func configureBasicUI() {
        // MARK: 디자인 확인 후 수정이 필요할 수 있는 부분
        self.collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        self.view.addSubviews(self.canvasView, self.collectionView)
        //        self.view.sendSubviewToBack(self.canvasShadowView)
        
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.imageView.backgroundColor = .white
    }
    
    private func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func configureLoader() {
        self.canvasView.isHidden = true
        self.collectionView.isHidden = true
        
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loader.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loader.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    private func stopLoader() {
        self.canvasView.isHidden = false
        self.collectionView.isHidden = false
        
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
    }
    
    private func configureCanvasView() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }
    
    private func configureCanvasViewData() {
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer { self.canvasView.delegate = self }
        
        guard let pkData = self.pagePencilData,
              self.pagePencilDataWidth > 0 else {
            self.canvasView.drawing = PKDrawing()
            return
        }
        
        guard let drawing = try? PKDrawing(data: pkData) else {
            print("Error loading drawing object")
            self.canvasView.drawing = PKDrawing()
            return
        }
        
        let scale = self.canvasView.frame.width / self.pagePencilDataWidth
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let drawingConverted = drawing.transformed(using: transform)
        self.canvasView.drawing = drawingConverted
    }
    
    private func configureMainImageView() {
        guard let mainImage = self.mainImage,
              mainImage.size.width > 0, mainImage.size.height > 0 else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
            return
        }
        self.imageView.image = mainImage
    }
    
    /// action 전/후 레이아웃 변경을 저장해주는 편의 함수
    private func adjustLayout(_ action: (() -> ())? = nil) {
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        action?()
        self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
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
    }
}

// MARK: - 레이아웃 관련
extension FormTwo {
    // 화면이 회전할 때 실행
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 회전 이전
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        
        coordinator.animate { _ in
            // 회전 도중
            UIView.performWithoutAnimation {
                self.layoutSplitView()
                self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
                
                if self.explanationId != nil {
                    // 답지 크기 설정
                    self.explanationView.frame.size = self.canvasView.frame.size
                }
            }
        }
    }
    
    private func layoutSplitView() {
        let viewSize = self.view.frame.size
        
        if UIWindow.isLandscape {
            let marginBetweenView: CGFloat = 26
            let canvasViewSize = CGSize((viewSize.width - marginBetweenView)/2, viewSize.height)
            let collectionViewSize = CGSize(canvasViewSize.width - 10, canvasViewSize.height)
            self.canvasView.frame = .init(origin: .init(0, 0), size: canvasViewSize)
            self.collectionView.frame = .init(origin: .init(canvasViewSize.width + marginBetweenView, 0), size: collectionViewSize)
        } else {
            let marginBetweenView: CGFloat = 13
            let canvasViewSize = CGSize(viewSize.width, (viewSize.height - marginBetweenView)/2)
            let collectionViewSize = CGSize(canvasViewSize.width - 10, canvasViewSize.height)
            self.canvasView.frame = .init(origin: .init(0, 0), size: canvasViewSize)
            self.collectionView.frame = .init(origin: .init(0, canvasViewSize.height + marginBetweenView), size: collectionViewSize)
        }
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension FormTwo: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}

// MARK: - 제스쳐
extension FormTwo {
    private func configureGesture() {
        self.canvasView.addDoubleTabGesture()
        self.addPageSwipeGesture()
    }
}

extension FormTwo: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let width = self.canvasView.frame.width
        let data = self.canvasView.drawing.dataRepresentation()
        self.updatePagePencilData(data: data, width: width)
    }
}

extension FormTwo: ExplanationRemovable {
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 0
        } completion: { _ in
            self.explanationView.removeFromSuperview()
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
                self.explanationView.configureImage(to: image) // 이미지 바꿔치기
            }
        } else {
            // 새로 생성
            self.explanationId = pid
            self.view.addSubview(self.explanationView)
            self.explanationView.frame = self.canvasView.frame
            
            self.explanationView.configureImage(to: image)
            self.explanationView.addShadow()
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.explanationView.alpha = 1
            }
        }
    }
}
