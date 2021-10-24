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
    
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var sectionTime: UILabel!
    @IBOutlet weak var bottomFrame: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var solvingFrameView: UIView!
    
    var singleWith5Answer: SingleWith5Answer!
    var singleWithTextAnswer: SingleWithTextAnswer!
    var multipleWith5Answer: MultipleWith5Answer!
    
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
        self.configureUI()
        pageDatas = PageDatas()
        
        // 임시 문제 생성
        for i in 0..<pageDatas.count {
            problems.append("\(i)")
            stars.append(false)
            bookmarks.append(false)
        }
        
        singleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: SingleWith5Answer.identifier) as? SingleWith5Answer
        singleWithTextAnswer = self.storyboard?.instantiateViewController(withIdentifier: SingleWithTextAnswer.identifier) as? SingleWithTextAnswer
        multipleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWith5Answer.identifier) as? MultipleWith5Answer
        self.addChild(singleWith5Answer)
        self.addChild(singleWithTextAnswer)
        self.addChild(multipleWith5Answer)
        
        currentVC = whatVC(index: 0)
        currentVC.view.frame = self.solvingFrameView.bounds
        self.solvingFrameView.addSubview(currentVC.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.subviews.forEach { $0.removeFromSuperview() }
        self.singleWith5Answer = nil
        self.singleWithTextAnswer = nil
        self.multipleWith5Answer = nil
    }
    
    @IBAction func back(_ sender: Any) {
        //저장되는 알고리즘이 필요, 일단은 뒤로가기
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finish(_ sender: Any) {
        // DB에 Post 하는 알고리즘이 필요
    }
    
}

extension SolvingViewController {
    // 뷰의 라운드 설정 부분
    func configureUI() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func chengeView(num: Int) {
        for child in self.solvingFrameView.subviews { child.removeFromSuperview() }
        currentVC.willMove(toParent: nil) // 제거되기 직전에 호출
        currentVC.removeFromParent() // parentVC로 부터 관계 삭제
        currentVC.view.removeFromSuperview() // parentVC.view.addsubView()와 반대 기능
        
        let vc = whatVC(index: num)
        vc.view.frame = self.solvingFrameView.bounds
        self.solvingFrameView.addSubview(vc.view)
    }
}

extension SolvingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return problems.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemNameCell.identifier, for: indexPath) as? ProblemNameCell else { return UICollectionViewCell() }
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
            vc = singleWith5Answer
            singleWith5Answer.image = page.mainImage
        case .string:
            vc = singleWithTextAnswer
            singleWithTextAnswer.image = page.mainImage
        case .multiple:
             vc = multipleWith5Answer
            multipleWith5Answer.mainImage = page.mainImage
            multipleWith5Answer.subImages = page.subImages
        }
        return vc
    }
}
