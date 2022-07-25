//
//  FormCell.swift
//  semomun
//
//  Created by SEONG YEOL YI on 2022/05/23.
//

import UIKit
import PencilKit

class FormCell: UICollectionViewCell, PKToolPickerObserver {
    /* public */
    weak var delegate: (FormCellControllable&ExplanationSelectable)?
    var problem: Problem_Core?
    var showTopShadow: Bool = false
    var mode: StudyVC.Mode = .default
    // MARK: canvasView의 위치 설정을 위해 override가 필요
    var internalTopViewHeight: CGFloat {
        assertionFailure("override error: internalTopViewHeight")
        return 51
    }
    // MARK: 자식 클래스에서 설정이 필요
    lazy var toolbarView = StudyToolbarView(delegate: self)
    /* private */
    private var toolPicker: PKToolPicker?
    private var isCanvasDrawingLoaded: Bool = false
    private let imageView: SecretImageView = {
        let imageView = SecretImageView(preventCapture: false)
        imageView.backgroundColor = .getSemomunColor(.white)
        return imageView
    }()
    private let background: UIView = {
        let view = UIView()
        view.backgroundColor = .getSemomunColor(.white)
        return view
    }()
    private let timerView = ProblemTimerView()
    private let correctImageView = CorrectImageView()
    private let canvasView = RotationableCanvasView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureSubViews()
        self.configureToolbarLayout()
        self.configureTimerLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.canvasView.setDefaults()
        self.correctImageView.hide()
        self.timerView.isHidden = true
        self.isCanvasDrawingLoaded = false
        // AnswerView가 표시되는 중에 reuse될 수 있다고 생각하여 제거
        self.toolbarView.hideAnswerView()
    }
    
    // MARK: Rotation
    override func layoutSubviews() {
        super.layoutSubviews()
        self.adjustLayouts(frameUpdate: true)
        self.updateCanvasViewDataAndDelegate()
    }
 
    // MARK: cellForItemAt에서 데이터 주입을 위해 사용. 자식 클래스에서도 같은 목적으로 override하여 사용.
    func prepareForReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?, _ mode: StudyVC.Mode? = .default) {
        self.mode = mode ?? .default
        self.updateProblem(problem)
        self.updateImageView(contentImage)
        self.updateToolPicker(toolPicker)
        self.updateTimerView()
    }
}

// MARK: Child Accessible
extension FormCell {
    /// 사용자가 문제가 풀었음을 input 답과 함께 저장.
    /// answer값이 존재하는 경우 string 단순 비교를 통해 정답 여부도 저장.
    func updateSolved(input: String) {
        guard let problem = self.problem else { return }
        problem.setValue(input, forKey: Problem_Core.Attribute.solved.rawValue)
        
        if let answer = problem.answer {
            let correct = (input == answer)
            problem.setValue(correct, forKey: Problem_Core.Attribute.correct.rawValue)
        }
        self.delegate?.addScoring(pid: Int(problem.pid))
    }
    
    func showCorrectImage(isCorrect: Bool) {
        self.correctImageView.show(isCorrect: isCorrect)
    }
}

// MARK: Configure
extension FormCell {
    private func configureSubViews() {
        self.contentView.addSubviews(self.canvasView, self.background, self.toolbarView, self.timerView)
        self.contentView.sendSubviewToBack(self.canvasView)
        self.contentView.sendSubviewToBack(self.background)
        
        self.canvasView.addDoubleTabGesture()
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.imageView.addSubview(self.correctImageView)
    }
    
    private func configureToolbarLayout() {
        NSLayoutConstraint.activate([
            self.toolbarView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 32),
            self.toolbarView.bottomAnchor.constraint(equalTo: self.contentView.topAnchor, constant: self.internalTopViewHeight)
        ])
    }
    
    private func configureTimerLayout() {
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.toolbarView.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.toolbarView.trailingAnchor, constant: 12)
        ])
    }
}

// MARK: Update
extension FormCell {
    private func updateCanvasViewDataAndDelegate() {
        guard self.isCanvasDrawingLoaded == false else { return }
        
        defer {
            // 설정 중에 delegate가 호출되지 않도록 마지막에 지정
            self.canvasView.delegate = self
            self.isCanvasDrawingLoaded = true
        }
        
        let savedData = self.problem?.drawing
        let lastWidth = self.problem?.drawingWidth
        self.canvasView.loadDrawing(to: savedData, lastWidth: lastWidth)
    }
    
    private func updateProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    private func updateImageView(_ contentImage: UIImage?) {
        guard let contentImage = contentImage, contentImage.size.hasValidSize else {
            self.imageView.image = UIImage(.warning)
            return
        }
        self.imageView.image = contentImage
    }
    
    private func updateToolPicker(_ toolPicker: PKToolPicker?) {
        self.toolPicker = toolPicker
        self.toolPicker?.setVisible(true, forFirstResponder: self.canvasView)
        self.toolPicker?.addObserver(self.canvasView)
    }
    
    private func updateTimerView() {
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
    private func adjustLayouts(frameUpdate: Bool = false) {
        let contentSize = self.contentView.frame.size
        guard let imageSize = self.imageView.image?.size else {
            assertionFailure("imageView 내 image 가 존재하지 않습니다.")
            return
        }
        // canvasView 필기 ratio 조절 및 필요시 frame update
        if frameUpdate {
            self.canvasView.updateDrawingRatioAndFrame(
                contentSize: contentSize,
                topHeight: self.internalTopViewHeight,
                imageSize: imageSize
            )
        } else {
            self.canvasView.updateDrawingRatio(imageSize: imageSize)
        }
        
        // 배경 뷰 위치 설정
        self.background.frame = self.canvasView.frame
        // 문제 이미지 크기 설정
        self.imageView.frame = .init(origin: .zero, size: self.canvasView.contentSize)
        // 채점 이미지 크기 설정
        self.correctImageView.adjustLayoutForCell(imageViewWidth: self.imageView.frame.width)
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

extension FormCell: StudyToolbarViewDelegate {
    func toggleBookmark() {
        let status = self.toolbarView.bookmarkSelected
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.refreshPageButtons()
    }
    
    func toggleExplanation() {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.selectExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
}
