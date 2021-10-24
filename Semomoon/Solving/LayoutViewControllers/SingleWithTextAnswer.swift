//
//  test_1ViewController.swift
//  test_1ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit
import PencilKit

class SingleWithTextAnswer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate  {
    static let identifier = "SingleWithTextAnswer"

    @IBOutlet var checkInput: UITextField!
    @IBOutlet var star: UIButton!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRadius()
        
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
    
}


extension SingleWithTextAnswer {
    // 뷰의 라운드 설정 부분
    func setRadius() {
        checkInput.layer.cornerRadius = 17.5
        checkInput.clipsToBounds = true
        checkInput.layer.borderWidth = 1
        checkInput.layer.borderColor = UIColor(named: "mint")?.cgColor
    }
}
