//
//  FormCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

protocol CellLayoutable {
    static var identifier: String { get }
    static func topViewHeight(with problem: Problem_Core) -> CGFloat
}

class FormCell: UICollectionViewCell, PKToolPickerObserver {
    private let canvasView = RotationableCanvasView()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.lightGrayBackgroundColor)
        return view
    }()
    private lazy var resultImageView: CorrectImageView = {
        let imageView = CorrectImageView()
        self.imageView.addSubview(imageView)
        return imageView
    }()
    let timerView: ProblemTimerView = {
        let timerView = ProblemTimerView()
        timerView.isHidden = true
        return timerView
    }()
    private var toolPicker: PKToolPicker?
    
    /* VC 에서 사용되는 property */
    private var isCanvasDrawingLoaded: Bool = false
    
    /* 자식 cell 에서 사용 가능한 Property들 */
    weak var delegate: CollectionCellDelegate?
    var problem: Problem_Core?
    var showTopShadow: Bool = false
    
    /* 자식 cell 에서 override 해야 하는 Property들 */
    var internalTopViewHeight: CGFloat {
        assertionFailure()
        return 51
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBasicUI()
        self.configureScrollView()
        self.configureCanvasView()
    }
    
    override func prepareForReuse() {
        self.canvasView.delegate = nil
        self.resultImageView.isHidden = true
        self.timerView.isHidden = true
        self.isCanvasDrawingLoaded = false
    }
    
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        self.configureProblem(problem)
        self.configureImageView(contentImage)
        self.configureToolpicker(toolPicker)
        self.configureTimer()
    }
    
    // MARK: Rotation
    override func layoutSubviews() {
        super.layoutSubviews()
        self.adjustLayouts(rotate: true)
        self.configureCanvasViewDataAndDelegate()
    }
}

// MARK: Configure
extension FormCell {
    private func configureBasicUI() {
        self.contentView.addSubviews(self.canvasView, self.background)
        self.contentView.sendSubviewToBack(self.canvasView)
        self.contentView.sendSubviewToBack(self.background)
        
        self.canvasView.addDoubleTabGesture()
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
    }
    
    private func configureCanvasView() {
        self.canvasView.isOpaque = false
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
    }
}

// MARK: Configure Reuse
extension FormCell {
    private func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    private func configureImageView(_ contentImage: UIImage?) {
        guard let contentImage = contentImage,
              contentImage.size.width > 0, contentImage.size.height > 0 else {
            self.imageView.image = UIImage(.warning)
            return
        }
        self.imageView.image = contentImage
    }
    
    private func configureToolpicker(_ toolPicker: PKToolPicker?) {
        self.toolPicker = toolPicker
        self.toolPicker?.setVisible(true, forFirstResponder: self.canvasView)
        self.toolPicker?.addObserver(self.canvasView)
    }
    
    private func configureCanvasViewDataAndDelegate() {
        guard self.isCanvasDrawingLoaded == false else { return }
        // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
        defer { self.canvasView.delegate = self }
        
        let savedData = self.problem?.drawing
        let lastWidth = self.problem?.drawingWidth
        // 필기데이터 ratio 조절 후 표시
        self.canvasView.loadDrawing(to: savedData, lastWidth: lastWidth)
        self.isCanvasDrawingLoaded = true
    }
    
    private func configureTimer() {
        guard let problem = self.problem else { return }
        
        if problem.terminated {
            self.timerView.configureTime(to: problem.time)
            self.timerView.isHidden = false
        } else {
            self.timerView.isHidden = true
        }
    }
}

// MARK: Rotation
extension FormCell {
    private func adjustLayouts(rotate: Bool = false) {
        let contentFrame = self.contentView.frame
        guard let imageSize = self.imageView.image?.size else {
            assertionFailure("imageView 내 image 가 존재하지 않습니다.")
            return
        }
        // canvasView 크기 및 필기 ratio 조절
        self.canvasView.updateFrameAndRatio(contentFrame: contentFrame, topHeight: self.internalTopViewHeight, imageSize: imageSize, rotate: rotate)
        // 배경 뷰 위치 설정
        self.background.frame = self.canvasView.frame
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        // 채점 이미지 크기 설정
        self.resultImageView.adjustLayoutForCell(imageViewWidth: self.imageView.frame.width)
    }
}

// MARK: Child Accessible
extension FormCell {
    func updateSolved(input: String) {
        guard let problem = self.problem else { return }
        problem.setValue(input, forKey: Problem_Core.Attribute.solved.rawValue)
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = (input == answer)
            problem.setValue(correct, forKey: Problem_Core.Attribute.correct.rawValue)
        }
        self.delegate?.addScoring(pid: Int(problem.pid))
    }
    
    func showResultImage(to: Bool) {
        self.resultImageView.show(isCorrect: to)
    }
}

// MARK: Drawing Detect
extension FormCell: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let problem = self.problem else { return }
        
        let width = self.canvasView.frame.width
        let data = self.canvasView.drawing.dataRepresentation()
        problem.setValue(Double(width), forKey: Problem_Core.Attribute.drawingWidth.rawValue)
        problem.setValue(data, forKey: Problem_Core.Attribute.drawing.rawValue)
        
        self.delegate?.addUpload(pid: Int(problem.pid))
    }
}

// MARK: Zooming
extension FormCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayouts()
    }
}
