//
//  SolvingViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/08/20.
//

import UIKit
import PencilKit

protocol SendData {
    func sendData(data: String)
}

class SolvingViewController: UIViewController {
    static let identifier = "SolvingViewController"
    
    @IBOutlet var bottomFrame: UIView!
    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var hideButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var childView: UIView!
    
    var vc1: test_1ViewController!
    var vc2: test_2ViewController!
    var vc3: test_3ViewController!
    
    // 임시적으로 문제내용 생성
    var problems: [String] = []
    var stars: [Bool] = []
    var bookmarks: [Bool] = []
    var isHide: Bool = false
    var problemNumber: Int = 0
    var pageDatas: PageDatas!
    var currentVC: UIViewController!
    
    var sectionCore: Section_Core! //저장되어 있는 섹션 정보
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadius()
        pageDatas = PageDatas()
        
        // 임시 문제 생성
        for i in 0..<pageDatas.count {
            problems.append("\(i)")
            stars.append(false)
            bookmarks.append(false)
        }
        
        vc1 = self.storyboard?.instantiateViewController(withIdentifier: "test_1ViewController") as? test_1ViewController
        vc2 = self.storyboard?.instantiateViewController(withIdentifier: "test_2ViewController") as? test_2ViewController
        vc3 = self.storyboard?.instantiateViewController(withIdentifier: "test_3ViewController") as? test_3ViewController
        self.addChild(vc1)
        self.addChild(vc2)
        self.addChild(vc3)
        
        currentVC = whatVC(index: 0)
        currentVC.view.frame = self.childView.bounds
        self.childView.addSubview(currentVC.view)
        self.view.addSubview(hideButton)
        
        print(self.sectionCore)
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
    
    @IBAction func back(_ sender: Any) {
        //저장되는 알고리즘이 필요, 일단은 뒤로가기
        self.dismiss(animated: true, completion: nil)
    }
}

extension SolvingViewController {
    // 뷰의 라운드 설정 부분
    func setRadius() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        hideButton.layer.cornerRadius = 17.5
    }
    
    func chengeView(num: Int) {
        for child in self.childView.subviews { child.removeFromSuperview() }
        currentVC.willMove(toParent: nil) // 제거되기 직전에 호출
        currentVC.removeFromParent() // parentVC로 부터 관계 삭제
        currentVC.view.removeFromSuperview() // parentVC.view.addsubView()와 반대 기능
        
        let vc = whatVC(index: num)
        vc.view.frame = self.childView.bounds
        self.childView.addSubview(vc.view)
        self.view.addSubview(hideButton)
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
        chengeView(num: indexPath.row)
        collectionView.reloadData()
    }
}

class solveNumberCell: UICollectionViewCell {
    @IBOutlet var num: UILabel!
    @IBOutlet var outerFrame: UIView!
}

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size))}
        print("화면 배율: \(UIScreen.main.scale)")// 배수
        print("origin: \(self), resize: \(renderImage)")
        //    printDataSize(renderImage)
        return renderImage
    }


}


extension SolvingViewController {
    
    func whatVC(index: Int) -> UIViewController {
        let page = pageDatas.pages[index]
        let vc: UIViewController
        switch(page.type) {
        case .ontToFive:
            vc = vc1
            vc1.image = page.mainImage
        case .string:
            vc = vc2
            vc2.image = page.mainImage
        case .multiple:
             vc = vc3
            vc3.mainImage = page.mainImage
            vc3.subImages = page.subImages
        }
        return vc
    }
}
