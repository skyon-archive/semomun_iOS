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
    
    private let canvasView = PKCanvasView()
    private let imageView = UIImageView()
    
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    var image: UIImage?
    var viewModel: SingleWith5AnswerVM?
    
    var contentHeight: CGFloat {
        return self.view.frame.height - self.topView.frame.height
    }
    
    var contentWidth: CGFloat {
        return self.view.frame.width
    }
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
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
        self.configureSwipeGesture()
        self.configureDoubleTapGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
        
        self.view.addSubview(self.canvasView)
        
        self.canvasView.addSubview(self.imageView)
        self.canvasView.sendSubviewToBack(self.imageView)
        
        self.canvasView.borderWidth = 5
        self.canvasView.borderColor = .red
        
        self.imageView.borderWidth = 5
        self.imageView.borderColor = .blue
        self.imageView.backgroundColor = .white
        
        self.view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("5다선지 willAppear")
        
        self.canvasView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
        self.canvasView.zoomScale = 1.0
        self.canvasView.contentInset = .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("5다선지 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.showResultImage()
        self.viewModel?.startTimeRecord()
        
        self.canvasView.frame = .init(0, self.topView.frame.height, self.contentWidth, self.contentHeight)
        self.reflectLayoutChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("5다선지 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
        self.resultImageView.removeFromSuperview()
        self.imageView.image = nil
        self.answerBT.isHidden = false
        self.checkImageView.removeFromSuperview()
        self.timerView.removeFromSuperview()
        self.explanationView.removeFromSuperview()
        self.answerView.removeFromSuperview()
        self.canvasView.frame.size.height = self.contentHeight
        
        self.canvasView.delegate = nil
        
        self.closeExplanation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("5다선지 : disappear")
    }
    
    deinit {
        toolPicker.setVisible(false, forFirstResponder: self.canvasView)
        toolPicker.removeObserver(self.canvasView)
        print("5다선지 deinit")
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated { return }
        
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

extension SingleWith5AnswerVC {
    func configureLoader() {
        self.view.addSubview(self.loader)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    
    func configureDoubleTapGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGesture.numberOfTapsRequired = 2
        self.canvasView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func doubleTapped() {
        UIView.animate(withDuration: 0.25) {
            self.canvasView.zoomScale = 1.0
        }
    }
    
    func configureSwipeGesture() {
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
    
    private func configureScrollView() {
        self.canvasView.minimumZoomScale = 0.5
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.delegate = self
    }
    
    func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
    
    func configureUI() {
        self.configureCheckButtons()
        self.configureStar()
        self.configureAnswer()
        self.configureExplanation()
    }
    
    func configureCheckButtons() {
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
    
    func createCheckImage(to index: Int) {
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
    
    func configureTimerView() {
        guard let time = self.viewModel?.problem?.time else { return }
        
        self.view.addSubview(self.timerView)
        self.timerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.timerView.centerYAnchor.constraint(equalTo: self.explanationBT.centerYAnchor),
            self.timerView.leadingAnchor.constraint(equalTo: self.explanationBT.trailingAnchor, constant: 15)
        ])
        
        self.timerView.configureTime(to: time)
    }
    
    func showResultImage() {
        guard let problem = self.viewModel?.problem else { return }
        if problem.terminated && problem.answer != nil {
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
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureAnswer() {
        self.answerBT.isUserInteractionEnabled = true
        self.answerBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.answer == nil {
            self.answerBT.isUserInteractionEnabled = false
            self.answerBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureExplanation() {
        self.explanationBT.isSelected = false
        self.explanationBT.isUserInteractionEnabled = true
        self.explanationBT.setTitleColor(UIColor(.deepMint), for: .normal)
        if self.viewModel?.problem?.explanationImage == nil {
            self.explanationBT.isUserInteractionEnabled = false
            self.explanationBT.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    func configureCanvasView() {
        self.canvasView.isOpaque = false
        self.canvasView.backgroundColor = .clear
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
        
        self.toolPicker.setVisible(true, forFirstResponder: canvasView)
        self.toolPicker.addObserver(canvasView)
    }
    
    func configureCanvasViewData() {
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
    
    func configureImageView() {
        guard let mainImage = self.image else { return }
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let warningImage = UIImage(.warning)
            self.imageView.image = warningImage
        }
    }
    
    private func showExplanation(to image: UIImage?) {
        self.explanationView.configureDelegate(to: self)
        self.view.addSubview(self.explanationView)
        
        self.explanationView.configureImage(to: image)
        self.setShadow(with: self.explanationView)
        
        self.reflectLayoutChange {
            self.layoutExplanation()
        }
        
        UIView.animate(withDuration: 0.2) {
            self.explanationView.alpha = 1
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        
        coordinator.animate { _ in
            UIView.performWithoutAnimation {
                if self.explanationBT.isSelected {
                    self.layoutExplanation()
                } else {
                    self.canvasView.frame.size.width = self.contentWidth
                    self.canvasView.frame.size.height = self.contentHeight
                    self.topViewTrailingConstraint.constant = 0
                }
                self.reflectLayoutChange(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
            }
        }
    }
    
    private func layoutExplanation() {
        let width = self.contentWidth
        let height = self.contentHeight
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
    
    private func reflectLayoutChange(of action: (() -> ())? = nil) {
        let previousCanvasSize = self.canvasView.frame.size
        let previousContentOffset = self.canvasView.contentOffset
        action?()
        self.reflectLayoutChange(previousCanvasSize: previousCanvasSize, previousContentOffset: previousContentOffset)
    }
    
    private func reflectLayoutChange(previousCanvasSize: CGSize, previousContentOffset: CGPoint) {
        let currentCanvasSize = self.canvasView.frame.size
        
        // 필기 크기 조절
        let scaleFactor: CGFloat = currentCanvasSize.width/previousCanvasSize.width
        let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        self.canvasView.drawing.transform(using: transform)
        
        // 이전 content 크기 및 contentOffset의 상대값 저장
        let previousContentSize = self.canvasView.contentSize
        
        // imageView와 canvasView 크기 조절
        let defaultImageWidth = self.canvasView.frame.width
        let image = self.image ?? UIImage(.warning)
        let defaultImageHeight = image.size.height*(defaultImageWidth/image.size.width)
        self.imageView.frame.size = CGSize(width: defaultImageWidth * canvasView.zoomScale, height: defaultImageHeight * canvasView.zoomScale)
        self.canvasView.contentSize = self.imageView.frame.size
        
        // 바뀐 크기에 맞게 이전과 같은 중심(혹은 좌상단?)를 가지도록 contentOffset 조절
        if previousContentSize.height != 0 && previousContentSize.width != 0 {
            /*
            // 중심에 맞춤
            let relativeContentXOffset = (previousContentOffset.x+previousCanvasSize.width/2)/previousContentSize.width
            let relativeContentYOffset = (previousContentOffset.y+previousCanvasSize.height/2)/previousContentSize.height
            
            let contentXOffset = self.canvasView.contentSize.width*relativeContentXOffset-currentCanvasSize.width/2
            let contentYOffset = self.canvasView.contentSize.height*relativeContentYOffset-currentCanvasSize.height/2
            */
            
            // 좌상단에 맞춤
            let relativeContentXOffset = previousContentOffset.x/previousContentSize.width
            let relativeContentYOffset = previousContentOffset.y/previousContentSize.height
            
            let contentXOffset = self.canvasView.contentSize.width*relativeContentXOffset
            let contentYOffset = self.canvasView.contentSize.height*relativeContentYOffset
            self.canvasView.contentOffset = .init(contentXOffset, contentYOffset)
            
            // 최하단에서 가로->세로 변경 시 여백이 보일 수 있는 점 수정
            if self.canvasView.contentOffset.y + self.canvasView.frame.height > self.canvasView.contentSize.height {
                self.canvasView.contentOffset.y = self.canvasView.contentSize.height - self.canvasView.frame.height
            }
        }
        
        // zoomScale이 1 미만일 시 content가 화면 중앙으로 오도록 조절
        let offsetX = max((self.canvasView.bounds.width - self.canvasView.contentSize.width) * 0.5, 0)
        let offsetY = max((self.canvasView.bounds.height - self.canvasView.contentSize.height) * 0.5, 0)
        self.canvasView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
}

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
        
        self.reflectLayoutChange {
            self.canvasView.frame.size.width = self.contentWidth
            self.canvasView.frame.size.height = self.contentHeight
        }
    }
}

extension SingleWith5AnswerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.reflectLayoutChange()
    }
}
