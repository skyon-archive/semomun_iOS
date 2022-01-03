//
//  MultipleWith5Answer.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWith5Answer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "MultipleWith5Answer" // form == 1 && type == 5
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var mainImage: UIImage?
    var subImages: [UIImage?]?
    var viewModel: MultipleWith5AnswerViewModel?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureDelegate()
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 좌우형 : willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.collectionView.reloadData()
        self.configureCanvasView()
        self.configureCanvasViewData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 좌우형 : didAppear")
        
        self.stopLoader()
//        self.configureCanvasViewData()
        self.configureMainImageView()
        self.viewModel?.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 좌우형 : willDisapplear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.cancelObserver()
        self.imageView.image = nil
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

extension MultipleWith5Answer {
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
        
        canvasView.delegate = self
    }
    
    func configureCanvasViewData() {
        if let pkData = self.viewModel?.pageData.pageCore.drawing {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
    }
    
    func configureMainImageView() {
        width = canvasView.frame.width
        guard let mainImage = self.mainImage else { return }
        height = mainImage.size.height*(width/mainImage.size.width)
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            imageView.image = mainImage
        } else {
            let worningImage = UIImage(named: SemomunImage.warning)!
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
extension MultipleWith5Answer: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.viewModel?.problem(at: indexPath.item)
        let superWidth = self.collectionView.frame.width
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, superWidth, toolPicker)
        
        return cell
    }
}

extension MultipleWith5Answer: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width
        let solveInputFrameHeight: CGFloat = 64
        // imageView 높이값 가져오기
        guard let contentImage = subImages?[indexPath.row] else {
            return CGSize(width: width, height: 300) }
        
        let imgHeight: CGFloat = contentImage.size.height * (collectionView.frame.width/contentImage.size.width)
        
        let height: CGFloat = solveInputFrameHeight + imgHeight
        
        return CGSize(width: width, height: height)
    }
}

extension MultipleWith5Answer {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

extension MultipleWith5Answer: CollectionCellDelegate {
    func updateStar(btName: String, to: Bool) {
        self.viewModel?.delegate?.updateStar(btName: btName, to: to)
    }
    
    func nextPage() {
        self.viewModel?.delegate?.nextPage()
    }
    
    func showExplanation(image: UIImage?) {
        guard let explanationVC = self.storyboard?.instantiateViewController(withIdentifier: ExplanationViewController.identifier) as? ExplanationViewController else { return }
        explanationVC.explanationImage = image
        self.present(explanationVC, animated: true, completion: nil)
    }
    
    func updateWrong(btName: String, to: Bool) {
        self.viewModel?.delegate?.updateWrong(btName: btName, to: to)
    }
}
