//
//  MultipleWith4Cell.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/11/06.
//

import UIKit
import PencilKit

class MultipleWithNoCell: UICollectionViewCell, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "MultipleWithNoCell"
    
    @IBOutlet weak var star: UIButton!
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var solvInputFrame: UIView!
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: CollectionCellWithNoAnswerDelegate?
    
    var toolPicker: PKToolPicker?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBaseUI()
        print("\(Self.identifier) awakeFromNib")
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker?.setVisible(false, forFirstResponder: canvasView)
        toolPicker?.removeObserver(canvasView)
    }
    
    @IBAction func toggleStar(_ sender: Any) {
        guard let pName = self.problem?.pName else { return }
        self.star.isSelected.toggle()
        let status = self.star.isSelected
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.updateStar(btName: pName, to: status)
    }
    
    @IBAction func nextProblem(_ sender: Any) {
        self.delegate?.nextPage()
    }
    
    // MARK: - Configure
    func configureBaseUI() {
        solvInputFrame.layer.cornerRadius = 27
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
        self.configureImage(contentImage)
        self.configureHeight(superWidth)
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
    
    func configureStar() {
        self.star.isSelected = self.problem?.star ?? false
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
        saveCoreData()
    }
}
