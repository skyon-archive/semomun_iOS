//
//  test_1ViewController.swift
//  test_1ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class test_1ViewController: UIViewController, PKToolPickerObserver {

    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet var star: UIButton!
    @IBOutlet var bookmark: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var image: UIImage!
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test1 load!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setRadius()
        setBorderWidth()
        setBorderColor()
        setShadowFrame()
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        width = canvasView.frame.width
        height = image.size.height*(width/image.size.width)
        
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("1 : disappear")
    }
    
    // 객관식 1~5 클릭 부분
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
    
}


extension test_1ViewController {
    // 뷰의 라운드 설정 부분
    func setRadius() {
        solvInputFrame.layer.cornerRadius = 20
        for bt in checkNumbers {
            bt.layer.cornerRadius = 20
        }
        
        star.layer.cornerRadius = 17.5
        star.clipsToBounds = true
        
        bookmark.layer.cornerRadius = 17.5
        bookmark.clipsToBounds = true
    }
    
    // 객관식 1~5의 두께 설정 부분
    func setBorderWidth() {
        for bt in checkNumbers {
            bt.layer.borderWidth = 0.5
        }
    }
    
    // 객관식 1~5의 두께 색설정 부분
    func setBorderColor() {
        for bt in checkNumbers {
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
