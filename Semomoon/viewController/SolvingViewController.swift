//
//  SolvingViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/08/20.
//

import UIKit
import PencilKit

class SolvingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet weak var sol_1: UIButton!
    @IBOutlet weak var sol_2: UIButton!
    @IBOutlet weak var sol_3: UIButton!
    @IBOutlet weak var sol_4: UIButton!
    @IBOutlet weak var sol_5: UIButton!
    @IBOutlet var bottomFrame: UIView!
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var hideButton: UIButton!
    
    @IBOutlet var star: UIButton!
    @IBOutlet var bookmark: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var problemImg: UIImageView!
    
    var buttons: [UIButton] = []
    // 임시적으로 문제내용 생성
    var problems: [String] = []
    var stars: [Bool] = []
    var bookmarks: [Bool] = []
    var isHide: Bool = false
    var problemNumber: Int = 0
    // 펜슬킷 캔버스
    let canvas = PKCanvasView(frame: .zero)
    var drawing = PKDrawing()
    var showPencilTool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [sol_1, sol_2, sol_3, sol_4, sol_5]
        setRadius()
        setBorderWidth()
        setBorderColor()
        setShadowFrame()
        // 임시 문제 생성
        for i in 1...30 {
            problems.append("\(i)")
            stars.append(false)
            bookmarks.append(false)
        }
        // 문제 확대축소 설정
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        // pencil kit 설정
        canvas.delegate = self
        canvas.drawing = drawing
        scrollView.addSubview(canvas)
        canvas.backgroundColor = .clear
        
        canvas.alwaysBounceVertical = true
        canvas.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: problemImg.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: problemImg.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: problemImg.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: problemImg.trailingAnchor),
        ])
        
        guard let window = parent?.view.window,
           let toolPicker = PKToolPicker.shared(for: window) else {
            return
        }
        
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        toolPicker.setVisible(true, forFirstResponder: canvas)
    }
    
    // 객관식 1~5 클릭 부분
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        for bt in buttons {
            if(bt.tag == num) {
                bt.backgroundColor = UIColor(named: "mint")
                bt.setTitleColor(UIColor.white, for: .normal)
            } else {
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
        }
    }
    // 문제 선택 가리기 버튼
    @IBAction func hide(_ sender: Any) {
        UIView.animate(withDuration: 0.15) {
            if(self.isHide) {
                self.bottomFrame.alpha = 1
                self.hideButton.setImage(UIImage(named: "down_icon"), for: .normal)
            } else {
                self.bottomFrame.alpha = 0
                self.hideButton.setImage(UIImage(named: "up_icon"), for: .normal)
            }
        }
        UIView.animate(withDuration: 0.3) {
            if(self.isHide) {
                self.hideButton.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                self.hideButton.transform = CGAffineTransform(translationX: 0, y: 78)
            }
        }
        view.layoutIfNeeded()
        isHide = !isHide
    }
    
    // star 클릭
    @IBAction func starClick(_ sender: Any) {
        stars[problemNumber] = !stars[problemNumber]
        setStar()
        collectionView.reloadData()
    }
    
    // bookmark 클릭
    @IBAction func bookmarkClick(_ sender: Any) {
        bookmarks[problemNumber] = !bookmarks[problemNumber]
        setBookmark()
    }
    
    // pencil toll 보이기 설정
    @IBAction func showPencilKit(_ sender: Any) {
        showPencilTool = !showPencilTool
    }
    
    
}

extension SolvingViewController {
    // 뷰의 라운드 설정 부분
    func setRadius() {
        solvInputFrame.layer.cornerRadius = 20
        for bt in buttons {
            bt.layer.cornerRadius = 20
        }
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        hideButton.layer.cornerRadius = 17.5
        
        star.layer.cornerRadius = 17.5
        star.clipsToBounds = true
        
        bookmark.layer.cornerRadius = 17.5
        bookmark.clipsToBounds = true
    }
    
    // 객관식 1~5의 두께 설정 부분
    func setBorderWidth() {
        for bt in buttons {
            bt.layer.borderWidth = 0.5
        }
    }
    
    // 객관식 1~5의 두께 색설정 부분
    func setBorderColor() {
        for bt in buttons {
            bt.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    // 객관식 입력창의 그림자 설정 부분
    func setShadowFrame() {
        solvInputFrame.layer.shadowColor = UIColor.lightGray.cgColor
        solvInputFrame.layer.shadowOpacity = 0.3
        solvInputFrame.layer.shadowOffset = CGSize(width: 3, height: 3)
        solvInputFrame.layer.shadowRadius = 5
        solvInputFrame.layer.masksToBounds = false
        
        star.layer.shadowColor = UIColor.lightGray.cgColor
        star.layer.shadowOpacity = 0.3
        star.layer.shadowOffset = CGSize(width: 2, height: 2)
        star.layer.shadowRadius = 3
        star.layer.masksToBounds = false
    }
    
    func setStar() {
        if(stars[problemNumber]) {
            star.setImage(UIImage(named: "star_fill_icon"), for: .normal)
        } else {
            star.setImage(UIImage(named: "star_icon"), for: .normal)
        }
        star.layer.cornerRadius = 17.5
        star.clipsToBounds = true
    }
    
    func setBookmark() {
        if(bookmarks[problemNumber]) {
            bookmark.setImage(UIImage(named: "bookmark_fill_icon"), for: .normal)
        } else {
            bookmark.setImage(UIImage(named: "bookmark_icon"), for: .normal)
        }
        bookmark.layer.cornerRadius = 17.5
        bookmark.clipsToBounds = true
    }
}

extension SolvingViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return problemImg
    }
}

extension SolvingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return problems.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "solveNumberCell", for: indexPath) as? solveNumberCell else { return UICollectionViewCell() }
        // 문제번호 설정
        cell.num.text = problems[indexPath.row]
        cell.outerFrame.layer.cornerRadius = 5
        // star 체크 여부
        if(stars[indexPath.row]) {
            cell.outerFrame.backgroundColor = UIColor(named: "yellow")
        } else {
            cell.outerFrame.backgroundColor = UIColor.white
        }
        // 크기 조절
        if(indexPath.row == problemNumber) {
            cell.outerFrame.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } else {
            cell.outerFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        problemNumber = indexPath.row
        setStar()
        setBookmark()
        collectionView.reloadData()
    }
    
}

class solveNumberCell: UICollectionViewCell {
    @IBOutlet var num: UILabel!
    @IBOutlet var outerFrame: UIView!
}
