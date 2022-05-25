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
    private let canvasView = PKCanvasView()
    private let imageView = UIImageView()
    private let background = UIView()
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    
    // 상속 전용
    var internalTopViewHeight: CGFloat {
        assertionFailure()
        return 51
    }
    
    weak var delegate: CollectionCellDelegate?
    
    var toolPicker: PKToolPicker?
    
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        self.imageView.addSubview(imageView)
        imageView.isHidden = true
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureBasicUI()
        self.configureScrollView()
    }
    
    override func prepareForReuse() {
        self.canvasView.delegate = nil
        self.resultImageView.isHidden = true
        self.layoutCanvas()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutCanvas()
    }
    
    private func layoutCanvas() {
        self.adjustLayout {
            let size = self.contentView.frame
            self.canvasView.frame = .init(0, self.internalTopViewHeight, size.width, size.height-self.internalTopViewHeight)
        }
    }
    
    // MARK: Configure
    private func configureBasicUI() {
        self.contentView.addSubviews(self.canvasView, self.background)
        self.contentView.sendSubviewToBack(self.canvasView)
        self.contentView.sendSubviewToBack(self.background)
        
        self.canvasView.addDoubleTabGesture()
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        self.canvasView.backgroundColor = .clear
        
        self.imageView.backgroundColor = .white
        
        self.background.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    // MARK: - Configure Reuse
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        self.configureProblem(problem)
        self.configureImageView(contentImage)
        self.toolPicker = toolPicker
        self.configureCanvasView()
    }
    
    func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
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
    
    func configureCanvasView() {
        self.configureCanvasViewDataAndDelegate()
        
        canvasView.isOpaque = false
//        canvasView.becomeFirstResponder()
        canvasView.drawingPolicy = .pencilOnly
        
//        toolPicker?.setVisible(true, forFirstResponder: canvasView)
        toolPicker?.addObserver(canvasView)
    }
    
    func configureCanvasViewDataAndDelegate() {
        if let pkData = self.problem?.drawing {
            do {
                try canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            canvasView.drawing = PKDrawing()
        }
        canvasView.delegate = self
    }
    
    func updateSolved(input: String) {
        guard let problem = self.problem else { return }

        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = input == answer
            problem.setValue(correct, forKey: "correct")
        }
        self.delegate?.addScoring(pid: Int(problem.pid))
    }
    
    func showResultImage(to: Bool) {
        let imageName: String = to ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        self.resultImageView.isHidden = false
    }
    
    /// action 전/후 레이아웃 변경을 저장해주는 편의 함수
    private func adjustLayout(_ action: (() -> ())? = nil) {
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        action?()
        self.adjustLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
    }
    
    /// CanvasView의 크기가 바뀐 후 이에 맞게 필기/이미지 레이아웃을 수정
    private func adjustLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint) {
        guard let image = self.imageView.image else {
            assertionFailure("CanvasView의 크기를 구할 이미지 정보 없음")
            return
        }
        
        let ratio = image.size.height/image.size.width
        
        self.canvasView.adjustDrawingLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
        
        // 배경 뷰 위치 설정
        self.background.frame = self.canvasView.frame
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        // 채점 이미지 크기 설정
        if self.resultImageView.isHidden == false {
            let imageViewWidth = self.imageView.frame.width
            
            self.resultImageView.frame = .init(imageViewWidth/10, imageViewWidth/10, imageViewWidth*150/834, imageViewWidth*150/834)
        }
    }
}

extension FormCell: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let problem = self.problem else { return }
        let data = self.canvasView.drawing.dataRepresentation()
        problem.setValue(data, forKey: "drawing")
        self.delegate?.addUpload(pid: Int(problem.pid))
    }
}

extension FormCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}
