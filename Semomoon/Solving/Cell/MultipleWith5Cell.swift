//
//  MultipleWith5Cell.swift
//  Semomoon
//
//  Created by qwer on 2021/11/06.
//

import UIKit
import PencilKit

class MultipleWith5Cell: UICollectionViewCell, PKToolPickerObserver {
    static let identifier = "MultipleWith5Cell"
    
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
    
    func setImage(contentImage: UIImage?) {
        guard let contentImage = contentImage else { return }
        self.image = contentImage
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
