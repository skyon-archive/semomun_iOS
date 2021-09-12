//
//  PreviewViewController.swift
//  PreviewViewController
//
//  Created by qwer on 2021/09/11.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var category: UICollectionView!
    @IBOutlet weak var preview: UICollectionView!
    //임시적인 데이터
    let categoryButtons: [String] = ["최근", "국어", "수학"]
    var currentPreives: [Preview_Real] = []
    var previews: [Preview_Real] = []
    var previews2: [Preview_Real] = []
    var categoryIndex: Int = 0
    let addImage = UIImage(named: "addPreview")!
    let dumyImage = UIImage(named: "256img_2")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category.delegate = self
        preview.delegate = self
        
        appendAddPreviewIcon()
        
        previews.append(Preview_Real(wid: 0, title: "고3 2021년 7월 화법과 작문", image: 0))
        previews[1].setDumyData(data: dumyImage.jpegData(compressionQuality: 1)!)
        previews.append(Preview_Real(wid: 1, title: "고3 2021년 7월 확률과 통계", image: 1))
        previews[2].setDumyData(data: dumyImage.jpegData(compressionQuality: 1)!)
        
        previews2.append(Preview_Real(wid: 2, title: "고3 2021년 7월 영어", image: 2))
        previews2[1].setDumyData(data: dumyImage.jpegData(compressionQuality: 1)!)
        
        currentPreives = previews
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        print("userInfo")
    }
}

extension PreviewViewController {
    func appendAddPreviewIcon() {
        let addIcon = Preview_Real(wid: -1, title: "", image: nil)
        addIcon.setDumyData(data: addImage.jpegData(compressionQuality: 1)!)
        previews.append(addIcon)
        previews2.append(addIcon)
    }
    
    func showSelectWorkbookVC() {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectWorkbookViewController")
//        nextVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
//        nextVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(nextVC!, animated: true, completion: nil)
    }
}

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == category {
            return categoryButtons.count
        } else {
            return currentPreives.count
        }
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == category {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            print("\(indexPath.row)")
            // 문제번호 설정
            cell.category.text = categoryButtons[indexPath.row]
            cell.underLine.alpha = indexPath.row == categoryIndex ? 1 : 0
            cell.setRadiusOfUnderLine()
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            // 문제번호 설정
            guard let imageData = currentPreives[indexPath.row].imageData else { return UICollectionViewCell() }
            cell.imageView.image = UIImage(data: imageData)
            cell.title.text = currentPreives[indexPath.row].preview.title
            
            return cell
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == category {
            categoryIndex = indexPath.row
            if(categoryIndex != 0) {
                currentPreives = previews2
            } else {
                currentPreives = previews
            }
            category.reloadData()
            preview.reloadData()
        } else {
            let wid = currentPreives[indexPath.row].preview.wid
            switch wid {
            case -1:
                showSelectWorkbookVC()
            default:
                print(wid)
            }
        }
    }
    
}

extension PreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == preview {
            let width = (preview.frame.width)/4
            let height = preview.frame.height/3
            
            return CGSize(width: width, height: height)
        }
        else {
            return CGSize(width: 60, height: 40)
        }
    }
}

class CategoryCell: UICollectionViewCell {
    @IBOutlet var category: UILabel!
    @IBOutlet var underLine: UIView!
    
    func setRadiusOfUnderLine() {
        self.underLine.layer.cornerRadius = 1.5
    }
}


class PreviewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
}
