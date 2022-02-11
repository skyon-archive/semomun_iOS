//
//  MultipleWithNoCell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWithNoCell: UICollectionViewCell, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWithNoCell"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: CollectionCellWithNoAnswerDelegate?
    
    var toolPicker: PKToolPicker?
    private lazy var timerView = ProblemTimerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
        print("\(Self.identifier) awakeFromNib")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.configureUI()
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        toolPicker?.removeObserver(canvasView)
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.showExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    // MARK: - Configure
    func configureUI() {
        self.timerView.removeFromSuperview()
        self.shadowView.addShadow(direction: .top)
    }
    
    // MARK: - Configure Reuse
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ superWidth: CGFloat, _ toolPicker: PKToolPicker?) {
        self.configureProblem(problem)
        self.configureUI(contentImage, superWidth)
        self.toolPicker = toolPicker
        self.configureCanvasView()
    }
    
    func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    func configureUI(_ contentImage: UIImage?, _ superWidth: CGFloat) {
        self.configureImageView(contentImage)
        self.configureHeight(superWidth)
        self.configureStar()
        self.configureExplanation()
        self.configureTimerView()
    }
    
    func configureImageView(_ contentImage: UIImage?) {
        guard let contentImage = contentImage else { return }
        if contentImage.size.width > 0 && contentImage.size.height > 0 {
            self.contentImage = contentImage
        } else {
            self.contentImage = UIImage(.warning)
        }
        self.imageView.image = self.contentImage
    }
    
    func configureHeight(_ superWidth: CGFloat) {
        guard let contentImage = self.contentImage else { return }
        let height = contentImage.size.height*(superWidth/contentImage.size.width)
        
        imageView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        imageHeight.constant = height
        canvasView.frame = CGRect(x: 0, y: 0, width: superWidth, height: height)
        canvasHeight.constant = height
    }
    
    func configureTimerView() {
        guard self.problem?.terminated == true,
              let time = self.problem?.time else { return }
        
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.darkMainColor), for: .normal)
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureCanvasView() {
        self.configureCanvasViewData()
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
//        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
        canvasView.subviews[0].addSubview(imageView)
        canvasView.subviews[0].sendSubviewToBack(imageView)
//        toolPicker?.setVisible(true, forFirstResponder: canvasView)
        toolPicker?.addObserver(canvasView)
        
        canvasView.delegate = self
    }
    
    func configureCanvasViewData() {
        if let pkData = self.problem?.drawing {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
    }
}

extension MultipleWithNoCell {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.problem?.setValue(self.canvasView.drawing.dataRepresentation(), forKey: "drawing")
        guard let pName = self.problem?.pName else { return }
        self.delegate?.updateCheck(btName: pName)
    }
}
