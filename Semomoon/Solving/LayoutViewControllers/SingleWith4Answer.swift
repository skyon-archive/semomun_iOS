//
//  SingleWith4Answer.swift
//  Semomoon
//
//  Created by qwer on 2021/10/24.
//

import UIKit
import PencilKit

class SingleWith4Answer: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "SingleWith4Answer" // form == 0 && type == 4
    
    @IBOutlet var checkNumbers: [UIButton]!
    @IBOutlet var star: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var width: CGFloat!
    var height: CGFloat!
    var image: UIImage!
    var pageData: PageData?
    var problem: Problem_Core?
    weak var delegate: PageDelegate?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("4다선지 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureProblem()
        self.configureUI()
        self.configureCanvasView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("4다선지 didAppear")
        self.configureImageView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("4다선지 : disappear")
    }
    
    // 객관식 1~4 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        guard let problem = self.problem else { return }
        problem.solved = String(num)
        saveCoreData()
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
    
    @IBAction func toggleStar(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        
    }
    
    @IBAction func nextProblem(_ sender: Any) {
        self.delegate?.nextPage()
    }
}

extension SingleWith4Answer {
    func configureProblem() {
        self.problem = self.pageData?.problems[0] ?? nil
    }
    
    func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
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
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        canvasView.delegate = self
    }
    
    func configureImageView() {
        width = canvasView.frame.width
        height = image.size.height*(width/image.size.width)
        
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        canvasHeight.constant = height
    }
}

extension SingleWith4Answer {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("update!")
    }
}
