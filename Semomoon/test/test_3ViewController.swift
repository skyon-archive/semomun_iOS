//
//  test_3ViewController.swift
//  test_3ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class test_3ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images = [UIImage(named: "B-1")!, UIImage(named: "B-2")!, UIImage(named: "B-3")!]
        // Do any additional setup after loading the view.
        
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
        cell.buttons = [cell.sol_1, cell.sol_2, cell.sol_3, cell.sol_4, cell.sol_5]
        cell.setRadius()
        cell.setBorderWidth()
        cell.setBorderColor()
        cell.setShadowFrame()
        cell.setImage(img: images[indexPath.item])
        cell.setHeight(superWidth: collectionView.frame.width)
        return cell
    }
    
}

extension test_3ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // imageView 높이값 가져오기
        let img = images[indexPath.row]
        print("\(img.size.width) * \(img.size.height)")
        print("\(collectionView.frame.width)")
        let imgHeight: CGFloat = img.size.height * (collectionView.frame.width/img.size.width)
        print("\(imgHeight)")
        
        let width: CGFloat = collectionView.frame.width
        let height: CGFloat = 161 + imgHeight
        // cell의 전체 높이 설정
        return CGSize(width: width, height: height)
    }
}

class KoreanCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet weak var sol_1: UIButton!
    @IBOutlet weak var sol_2: UIButton!
    @IBOutlet weak var sol_3: UIButton!
    @IBOutlet weak var sol_4: UIButton!
    @IBOutlet weak var sol_5: UIButton!
    
    @IBOutlet var star: UIButton!
    @IBOutlet var bookmark: UIButton!
    
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    var buttons: [UIButton] = []
    var image: UIImage = UIImage()
    
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        for bt in buttons {
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
        for bt in buttons {
            bt.layer.cornerRadius = 20
        }
        
        star.layer.cornerRadius = 17.5
        star.clipsToBounds = true
        
        bookmark.layer.cornerRadius = 17.5
        bookmark.clipsToBounds = true
    }
    
    // 객관식 1~5의 두께 설정 부분
    func setBorderWidth() {
        for bt in buttons {
            bt.layer.borderWidth = 0.5
        }
    }
    
    // 객관식 1~5의 두께 색설정 부분
    func setBorderColor() {
        for bt in buttons {
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
    
    func setImage(img: UIImage) {
        self.image = img
        self.imgView.image = image
    }
    
    func setHeight(superWidth: CGFloat) {
        let newHeight: CGFloat = image.size.height * (superWidth/image.size.width)
        imgHeight.constant = newHeight
    }
}
