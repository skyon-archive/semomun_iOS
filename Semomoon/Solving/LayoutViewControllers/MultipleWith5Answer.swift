//
//  test_3ViewController.swift
//  test_3ViewController
//
//  Created by qwer on 2021/08/25.
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
    var pageData: PageData?
    var problems: [Problem_Core]?
    weak var delegate: PageDelegate?
    var isShow: Bool = false
    
    var toolPicker: PKToolPicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 좌우형 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureProblems()
        self.configureCanvasView()
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 좌우형 didAppear")
        self.configureMainImageView()
        self.isShow = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("5다선지 좌우형 : disappear")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        print("----------------------")
//        self.toolPicker?.removeObserver(canvasView)
//        guard let count = problems?.count else { return }
//        for i in 0..<count {
//            let index = IndexPath(row: i, section: 0)
//            guard let cell = collectionView.cellForItem(at: index) as? MultipleWith5Cell else { return }
//            cell.toolPicker?.removeObserver(cell.canvasView)
//            print("remove at: \(i)")
//        }
        
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
        if !isShow {
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
        }
        toolPicker?.addObserver(canvasView)
        
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
        
        cell.delegate = self.delegate
        cell.configureReuse(contentImage, problem, superWidth, toolPicker, isShow)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MultipleWith5Cell else { return }
        cell.toolPicker?.removeObserver(cell.canvasView)
        print("remove at: \(indexPath.item)")
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
        saveCoreData()
    }
}
