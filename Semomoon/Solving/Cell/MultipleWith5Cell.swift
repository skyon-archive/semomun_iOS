//
//  MultipleWith5Cell.swift
//  Semomoon
//
//  Created by qwer on 2021/11/06.
//

import UIKit
import PencilKit

class MultipleWith5Cell: UICollectionViewCell, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWith5Cell"
    
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet var star: UIButton!
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var solvInputFrame: UIView!
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: PageDelegate?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBaseUI()
        print("\(Self.identifier) awakeFromNib")
    }
    
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
    
    // MARK: - Configure
    func configureBaseUI() {
        solvInputFrame.layer.cornerRadius = 27
        checkNumbers.forEach { $0.layer.cornerRadius = 15 }
    }
    
    // MARK: - Configure Reuse
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ superWidth: CGFloat) {
        self.configureProblem(problem)
        self.configureUI(contentImage, superWidth)
        self.configureCanvasView()
    }
    
    func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    func configureUI(_ contentImage: UIImage?, _ superWidth: CGFloat) {
        self.configureImage(contentImage)
        self.configureHeight(superWidth)
        self.configureCheckButtons()
        self.configureStar()
    }
    
    func configureImage(_ contentImage: UIImage?) {
        guard let contentImage = contentImage else { return }
        self.contentImage = contentImage
        self.imageView.image = contentImage
    }
    
    func configureHeight(_ superWidth: CGFloat) {
        guard let contentImage = self.contentImage else { return }
        let height = contentImage.size.height*(superWidth/contentImage.size.width)
        
        imageView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        canvasHeight.constant = height
    }
    
    func configureCheckButtons() {
        if let solved = self.problem?.solved {
            for bt in checkNumbers {
                bt.layer.cornerRadius = 17.5
                if String(bt.tag) == solved {
                    bt.backgroundColor = UIColor(named: "mint")
                    bt.setTitleColor(UIColor.white, for: .normal)
                } else {
                    bt.backgroundColor = UIColor.white
                    bt.setTitleColor(UIColor(named: "mint"), for: .normal)
                }
            }
        } else {
            for bt in checkNumbers {
                bt.layer.cornerRadius = 17.5
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
        }
    }
    
    func configureStar() {
        self.star.isSelected = self.problem?.star ?? false
    }
    
    func configureCanvasView() {
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.becomeFirstResponder()
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        
        canvasView.delegate = self
    }
}
