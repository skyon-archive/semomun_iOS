//
//  FormTwo.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

protocol FormTwoDelegate: AnyObject {
    var pagePencilData: Data? { get }
    func updatePagePencilData(_ data: Data)
    
    var xibAwakable: XibAwakable.Type { get }
    
    var cellCount: Int { get }
    func getCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    
    func previousPage()
    func nextPage()
}

class FormTwo: UIViewController {
    let canvasView = PKCanvasView()
    
    private let canvasShadowView = UIView()
    private let imageView = UIImageView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    /// Cell에서 받은 explanation 의 pid
    var explanationId: Int?
    
    var mainImage: UIImage?
    var subImages: [UIImage?]?
    
    weak var delegate: FormTwoDelegate!
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    
    lazy var explanationView: ExplanationView = {
        let explanationView = ExplanationView()
        explanationView.alpha = 0
        explanationView.configureDelegate(to: self)
        return explanationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureDelegate()
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
        self.configureMainImageView()
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
}

// MARK: - Private 메소드
extension FormTwo {
    /// 각 view들의 상태를 VC가 처음 보여졌을 때의 것으로 초기화
    private func setViewToDefault() {
        self.canvasView.setContentOffset(.zero, animated: true)
        self.canvasView.zoomScale = 1.0
        
        self.explanationView.removeFromSuperview()
    }
    
    /// View의 frame이 정해진 후 UI를 구성
    private func configureUI() {
        self.layoutSplitView()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.adjustLayout()
    }
    
    private func configureBasicUI() {
        let cellNib = UINib(nibName: self.delegate.xibAwakable.identifier, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: self.delegate.xibAwakable.identifier)
        
        self.collectionView.contentInset = .init(top: 5, left: 0, bottom: 0, right: 0)
        
        self.view.addSubviews(self.canvasView, self.collectionView, self.canvasShadowView)
        self.view.sendSubviewToBack(self.canvasShadowView)
        
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.imageView.backgroundColor = .white
        
        self.canvasShadowView.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    private func configureDelegate() {
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
        self.canvasView.delegate = self
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
        if let pkData = self.delegate.pagePencilData {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
        self.canvasView.delegate = self
    }
    
    private func configureMainImageView() {
        guard let mainImage = self.mainImage else { return }
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
        }
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
        // 답지 크기 설정
        self.explanationView.frame.size = self.canvasView.frame.size
        
        self.canvasShadowView.frame = self.canvasView.frame
        self.canvasShadowView.addAccessibleShadow()
        self.canvasShadowView.clipAccessibleShadow(at: .exceptTop)
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
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
            }
        }
    }
    
    private func layoutSplitView() {
        let viewSize = self.view.frame.size
        let marginForTopShadow: CGFloat = 10
        
        if UIWindow.isLandscape {
            let marginBetweenView: CGFloat = 26
            let canvasViewSize = CGSize((viewSize.width-marginBetweenView)/2, viewSize.height-marginForTopShadow)
            let collectionViewSize = CGSize((viewSize.width-marginBetweenView)/2, viewSize.height)
            self.canvasView.frame = .init(origin: .init(0, marginForTopShadow), size: canvasViewSize)
            self.collectionView.frame = .init(origin: .init(self.canvasView.frame.maxX+marginBetweenView, 0), size: collectionViewSize)
        } else {
            let marginBetweenView: CGFloat = 13
            let size = CGSize(viewSize.width, (viewSize.height-marginBetweenView)/2)
            self.canvasView.frame = .init(origin: .init(0, marginForTopShadow), size: size)
            self.collectionView.frame = .init(origin: .init(0, viewSize.height/2+marginBetweenView), size: size)
        }
    }
}

extension FormTwo: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}

// MARK: - 제스쳐
extension FormTwo {
    func configureGesture() {
        self.canvasView.addDoubleTabGesture()
        self.configureSwipeGesture()
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
        self.delegate.previousPage()
    }
    
    @objc func leftDragged() {
        self.delegate.nextPage()
    }
}

// MARK: - Configure Cell
extension FormTwo: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate.cellCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.delegate.getCell(collectionView, cellForItemAt: indexPath)
    }
}

extension FormTwo: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        let image = subImages?[indexPath.row] ?? UIImage(.warning)
        let imgHeight = image.size.height * (width/image.size.width)
        let topViewHeight = self.delegate.xibAwakable.topViewHeight
        let height = topViewHeight + imgHeight
        
        return CGSize(width: width, height: height)
    }
}

extension FormTwo: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.delegate.updatePagePencilData(data)
    }
}

extension FormTwo: ExplanationRemover {
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 0
        } completion: { _ in
            self.explanationView.removeFromSuperview()
        }
    }
}
