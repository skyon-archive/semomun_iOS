//
//  MultipleWith5AnswerWideVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/05/17.
//

import UIKit
import PencilKit

final class MultipleWith5AnswerWideVC: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWith5AnswerWideVC"
    static let storyboardName = "Study"
    
    private let canvasView = PKCanvasView()
    private let imageView = UIImageView()
    
    @IBOutlet weak var collectionView: UICollectionView! // 문제들뷰
    
    private var explanationId: Int? // Cell 에서 받은 explanation 의 pid 저장
    
    var mainImage: UIImage?
    var subImages: [UIImage?]?
    var viewModel: MultipleWith5AnswerVM?
    
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
        explanationView.configureDelegate(to: self)
        return explanationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureDelegate()
        self.configureLoader()
        self.configureGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
        
        self.view.addSubview(self.canvasView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 좌우형 : willAppear")
        
        self.canvasView.setContentOffset(.zero, animated: true)
        self.canvasView.zoomScale = 1.0
        
        self.configureCanvasView()
        self.configureCanvasViewData()
        self.configureMainImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 좌우형 : didAppear")
        self.stopLoader()
        
        self.canvasView.frame = .init(0, 0, self.view.frame.width, self.view.frame.height/2)
        self.collectionView.frame = .init(0, self.view.frame.height/2, self.view.frame.width, self.view.frame.height/2)
        self.adjustLayout()
        
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 좌우형 : willDisapplear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
        
        self.explanationView.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("5다선지 좌우형 : disappear")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        print("5다선지 좌우형 : willMove")
    }
}

extension MultipleWith5AnswerWideVC {
    func configureDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configureLoader() {
        self.canvasView.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.canvasView.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.canvasView.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    func configureCanvasView() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }
    
    func configureCanvasViewData() {
        if let pkData = self.viewModel?.pagePencilData {
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
    
    func configureMainImageView() {
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
    }
}

extension MultipleWith5AnswerWideVC: UIScrollViewDelegate {
    // 화면이 회전할 때 실행
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 회전 이전
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        
        coordinator.animate { _ in
            // 회전 도중
            UIView.performWithoutAnimation {
                let viewSize = self.view.frame.size
                if UIWindow.isLandscape {
                    let size = CGSize(viewSize.width/2, viewSize.height)
                    self.canvasView.frame = .init(origin: .init(0, 0), size: size)
                    self.collectionView.frame = .init(origin: .init(viewSize.width/2, 0), size: size)
                } else {
                    let size = CGSize(viewSize.width, viewSize.height/2)
                    self.canvasView.frame = .init(origin: .init(0, 0), size: size)
                    self.collectionView.frame = .init(origin: .init(0, viewSize.height/2), size: size)
                }
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
            }
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}

// MARK: - 제스쳐
extension MultipleWith5AnswerWideVC {
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
        self.viewModel?.delegate?.beforePage()
    }
    
    @objc func leftDragged() {
        self.viewModel?.delegate?.nextPage()
    }
}

// MARK: - Configure MultipleWith5Cell
extension MultipleWith5AnswerWideVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item]
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, toolPicker)
        
        return cell
    }
}

extension MultipleWith5AnswerWideVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.bounds.width
        let image = subImages?[indexPath.row] ?? UIImage(.warning)
        let imgHeight = image.size.height * (width/image.size.width)
        let topViewHeight: CGFloat = 51
        let height = topViewHeight + imgHeight
        
        return CGSize(width: width, height: height)
    }
}

extension MultipleWith5AnswerWideVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePagePencilData(to: data)
    }
}

extension MultipleWith5AnswerWideVC: CollectionCellDelegate {
    func reload() {
        self.viewModel?.delegate?.reload()
    }
    
    func showExplanation(image: UIImage?, pid: Int) {
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
    
    func addScoring(pid: Int) {
        self.viewModel?.delegate?.addScoring(pid: pid)
    }
    
    func addUpload(pid: Int) {
        self.viewModel?.delegate?.addUploadProblem(pid: pid)
    }
}

extension MultipleWith5AnswerWideVC: ExplanationRemover {
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 0
        } completion: { _ in
            self.explanationView.removeFromSuperview()
        }
    }
}
