//
//  SingleWith5AnswerVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

final class SingleWith5AnswerVC: UIViewController, PKToolPickerObserver {
    static let identifier = "SingleWith5AnswerVC" // form == 0 && type == 5
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var explanationBT: UIButton!
    @IBOutlet weak var answerBT: UIButton!
    @IBOutlet var checkNumbers: [UIButton]!
    
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    private var canvasView = PKCanvasView()
    private let imageView = UIImageView()
    
    var image: UIImage?
    var viewModel: SingleWith5AnswerVM?
    
    private let toolPicker = PKToolPicker()
    
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
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    private lazy var explanationView: ExplanationView = {
        let explanationView = ExplanationView()
        explanationView.alpha = 0
        return explanationView
    }()
    private lazy var answerView: AnswerView = {
        let answerView = AnswerView()
        answerView.alpha = 0
        return answerView
    }()
    private lazy var timerView = ProblemTimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureLoader()
        self.configureGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
        self.configureBasicUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 willAppear")
        
        self.configureCanvasView()
        self.configureCanvasViewData()
        
        self.configureImageView()
        self.showResultImage()
        
        self.configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 didAppear")
        
        self.viewModel?.startTimeRecord()
        self.stopLoader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 willDisappear")
        
        self.setViewToDefault()
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.viewModel?.problem,
              problem.terminated == false else { return }
        
        let input: Int = sender.tag
        self.viewModel?.updateSolved(withSelectedAnswer: "\(input)")
        
        self.configureCheckButtons()
    }
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
    
    @IBAction func showExplanation(_ sender: Any) {
        guard let imageData = self.viewModel?.problem?.explanationImage else { return }
        let explanationImage = UIImage(data: imageData)
        self.explanationBT.isSelected.toggle()
        
        if self.explanationBT.isSelected {
            self.showExplanation(to: explanationImage)
        } else {
            self.closeExplanation()
        }
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        guard let answer = self.viewModel?.answer() else { return }
        self.answerView.removeFromSuperview()
        
        self.answerView.configureAnswer(to: answer.circledAnswer)
        self.view.addSubview(self.answerView)
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
}

// MARK: - Configures
extension SingleWith5AnswerVC {
    /// 단 한 번만 필요한 UI 설정을 수행
    private func configureBasicUI() {
        self.view.addSubview(self.canvasView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        self.imageView.backgroundColor = .white
        self.view.backgroundColor = UIColor(.lightGrayBackgroundColor)
    }
    
    /// 각 view들의 상태를 view가 처음 보여졌을 때의 것으로 초기화
    private func setViewToDefault() {
        self.canvasView.setContentOffset(.zero, animated: false)
        self.canvasView.zoomScale = 1.0
        self.canvasView.contentInset = .zero

        // 필기 남는 버그 우회
        self.canvasView.removeFromSuperview()
        self.imageView.removeFromSuperview()
        self.canvasView = PKCanvasView()
        self.view.addSubview(self.canvasView)
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.resultImageView.removeFromSuperview()
        self.checkImageView.removeFromSuperview()
        self.timerView.removeFromSuperview()
        self.explanationView.removeFromSuperview()
        self.answerView.removeFromSuperview()
    }
    
    private func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
        
        self.canvasView.frame = .init(origin: .init(0, self.topView.frame.height), size: self.contentSize)
        self.adjustCanvasLayout()
    }
    
    private func configureCheckButtons() {
        guard let problem = self.viewModel?.problem else { return }
        
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
        if let answer = self.viewModel?.answer(),
           problem.terminated == true {
            self.answerBT.isHidden = true
            if answer != "복수",
               let targetIndex = Int(answer) {
                self.createCheckImage(to: targetIndex-1)
                self.configureTimerView()
            }
        }
    }
    
    private func createCheckImage(to index: Int) {
        self.checkImageView.image = UIImage(named: "check")
        self.view.addSubview(self.checkImageView)
        self.checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.checkImageView.widthAnchor.constraint(equalToConstant: 75),
            self.checkImageView.heightAnchor.constraint(equalToConstant: 75),
            self.checkImageView.centerXAnchor.constraint(equalTo: self.checkNumbers[index].centerXAnchor, constant: 10),
            self.checkImageView.centerYAnchor.constraint(equalTo: self.checkNumbers[index].centerYAnchor, constant: -10)
        ])
    }
    
    private func configureTimerView() {
        guard let time = self.viewModel?.problem?.time else { return }
        
        self.view.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    private func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    private func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    private func showResultImage() {
        guard let problem = self.viewModel?.problem,
              problem.terminated && problem.answer != nil  else { return }
        
        let imageName: String = problem.correct ? "correct" : "wrong"
        self.resultImageView.image = UIImage(named: imageName)
        
        self.imageView.addSubview(self.resultImageView)
        self.resultImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = imageView.frame.width
        let autoLeading: CGFloat = 65*width/CGFloat(834)
        let autoTop: CGFloat = 0*width/CGFloat(834)
        let autoSize: CGFloat = 150*width/CGFloat(834)
        
        NSLayoutConstraint.activate([
            self.resultImageView.widthAnchor.constraint(equalToConstant: autoSize),
            self.resultImageView.heightAnchor.constraint(equalToConstant: autoSize),
            self.resultImageView.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: autoLeading),
            self.resultImageView.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: autoTop)
        ])
    }
    
    private func configureCanvasView() {
        self.canvasView.isOpaque = false
        self.canvasView.backgroundColor = .clear
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
        
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
    }
    
    private func configureCanvasViewData() {
        if let pkData = self.viewModel?.problem?.drawing {
            do {
                try self.canvasView.drawing = PKDrawing.init(data: pkData)
            } catch {
                print("Error loading drawing object")
            }
        } else {
            self.canvasView.drawing = PKDrawing()
        }
        self.canvasView.delegate = self
    }
    
    private func configureImageView() {
        guard let mainImage = self.image else { return }
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
        }
    }
    
    private func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    private func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
}

// MARK: - 레이아웃 관련
extension SingleWith5AnswerVC {
    /// topView를 제외한 나머지 view의 사이즈
    private var contentSize: CGSize {
        return CGSize(self.view.frame.width, self.view.frame.height - self.topView.frame.height)
    }
    
    private func showExplanation(to image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        self.explanationView.configureImage(to: image)
        self.explanationView.addShadow()
        
        self.adjustCanvasLayout {
            self.layoutExplanation()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 1
        }
    }
    
    // 화면이 회전할 때 실행
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // 회전 이전
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        
        coordinator.animate { _ in
            // 회전 도중
            UIView.performWithoutAnimation {
                if self.explanationBT.isSelected {
                    self.layoutExplanation()
                } else {
                    self.canvasView.frame.size = self.contentSize
                    self.topViewTrailingConstraint.constant = 0
                }
                self.adjustCanvasLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
            }
        }
    }
    
    /// ExplanationView의 frame을 상황에 맞게 수정
    private func layoutExplanation() {
        let width = self.contentSize.width
        let height = self.contentSize.height
        let topViewHeight = self.topView.frame.height
        
        if UIWindow.isLandscape {
            self.canvasView.frame.size.width = width/2
            self.canvasView.frame.size.height = height
            self.topViewTrailingConstraint.constant = width/2
            self.explanationView.frame = .init(width/2, 0, width/2, height+topViewHeight)
        } else {
            self.canvasView.frame.size.width = width
            self.canvasView.frame.size.height = height/2
            self.topViewTrailingConstraint.constant = 0
            self.explanationView.frame = .init(0, height/2+topViewHeight, width, height/2)
        }
        
        self.explanationView.updateLayout()
    }
    
    /// CanvasView의 크기가 바뀐 후 이에 맞게 필기/이미지 레이아웃을 수정
    private func adjustCanvasLayout(previousCanvasSize: CGSize, previousContentOffset: CGPoint) {
        guard let image = self.imageView.image else {
            assertionFailure("CanvasView의 크기를 구할 이미지 정보 없음")
            return
        }
        let ratio = image.size.height/image.size.width
        self.canvasView.adjustContentLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset, contentRatio: ratio)
        self.imageView.frame.size = self.canvasView.contentSize
    }
    
    /// action 전/후 레이아웃 변경을 저장해주는 편의 함수
    private func adjustCanvasLayout(_ action: (() -> ())? = nil) {
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        action?()
        self.adjustCanvasLayout(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
    }
}

// MARK: - 제스쳐 설정
extension SingleWith5AnswerVC {
    private func configureGesture() {
        self.configureDoubleTapGesture()
        self.configureSwipeGesture()
    }
    
    private func configureDoubleTapGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGesture.numberOfTapsRequired = 2
        self.canvasView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func doubleTapped() {
        UIView.animate(withDuration: 0.25) {
            self.canvasView.zoomScale = 1.0
        }
    }
    
    private func configureSwipeGesture() {
        let rightSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightDragged))
        rightSwipeGesture.direction = .right
        rightSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(rightSwipeGesture)
        
        let leftSwipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftDragged))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(leftSwipeGesture)
    }
    
    @objc func rightDragged() {
        self.viewModel?.delegate?.beforePage()
    }
    
    @objc func leftDragged() {
        self.viewModel?.delegate?.nextPage()
    }
}

// MARK: - Protocols
extension SingleWith5AnswerVC: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

extension SingleWith5AnswerVC: ExplanationRemover {
    func closeExplanation() {
        self.explanationView.alpha = 0
        self.explanationView.removeFromSuperview()
        self.explanationBT.isSelected = false
        self.topViewTrailingConstraint.constant = 0
        
        self.adjustCanvasLayout {
            self.canvasView.frame.size = self.contentSize
        }
    }
}

extension SingleWith5AnswerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.adjustCanvasLayout()
    }
}
