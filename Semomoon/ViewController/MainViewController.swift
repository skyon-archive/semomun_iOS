//
//  PreviewViewController.swift
//  PreviewViewController
//
//  Created by qwer on 2021/09/11.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var category: UICollectionView!
    @IBOutlet weak var preview: UICollectionView!
    //임시적인 데이터
    let categoryButtons: [String] = ["전체", "국어", "수학"]
    var previews: [Preview_Core] = []
    
    var categoryIndex: Int = 0
    let addImage = UIImage(named: "addPreview")!
    let dumyImage = UIImage(named: "256img_2")!
    var queryDictionary: [String:NSPredicate] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category.delegate = self
        preview.delegate = self
        
        queryDictionary["국어"] = NSPredicate(format: "subject = %@", "국어")
        queryDictionary["수학"] = NSPredicate(format: "subject = %@", "수학")
        queryDictionary["영어"] = NSPredicate(format: "subject = %@", "영어")
        
        fetchPreviews(filter: "전체")
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        print("userInfo")
    }
}

extension MainViewController {
    func showViewController(identifier: String, isFull: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        if isFull {
            nextVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        }
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    func fetchPreviews(filter: String) {
        previews.removeAll()
        let fetchRequest = Preview_Core.fetchRequest()
        if filter != "전체" {
            let filter = queryDictionary[filter]
            fetchRequest.predicate = filter
        }
        let tempData = dumyImage.jpegData(compressionQuality: 1)!
        do {
            previews = try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        // MARK:- dumy image setting
        previews.forEach {
            $0.image = tempData
        }
        self.preview.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == category {
            return categoryButtons.count
        } else {
            return previews.count+1
        }
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == category {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            // 문제번호 설정
            cell.category.text = categoryButtons[indexPath.row]
            cell.underLine.alpha = indexPath.row == categoryIndex ? 1 : 0
            cell.setRadiusOfUnderLine()
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            // Preview cell 설정
            if indexPath.row == 0 {
                let image = UIImage(named: "addPreview")!
                let imageData = image.jpegData(compressionQuality: 1)!
                cell.imageView.image = UIImage(data: imageData)
                cell.title.text = " "
            } else {
                guard let imageData = previews[indexPath.row-1].image else { return UICollectionViewCell() }
                cell.imageView.image = UIImage(data: imageData)
                cell.title.text = previews[indexPath.row-1].title
            }
            return cell
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == category {
            categoryIndex = indexPath.row
            fetchPreviews(filter: categoryButtons[indexPath.row])
            category.reloadData()
            preview.reloadData()
        } else {
            if indexPath.row == 0 {
                showViewController(identifier: "SearchWorkbookViewController", isFull: false)
            }
            else {
                print(previews[indexPath.row-1].wid)
                showViewController(identifier: "SolvingViewController", isFull: true) //해당 wid 문제 풀이
            }
        }
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
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
