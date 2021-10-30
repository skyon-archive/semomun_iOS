//
//  MultipleWithNoAnswer.swift
//  Semomoon
//
//  Created by qwer on 2021/10/24.
//

import UIKit
import PencilKit

class MultipleWithNoAnswer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWithNoAnswer" // form == 1 && type == 0

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var mainImage: UIImage!
    var subImages: [UIImage]!
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        let tempData = PKDrawing()
        canvasView.drawing = tempData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        width = canvasView.frame.width
        height = mainImage.size.height*(width/mainImage.size.width)
        
        imageView.image = mainImage
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
        
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("3 : disappear")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
    }
    
}

extension MultipleWithNoAnswer: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoAnswerCell", for: indexPath) as? NoAnswerCell else { return UICollectionViewCell() }
        cell.setRadius()
        cell.setCanvas()
        cell.setImage(img: subImages[indexPath.item])
        cell.setHeight(superWidth: collectionView.frame.width)
        return cell
    }
}

extension MultipleWithNoAnswer: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // imageView 높이값 가져오기
        let img = subImages[indexPath.row]
        let imgHeight: CGFloat = img.size.height * (collectionView.frame.width/img.size.width)
        
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 64 + imgHeight
        return CGSize(width: width, height: height)
    }
}

class NoAnswerCell: UICollectionViewCell, PKToolPickerObserver {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet var star: UIButton!
    
    @IBOutlet weak var probHeaderFrame: UIView!
    var image: UIImage = UIImage()
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    func setRadius() {
       probHeaderFrame.layer.cornerRadius = 27
    }

    func setCanvas() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
    }
    
    func setImage(img: UIImage) {
        self.image = img
        self.imageView.image = image
        imageView.clipsToBounds = true
    }
    
    func setHeight(superWidth: CGFloat) {
        let height = image.size.height*(superWidth/image.size.width)
        
        imageView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        canvasHeight.constant = height
    }
}
