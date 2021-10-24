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



extension MultipleWith5Answer: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanCell", for: indexPath) as? KoreanCell else { return UICollectionViewCell() }
        cell.setRadius()
        cell.setButtons()
        cell.setCanvas()
        cell.setImage(img: subImages[indexPath.item])
        cell.setHeight(superWidth: collectionView.frame.width)
        return cell
    }
    
}

extension MultipleWith5Answer: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // imageView 높이값 가져오기
        let img = subImages[indexPath.row]
        let imgHeight: CGFloat = img.size.height * (collectionView.frame.width/img.size.width)
        
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 64 + imgHeight
        return CGSize(width: width, height: height)
    }
}

class KoreanCell: UICollectionViewCell, PKToolPickerObserver {
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet var checkNumbers: [UIButton]!
    
    @IBOutlet var star: UIButton!
    
    var buttons: [UIButton] = []
    var image: UIImage = UIImage()
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        for bt in checkNumbers {
            if(bt.tag == num) {
                bt.backgroundColor = UIColor(named: "mint")
                bt.setTitleColor(UIColor.white, for: .normal)
            } else {
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
        }
    }
    
    // 뷰의 라운드 설정 부분
    func setRadius() {
        solvInputFrame.layer.cornerRadius = 27
    }
    
    func setButtons() {
        for bt in checkNumbers {
            bt.layer.cornerRadius = 15
        }
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
