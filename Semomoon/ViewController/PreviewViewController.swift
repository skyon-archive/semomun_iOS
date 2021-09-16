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
    var previews: [Preview_Core] = []
    var previews2: [Preview_Core] = []
    var previews_core: [Preview_Core] = []
    
    var categoryIndex: Int = 0
    let addImage = UIImage(named: "addPreview")!
    let dumyImage = UIImage(named: "256img_2")!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category.delegate = self
        preview.delegate = self
        
        appendAddPreviewIcon()
        let tempData = dumyImage.jpegData(compressionQuality: 1)!
        
        fetchPreviews()
        print(previews_core.count)
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        print("userInfo")
    }
}

extension PreviewViewController {
    func appendAddPreviewIcon() {
        let addIcon = Preview_Core()
        addIcon.preview2core(wid: -1, title: "", image: nil)
        addIcon.setValue(addImage.jpegData(compressionQuality: 1)!, forKey: "image")
        previews.append(addIcon)
        previews2.append(addIcon)
    }
    
    func showViewController(identifier: String, isFull: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        if isFull {
            nextVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        }
//        nextVC?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    func fetchPreviews() {
        let tempData = dumyImage.jpegData(compressionQuality: 1)!
        do {
            self.previews_core = try context.fetch(Preview_Core.fetchRequest())
        } catch let error {
            print(error.localizedDescription)
        }
        // only because there is no image data saved in Core Data
        previews_core.forEach {
            $0.image = tempData
        }
        DispatchQueue.main.async {
            self.preview.reloadData()
        }
    }
}

extension PreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == category {
            return categoryButtons.count
        } else {
            return previews_core.count
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
            // 문제번호 설정
            print(previews_core[indexPath.row])
            guard let imageData = previews_core[indexPath.row].image else { return UICollectionViewCell() }
            cell.imageView.image = UIImage(data: imageData)
            cell.title.text = previews_core[indexPath.row].title
            
            return cell
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == category {
            categoryIndex = indexPath.row
            if(categoryIndex != 0) {
                previews_core = previews2
            } else {
                previews_core = previews
            }
            category.reloadData()
            preview.reloadData()
        } else {
            let wid = previews_core[indexPath.row].wid
            print(wid)
            switch wid {
            case -1:
                showViewController(identifier: "SelectWorkbookViewController", isFull: false)
            default:
                //여기서 section 선택하는 화면으로 넘어가야 하나, 일단은 바로 학습공간으로
                if(wid == 0) {
                    showViewController(identifier: "SolvingViewController", isFull: true)
                }
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
