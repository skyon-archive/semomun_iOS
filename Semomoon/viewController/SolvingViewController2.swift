//
//  SolvingViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/08/20.
//

import UIKit
import PencilKit

class SolvingViewController2: UIViewController {

    @IBOutlet var bottomFrame: UIView!
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var hideButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var childView: UIView!
    
    var vc1: UIViewController = test_1ViewController()
    var vc2: UIViewController = test_2ViewController()
    var vc3: UIViewController = test_3ViewController()
    
    // 임시적으로 문제내용 생성
    var problems: [String] = []
    var stars: [Bool] = []
    var bookmarks: [Bool] = []
    var isHide: Bool = false
    var problemNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadius()
        // 임시 문제 생성
        for i in 1...30 {
            problems.append("\(i)")
            stars.append(false)
            bookmarks.append(false)
        }
        problems.append("개")
        problems.append("유")
        stars.append(false)
        bookmarks.append(false)
        stars.append(false)
        bookmarks.append(false)
        
        vc1 = self.storyboard?.instantiateViewController(withIdentifier: "test_1ViewController") ?? test_1ViewController()
        vc2 = self.storyboard?.instantiateViewController(withIdentifier: "test_2ViewController") ?? test_2ViewController()
        vc3 = self.storyboard?.instantiateViewController(withIdentifier: "test_3ViewController") ?? test_3ViewController()
        self.addChild(vc1)
        self.addChild(vc2)
        self.addChild(vc3)
        
        vc1.view.frame = self.childView.bounds
        self.childView.addSubview(vc1.view)
        self.view.addSubview(hideButton)
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
    
}

extension SolvingViewController2 {
    // 뷰의 라운드 설정 부분
    func setRadius() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        hideButton.layer.cornerRadius = 17.5
    }
    
    func chengeView(num: Int) {
        for child in self.childView.subviews { child.removeFromSuperview() }
        switch(num%3) {
        case 0:
            vc1.view.frame = self.childView.bounds
            self.childView.addSubview(vc1.view)
        case 1:
            vc2.view.frame = self.childView.bounds
            self.childView.addSubview(vc2.view)
        case 2:
            vc3.view.frame = self.childView.bounds
            self.childView.addSubview(vc3.view)
        default:
            break
        }
        self.view.addSubview(hideButton)
    }
}

extension SolvingViewController2: UICollectionViewDelegate, UICollectionViewDataSource {
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
        chengeView(num: indexPath.row)
        collectionView.reloadData()
    }
    
}

//class solveNumberCell: UICollectionViewCell {
//    @IBOutlet var num: UILabel!
//    @IBOutlet var outerFrame: UIView!
//}

//extension UIImage {
//    func resize(newWidth: CGFloat) -> UIImage {
//        let scale = newWidth / self.size.width
//        let newHeight = self.size.height * scale
//        let size = CGSize(width: newWidth, height: newHeight)s
//        let render = UIGraphicsImageRenderer(size: size)
//        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size))}
//        print("화면 배율: \(UIScreen.main.scale)")// 배수
//        print("origin: \(self), resize: \(renderImage)")
//        //    printDataSize(renderImage)
//        return renderImage
//    }
//
//
//}
