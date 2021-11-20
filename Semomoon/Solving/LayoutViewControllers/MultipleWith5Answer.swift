//
//  test_3ViewController.swift
//  test_3ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

protocol CollectionCellDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func nextPage()
    func showExplanation(image: UIImage)
}

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
    var pageData: PageData?
    var problems: [Problem_Core]?
    weak var delegate: PageDelegate?
    var isShow: Bool = false
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 좌우형 : willAppear")
        print(self.toolPicker.isVisible)
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureProblems()
        self.collectionView.reloadData()
        self.configureMainImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 좌우형 : didAppear")
        self.configureCanvasView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 좌우형 : willDisapplear")
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
    func configureProblems() {
        self.problems = self.pageData?.problems ?? nil
    }
    
    func configureCanvasView() {
        self.configureCanvasViewData()
        
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
        if let pkData = self.pageData?.pageData.drawing {
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
        
        imageView.image = mainImage
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
        return self.problems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleWith5Cell.identifier, for: indexPath) as? MultipleWith5Cell else { return UICollectionViewCell() }
        
        let contentImage = self.subImages?[indexPath.item] ?? nil
        let problem = self.problems?[indexPath.item] ?? nil
        let superWidth = self.collectionView.frame.width
        
        cell.delegate = self
        cell.configureReuse(contentImage, problem, superWidth, toolPicker, isShow)
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
        self.pageData?.pageData.setValue(self.canvasView.drawing.dataRepresentation(), forKey: "drawing")
        print("///////\(pageData?.vid) save complete")
        saveCoreData()
    }
}

extension MultipleWith5Answer: CollectionCellDelegate {
    func updateStar(btName: String, to: Bool) {
        self.delegate?.updateStar(btName: btName, to: to)
    }
    
    func nextPage() {
        self.delegate?.nextPage()
    }
    
    func showExplanation(image: UIImage) {
        guard let explanationVC = self.storyboard?.instantiateViewController(withIdentifier: ExplanationViewController.identifier) as? ExplanationViewController else { return }
        explanationVC.explanationImage = image
        self.present(explanationVC, animated: true, completion: nil)
    }
}
