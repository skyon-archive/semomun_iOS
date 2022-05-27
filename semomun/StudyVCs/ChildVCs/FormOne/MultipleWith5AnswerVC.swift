//
//  MultipleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class MultipleWith5AnswerVC: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "MultipleWith5AnswerVC" // form == 1 && type == 5
    static let storyboardName = "Study"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
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
        
        let cellIdentifier = MultipleWith5Cell.identifier
        let cellNib = UINib(nibName: cellIdentifier, bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: cellIdentifier)
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
        
        self.stopLoader()
        self.configureMainImageView()
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 좌우형 : willDisapplear")
        
        self.viewModel?.endTimeRecord()
        self.imageView.image = nil
        self.explanationView.removeFromSuperview()
        self.scrollViewBottomConstraint.constant = 0
        self.collectionViewBottomConstraint.constant = 0
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

extension MultipleWith5AnswerVC {
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
        self.scrollView.minimumZoomScale = 1.0
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
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
    }
}


// MARK: - Configure MultipleWith5Cell
extension MultipleWith5AnswerVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.problems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problems[indexPath.item]
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, toolPicker)
        
        return cell
    }
}

extension MultipleWith5AnswerVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

extension MultipleWith5AnswerVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePagePencilData(to: data, width: Double(self.canvasView.contentSize.width))
    }
}

extension MultipleWith5AnswerVC: CollectionCellDelegate {
    func reload() {
        self.viewModel?.delegate?.reload()
    }
    
    func showExplanation(image: UIImage?, pid: Int) {
        if let explanationId = self.explanationId {
            if explanationId == pid {
                self.closeExplanation()
            } else {
                self.explanationId = pid
                self.explanationView.configureImage(to: image)
            }
        } else {
            self.explanationId = pid
            
            self.explanationView.configureDelegate(to: self)
            self.view.addSubview(self.explanationView)
            self.explanationView.translatesAutoresizingMaskIntoConstraints = false
            let height = self.view.frame.height/2
            
            NSLayoutConstraint.activate([
                self.explanationView.heightAnchor.constraint(equalToConstant: height),
                self.explanationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.explanationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.explanationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            self.explanationView.configureImage(to: image)
            self.setShadow(with: self.explanationView)
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.scrollViewBottomConstraint.constant = height
                self?.collectionViewBottomConstraint.constant = height
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

extension MultipleWith5AnswerVC: ExplanationRemover {
    func closeExplanation() {
        self.explanationId = nil
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.explanationView.alpha = 0
            self?.scrollViewBottomConstraint.constant = 0
            self?.collectionViewBottomConstraint.constant = 0
        } completion: { [weak self] _ in
            self?.explanationView.removeFromSuperview()
        }
    }
}

extension MultipleWith5AnswerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
