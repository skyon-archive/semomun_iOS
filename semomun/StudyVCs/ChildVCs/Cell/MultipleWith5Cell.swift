//
//  MultipleWith5Cell.swift
//  semomun
//
//  Created by Kang Minsang on 2021/12/19.
//

import UIKit
import PencilKit

class MultipleWith5Cell: UICollectionViewCell, PKToolPickerObserver {
    static let identifier = "MultipleWith5Cell"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet var checkNumbers: [UIButton]!
    
    private let canvasView = PKCanvasView()
    private let imageView = UIImageView()
    
    var contentImage: UIImage?
    var problem: Problem_Core?
    weak var delegate: CollectionCellDelegate?
    
    var toolPicker: PKToolPicker?
    lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    private lazy var timerView = ProblemTimerView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureUI()
        self.configureScrollView()
        
        self.contentView.addSubview(canvasView)
        self.canvasView.addDoubleTabGesture()
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.canvasView.borderColor = .red
        self.canvasView.borderWidth = 5
        self.imageView.borderColor = .blue
        self.imageView.borderWidth = 5
        
        print("\(Self.identifier) awakeFromNib")
    }
    
    override func prepareForReuse() {
        self.configureUI()
        self.canvasView.delegate = nil
        
        self.layoutIfNeeded()
        let size = self.contentView.frame
        self.canvasView.frame = .init(0, 51, size.width, size.height-51)
        self.adjustLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        let size = self.contentView.frame
        self.canvasView.frame = .init(0, 51, size.width, size.height-51)
        self.adjustLayout()
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.problem else { return }
        if problem.terminated { return }
        
        let input: Int = sender.tag
        self.updateSolved(problem: problem, input: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        
        self.problem?.setValue(status, forKey: "star")
        self.delegate?.reload()
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.problem?.explanationImage,
              let pid = self.problem?.pid else { return }
        self.delegate?.showExplanation(image: UIImage(data: imageData), pid: Int(pid))
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.problem?.answer else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer.circledAnswer)
        self.contentView.addSubview(self.answerView)
        self.answerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.answerView.widthAnchor.constraint(equalToConstant: 146),
            self.answerView.heightAnchor.constraint(equalToConstant: 61),
            self.answerView.centerXAnchor.constraint(equalTo: self.answerBT.centerXAnchor),
            self.answerView.topAnchor.constraint(equalTo: self.answerBT.bottomAnchor,constant: 5)
        ])
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.answerView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 2) { [weak self] in
                self?.answerView.alpha = 0
            }
        }
    }
    
    // MARK: Configure
    private func configureUI() {
        self.resultImageView.removeFromSuperview()
        self.checkImageView.removeFromSuperview()
        self.answerBT.isHidden = false
        self.timerView.removeFromSuperview()
        self.answerView.removeFromSuperview()
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    // MARK: - Configure Reuse
    func configureReuse(_ contentImage: UIImage?, _ problem: Problem_Core?, _ toolPicker: PKToolPicker?) {
        self.configureProblem(problem)
        self.configureUI(contentImage)
        self.toolPicker = toolPicker
        self.configureCanvasView()
    }
    
    func configureProblem(_ problem: Problem_Core?) {
        self.problem = problem
    }
    
    func configureUI(_ contentImage: UIImage?) {
        self.configureImageView(contentImage)
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
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
    
    func configureCheckButtons() {
        guard let problem = self.problem else { return }
        
        // 일단 모든 버튼 표시 구현
        for bt in checkNumbers {
            bt.backgroundColor = UIColor.white
            bt.setTitleColor(UIColor(.deepMint), for: .normal)
        }
        // 사용자 체크한 데이터 표시
        if let solved = problem.solved {
            guard let targetIndex = Int(solved) else { return }
            self.checkNumbers[targetIndex-1].backgroundColor = UIColor(.deepMint)
            self.checkNumbers[targetIndex-1].setTitleColor(UIColor.white, for: .normal)
        }
        
        // 채점이 완료된 경우 && 틀린 경우 정답을 빨간색으로 표시
        if let answer = problem.answer,
           problem.terminated == true {
            self.answerBT.isHidden = true
            guard let targetIndex = Int(answer) else { return }
            // 체크 이미지 표시
            self.showResultImage(to: problem.correct)
            self.createCheckImage(to: targetIndex-1)
            self.configureTimerView()
        }
    }
    
    func createCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.contentView.addSubview(self.checkImageView)
        self.checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 70),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 70),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkNumbers[index].centerXAnchor, constant: 9),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkNumbers[index].centerYAnchor, constant: -9)
        ])
    }
    
    func configureTimerView() {
        guard let time = self.problem?.time else { return }
        
        self.contentView.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 9)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func showResultImage(to: Bool) {
        let imageName: String = to ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        self.imageView.addSubview(self.resultImageView)
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureCanvasView() {
        self.configureCanvasViewDataAndDelegate()
        
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
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
    
    func updateSolved(problem: Problem_Core, input: String) {
        problem.setValue(input, forKey: "solved") // 사용자 입력 값 저장
        
        if let answer = problem.answer { // 정답이 있는 경우 정답여부 업데이트
            let correct = input == answer
            problem.setValue(correct, forKey: "correct")
        }
        self.delegate?.addScoring(pid: Int(problem.pid))
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
        
        // 문제 이미지 크기 설정
        self.imageView.frame.size = self.canvasView.contentSize
        // 채점 이미지 크기 설정
        let imageViewWidth = self.imageView.frame.width
        self.resultImageView.frame = .init(imageViewWidth*65/834, 0, imageViewWidth*150/834, imageViewWidth*150/834)
    }
}

extension MultipleWith5Cell: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        guard let problem = self.problem else { return }
        let data = self.canvasView.drawing.dataRepresentation()
        problem.setValue(data, forKey: "drawing")
        self.delegate?.addUpload(pid: Int(problem.pid))
    }
}

extension MultipleWith5Cell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustLayout()
    }
}
