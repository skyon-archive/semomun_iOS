//
//  test_1ViewController.swift
//  test_1ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class test_1ViewController: UIViewController, CALayerDelegate {

    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet weak var sol_1: UIButton!
    @IBOutlet weak var sol_2: UIButton!
    @IBOutlet weak var sol_3: UIButton!
    @IBOutlet weak var sol_4: UIButton!
    @IBOutlet weak var sol_5: UIButton!
    
    @IBOutlet var star: UIButton!
    @IBOutlet var bookmark: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var underImage: UIImageView!
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
//    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    var buttons: [UIButton] = []
    
    
    var height: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [sol_1, sol_2, sol_3, sol_4, sol_5]

        setRadius()
        setBorderWidth()
        setBorderColor()
        setShadowFrame()
        
//        underImage.layer.delegate = self
        let image = UIImage(named: "A-1")!
        underImage.image = image
        height = image.size.height*(500/image.size.width)
        underImage.frame = CGRect(x: 0, y: 0, width: 500, height: height)
        imageWidth.constant = 500
        imageHeight.constant = height
//
        addPinch()
        
        scrollView.delegate = self
//        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
    }
    
    func addPinch() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(test_1ViewController.didPinch(_:)))
        self.view.addGestureRecognizer(pinch)
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            imageWidth.constant *= gesture.scale
            imageHeight.constant *= gesture.scale
//            contentHeight.constant *= gesture.scale
            gesture.scale = 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("1 : disappear")
    }
    
    // 객관식 1~5 클릭 부분
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
    
}


extension test_1ViewController {
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
    
}


extension test_1ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return underImage
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.center = view.center
        underImage.center.x = scrollView.center.x
    }
}
