//
//  test_3ViewController.swift
//  test_3ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class test_3ViewController: UIViewController, PKToolPickerObserver {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var images: [UIImage] = []
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        images = [UIImage(named: "B-1")!, UIImage(named: "B-2")!, UIImage(named: "B-3")!]
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        guard let mainImage = UIImage(named: "B-0") else { return }
        
        width = canvasView.frame.width
        height = mainImage.size.height*(width/mainImage.size.width)
        
        imageView.image = mainImage
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("3 : disappear")
    }
}



extension test_3ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KoreanCell", for: indexPath) as? KoreanCell else { return UICollectionViewCell() }
        cell.setRadius()
        cell.setSolvUI()
        cell.setShadowFrame()
        cell.setCanvas()
        cell.setImage(img: images[indexPath.item])
        cell.setHeight(superWidth: collectionView.frame.width)
        return cell
    }
    
}

extension test_3ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // imageView 높이값 가져오기
        let img = images[indexPath.row]
        let imgHeight: CGFloat = img.size.height * (collectionView.frame.width/img.size.width)
        
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 161 + imgHeight
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
    @IBOutlet var bookmark: UIButton!
    
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
        solvInputFrame.layer.cornerRadius = 20
        
        star.layer.cornerRadius = 17.5
        star.clipsToBounds = true
        
        bookmark.layer.cornerRadius = 17.5
        bookmark.clipsToBounds = true
    }
    
    func setSolvUI() {
        for bt in checkNumbers {
            bt.layer.cornerRadius = 20
            bt.layer.borderWidth = 0.5
            bt.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    // 객관식 입력창의 그림자 설정 부분
    func setShadowFrame() {
        solvInputFrame.layer.shadowColor = UIColor.lightGray.cgColor
        solvInputFrame.layer.shadowOpacity = 0.3
        solvInputFrame.layer.shadowOffset = CGSize(width: 3, height: 3)
        solvInputFrame.layer.shadowRadius = 5
        solvInputFrame.layer.masksToBounds = false
        
        star.layer.shadowColor = UIColor.lightGray.cgColor
        star.layer.shadowOpacity = 0.3
        star.layer.shadowOffset = CGSize(width: 2, height: 2)
        star.layer.shadowRadius = 3
        star.layer.masksToBounds = false
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
