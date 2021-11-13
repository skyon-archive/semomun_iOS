//
//  SolvingViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/08/20.
//

import UIKit
import PencilKit

protocol PageDelegate: AnyObject {
    func updateStar(btName: String, to: Bool)
    func nextPage()
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
    var singleWith4Answer: SingleWith4Answer!
    var multipleWithNoAnswer: MultipleWithNoAnswer!
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    // 임시적으로 문제내용 생성
    var problems: [String] = []
    var stars: [Bool] = []
    var bookmarks: [Bool] = []
    var isHide: Bool = false
    var problemNumber: Int = 0
    var currentVC: UIViewController!
    
    var manager: SectionManager!
    var sectionCore: Section_Core? //저장되어 있는 섹션 정보
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        
        singleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: SingleWith5Answer.identifier) as? SingleWith5Answer
        singleWithTextAnswer = self.storyboard?.instantiateViewController(withIdentifier: SingleWithTextAnswer.identifier) as? SingleWithTextAnswer
        multipleWith5Answer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWith5Answer.identifier) as? MultipleWith5Answer
        singleWith4Answer = self.storyboard?.instantiateViewController(withIdentifier: SingleWith4Answer.identifier) as? SingleWith4Answer
        multipleWithNoAnswer = self.storyboard?.instantiateViewController(withIdentifier: MultipleWithNoAnswer.identifier) as? MultipleWithNoAnswer
        
        self.addChild(singleWith5Answer)
        self.addChild(singleWithTextAnswer)
        self.addChild(multipleWith5Answer)
        
        self.configureManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.subviews.forEach { $0.removeFromSuperview() }
        self.singleWith5Answer = nil
        self.singleWithTextAnswer = nil
        self.multipleWith5Answer = nil
    }
    
    @IBAction func back(_ sender: Any) {
        self.manager.stopTimer()
    }
    
    @IBAction func finish(_ sender: Any) {
        // DB에 Post 하는 알고리즘이 필요
    }
    
}

// MARK: - Configure
extension SolvingViewController {
    func configureUI() {
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func configureManager() {
        self.manager = SectionManager(delegate: self, section: self.sectionCore)
    }
}

extension SolvingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager.count
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProblemNameCell.identifier, for: indexPath) as? ProblemNameCell else { return UICollectionViewCell() }
        // 문제번호 설정
        cell.num.text = self.manager.buttonTitle(at: indexPath.item)
        cell.outerFrame.layer.cornerRadius = 5
        // star 체크 여부
        if self.manager.showStarColor(at: indexPath.item) {
            cell.outerFrame.backgroundColor = UIColor(named: "yellow")
        } else {
            cell.outerFrame.backgroundColor = UIColor.white
        }
        // 크기 조절
        if indexPath.item == self.manager.currentIndex {
            cell.outerFrame.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } else {
            cell.outerFrame.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        return cell
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.manager.changePage(at: indexPath.item)
    }
}

extension SolvingViewController {
    func showVC() {
        currentVC.view.frame = self.solvingFrameView.bounds
        self.solvingFrameView.addSubview(currentVC.view)
    }
    
    func getImage(data: Data?) -> UIImage {
        guard let data = data else { return UIImage() }
        return UIImage(data: data) ?? UIImage()
    }
    
    func getImages(problems: [Problem_Core]) -> [UIImage] {
        var images: [UIImage] = []
        problems.forEach {
            guard let data = $0.contentImage else {
                images.append(UIImage())
                return
            }
            images.append(getImage(data: data))
        }
        return images
    }
}

extension SolvingViewController: LayoutDelegate {
    func showTitle(title: String) {
        self.sectionTitle.text = title
    }
    
    func showTime(time: Int64) {
        self.sectionTime.text = time.toTimeString()
    }
    
    func changeVC(pageData: PageData) {
        if let _ = currentVC {
            for child in self.solvingFrameView.subviews { child.removeFromSuperview() }
            currentVC.willMove(toParent: nil) // 제거되기 직전에 호출
            currentVC.removeFromParent() // parentVC로 부터 관계 삭제
            currentVC.view.removeFromSuperview() // parentVC.view.addsubView()와 반대 기능
        }
        
        switch pageData.layoutType {
        case SingleWith5Answer.identifier:
            self.currentVC = singleWith5Answer
            singleWith5Answer.delegate = self
            singleWith5Answer.image = getImage(data: pageData.problems[0].contentImage)
            singleWith5Answer.pageData = pageData
            
        case SingleWithTextAnswer.identifier:
            self.currentVC = singleWithTextAnswer
            singleWithTextAnswer.delegate = self
            singleWithTextAnswer.image = getImage(data: pageData.problems[0].contentImage)
            singleWithTextAnswer.pageData = pageData
            
        case MultipleWith5Answer.identifier:
            self.currentVC = multipleWith5Answer
            multipleWith5Answer.delegate = self
            multipleWith5Answer.toolPicker = self.toolPicker
            multipleWith5Answer.mainImage = getImage(data: pageData.pageData.materialImage)
            multipleWith5Answer.subImages = getImages(problems: pageData.problems)
            multipleWith5Answer.pageData = pageData
            
        case SingleWith4Answer.identifier:
            self.currentVC = singleWith4Answer
            singleWith4Answer.delegate = self
            singleWith4Answer.image = getImage(data: pageData.problems[0].contentImage)
            singleWith4Answer.pageData = pageData
            
        case MultipleWithNoAnswer.identifier:
            self.currentVC = multipleWithNoAnswer
            multipleWithNoAnswer.delegate = self
            multipleWithNoAnswer.mainImage = getImage(data: pageData.pageData.materialImage)
            multipleWithNoAnswer.subImages = getImages(problems: pageData.problems)
            multipleWithNoAnswer.pageData = pageData
            
        default:
            break
        }
        self.showVC()
    }
    
    func reloadButtons() {
        self.collectionView.reloadData()
    }
    
    func showAlert(text: String) {
        self.showAlertWithOK(title: text, text: "")
    }
    
    func saveComplete() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SolvingViewController: PageDelegate {
    func updateStar(btName: String, to: Bool) {
        self.manager.updateStar(title: btName, to: to)
    }
    
    func nextPage() {
        self.manager.changeNextPage()
    }
}
