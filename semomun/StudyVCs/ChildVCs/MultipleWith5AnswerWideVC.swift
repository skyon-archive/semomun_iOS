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
    
    @IBOutlet weak var scrollView: UIScrollView! // 지문 스크롤뷰
    @IBOutlet weak var canvasView: PKCanvasView! // 지문 필기뷰
    @IBOutlet weak var imageView: UIImageView! // 지문 이미지뷰
    @IBOutlet weak var collectionView: UICollectionView! // 문제들뷰
    @IBOutlet weak var imageWidth: NSLayoutConstraint! // 지문 이미지 width 필요
    @IBOutlet weak var imageHeight: NSLayoutConstraint! // 지문 이미지 높이
    @IBOutlet weak var canvasViewWidth: NSLayoutConstraint!
    @IBOutlet weak var canvasViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView! // 스크롤뷰 컨텐트뷰
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint! // 지문 width 필요
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint! // 지문 height 필요
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint! // 문제 width 필요
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint! // 문제 height 필요
    
    private var width: CGFloat!
    private var height: CGFloat!
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
        return explanationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        self.configureDelegate()
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
        self.configureOrientation()
        self.configureObservation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 좌우형 : willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.collectionView.reloadData()
        self.configureCanvasView()
        self.configureCanvasViewData()
        self.scrollView.zoomScale = 1.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 좌우형 : didAppear")
        self.configureOrientation()
        self.stopLoader()
        self.configureMainImageView()
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 좌우형 : willDisapplear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
        self.imageView.image = nil
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
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.removeObserver(canvasView)
        print("5다선지 좌우형 deinit")
    }
}

extension MultipleWith5AnswerWideVC {
    func configureDelegate() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configureLoader() {
        self.scrollView.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        self.canvasView.isHidden = true
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
    
    private func configureScrollView() {
        self.scrollView.minimumZoomScale = 0.5
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.delegate = self
    }
    
    func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
        self.canvasView.isHidden = false
    }
    
    func configureCanvasView() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
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
        // MARK: 세로, 가로모드에 따른 설정 필요
        width = canvasView.frame.width
        guard let mainImage = self.mainImage else { return }
        height = mainImage.size.height*(width/mainImage.size.width)
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            imageView.image = mainImage
        } else {
            let worningImage = UIImage(.warning)
            imageView.image = worningImage
            height = worningImage.size.height*(width/worningImage.size.width)
        }
        
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.imageHeight.constant = height
        self.canvasViewHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
}

// MARK: - Configure Orientation UI
extension MultipleWith5AnswerWideVC {
    private func configureOrientation() {
        // MARK: 가로, 세로에 따른 UI 설정
        if UIDevice.current.orientation.isLandscape {
            self.imageWidth.constant = self.view.bounds.width/2
            self.canvasViewWidth.constant = self.view.bounds.width/2
            self.scrollViewWidth.constant = self.view.bounds.width/2
            self.scrollViewHeight.constant = self.view.bounds.height
            self.collectionViewWidth.constant = self.view.bounds.width/2
            self.collectionViewHeight.constant = self.view.bounds.height
        } else {
            self.imageWidth.constant = self.view.bounds.width
            self.canvasViewWidth.constant = self.view.bounds.width
            self.scrollViewWidth.constant = self.view.bounds.width
            self.scrollViewHeight.constant = self.view.bounds.height/2
            self.collectionViewWidth.constant = self.view.bounds.width
            self.collectionViewHeight.constant = self.view.bounds.height/2
        }
    }
    
    private func configureObservation() {
        // MARK:  가로, 세로 변화 수신
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceRotated(){
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.configureOrientation()
            self?.view.layoutIfNeeded()
            self?.configureMainImageView()
        }
    }
}


// MARK: - Configure MultipleWith5Cell
extension MultipleWith5AnswerWideVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problems[indexPath.item]
        let superWidth = self.collectionView.frame.width
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, superWidth, toolPicker)
        
        return cell
    }
}

extension MultipleWith5AnswerWideVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // MARK: 가로, 세로모드에 따른 계산 로직 필요
        let width: CGFloat = self.view.frame.width/2 - 10
        let solveInputFrameHeight: CGFloat = 6 + 45
        // imageView 높이값 가져오기
        guard var contentImage = subImages?[indexPath.row] else {
            return CGSize(width: width, height: 300) }
        if contentImage.size.width == 0 || contentImage.size.height == 0 {
            contentImage = UIImage(.warning)
        }
        let imgHeight: CGFloat = contentImage.size.height * (width/contentImage.size.width)
        
        let height: CGFloat = solveInputFrameHeight + imgHeight
        
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
        // MARK: 가로, 세로에 따른 해설 UI 로직 구현 필요
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
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension MultipleWith5AnswerWideVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}
