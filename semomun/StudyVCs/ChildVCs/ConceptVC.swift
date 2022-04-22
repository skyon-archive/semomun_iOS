//
//  ConceptVC.swift
//  semomun
//
//  Created by Kang Minsang on 2022/01/21.
//

import UIKit
import PencilKit

class ConceptVC: UIViewController, PKToolPickerObserver, PKCanvasViewDelegate {
    static let identifier = "ConceptVC" // form == 0 && type == -1
    static let storyboardName = "Study"
    
    @IBOutlet weak var bookmarkBT: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    private var width: CGFloat!
    private var height: CGFloat!
    var image: UIImage!
    var viewModel: ConceptVM?
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = UIColor.gray
        return loader
    }()
    private lazy var timerView = ProblemTimerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Self.identifier) didLoad")
        
        self.configureLoader()
        self.configureSwipeGesture()
        self.addCoreDataAlertObserver()
        self.configureScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("개념 willAppear")
        
        self.scrollView.setContentOffset(.zero, animated: true)
        self.configureUI()
        self.configureCanvasView()
        self.scrollView.zoomScale = 1.0
        self.checkScoring()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("개념 didAppear")
        
        self.stopLoader()
        self.configureCanvasViewData()
        self.configureImageView()
        self.viewModel?.startTimeRecord()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("개념 willDisappear")
        
        CoreDataManager.saveCoreData()
        self.viewModel?.endTimeRecord()
        self.imageView.image = nil
        self.timerView.removeFromSuperview()
        self.scrollViewBottomConstraint.constant = 0
        self.canvasView.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("개념 : disappear")
    }
    
    deinit {
        guard let canvasView = self.canvasView else { return }
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        toolPicker.removeObserver(canvasView)
        print("개념 deinit")
    }
    
    
    @IBAction func toggleBookmark(_ sender: Any) {
        self.bookmarkBT.isSelected.toggle()
        let status = self.bookmarkBT.isSelected
        self.viewModel?.updateStar(to: status)
    }
}

extension ConceptVC {
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
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.delegate = self
    }
    
    func stopLoader() {
        self.loader.isHidden = true
        self.loader.stopAnimating()
    }
    
    func configureUI() {
        self.configureStar()
        self.configureTimerView()
    }
    
    func configureTimerView() {
        guard let problem = self.viewModel?.problem else { return }
        
        if problem.terminated {
            self.view.addSubview(self.timerView)
            self.timerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.timerView.centerYAnchor.constraint(equalTo: self.bookmarkBT.centerYAnchor),
                self.timerView.leadingAnchor.constraint(equalTo: self.bookmarkBT.trailingAnchor, constant: 15)
            ])
            
            self.timerView.configureTime(to: problem.time)
        }
    }
    
    func configureStar() {
        self.bookmarkBT.isSelected = self.viewModel?.problem?.star ?? false
    }
    
    func configureCanvasView() {
        self.canvasView.isOpaque = false
        self.canvasView.backgroundColor = .clear
        self.canvasView.becomeFirstResponder()
        self.canvasView.drawingPolicy = .pencilOnly
        
        self.canvasView.subviews[0].addSubview(imageView)
        self.canvasView.subviews[0].sendSubviewToBack(imageView)
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
        self.width = canvasView.frame.width
        guard let mainImage = self.image else { return }
        self.height = mainImage.size.height*(width/mainImage.size.width)
        
        if mainImage.size.width > 0 && mainImage.size.height > 0 {
            self.imageView.image = mainImage
        } else {
            let worningImage = UIImage(.warning)
            self.imageView.image = worningImage
            self.height = worningImage.size.height*(width/worningImage.size.width)
        }
        
        self.imageView.clipsToBounds = true
        self.imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.imageHeight.constant = height
        self.canvasView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.canvasHeight.constant = height
    }
    
    private func checkScoring() {
        guard let problem = self.viewModel?.problem else { return }
        let terminated = problem.terminated
              
        if terminated == false {
            self.viewModel?.delegate?.addScoring(pid: Int(problem.pid))
        }
    }
}

extension ConceptVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let data = self.canvasView.drawing.dataRepresentation()
        self.viewModel?.updatePencilData(to: data)
    }
}

extension ConceptVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
