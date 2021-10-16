//
//  PreviewViewController.swift
//  PreviewViewController
//
//  Created by qwer on 2021/09/11.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UIContextMenuInteractionDelegate {
    @IBOutlet weak var currentMode: UIButton!
    @IBOutlet weak var category: UICollectionView!
    @IBOutlet weak var preview: UICollectionView!
    @IBOutlet weak var userInfo: UIButton!
    
    //임시적인 데이터
    let addImage = UIImage(named: "workbook_1")!
    let dumyImage = UIImage(named: "256img_2")!
    
    private var previewManager: PreviewManager!
    
    // Sidebar ViewController Properties
    var sideMenuViewController: SideMenuViewController!
    var sideMenuTrailingConstraint: NSLayoutConstraint!
    var sideMenuShadowView: UIView!
    var revealSideMenuOnTop: Bool = true
    var isExpanded: Bool = false
    var sideMenuRevealWidth: CGFloat = 260
    let paddingForRotation: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureManager()
        self.configureCollectionView()
        self.configureObserve()
        self.previewManager.fetchPreviews()
        self.configureUserInfoAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureSideBarViewController()
    }
    
    @IBAction func showSidebar(_ sender: Any) {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        print("userInfo")
    }
}

// MARK: - Configure MainViewController
extension MainViewController {
    func configureManager() {
        self.previewManager = PreviewManager(delegate: self)
    }
    
    func configureCollectionView() {
        self.category.delegate = self
        self.preview.delegate = self
        self.addLongpressGesture(target: self.preview)
    }
    
    func configureObserve() {
        NotificationCenter.default.addObserver(forName: ShowDetailOfWorkbookViewController.refresh, object: nil, queue: .main) { _ in
            self.previewManager.fetchPreviews()
        }
    }
    
    func configureUserInfoAction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        userInfo.addInteraction(interaction)
    }
}

// MARK: - CollectionView LongPress Action
extension MainViewController {
    func addLongpressGesture(target: UIView) {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        target.addGestureRecognizer(longPressRecognizer)
        longPressRecognizer.minimumPressDuration = 0.7
    }
    
    @objc func longPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: preview)
            guard let indexPath = preview.indexPathForItem(at: touchPoint) else { return }
            if indexPath.row-1 >= 0 {
                deleteAlert(idx: indexPath.row-1)
            }
        }
    }
}

// MARK: - Logic
extension MainViewController {
    func showViewController(identifier: String, isFull: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        if isFull {
            nextVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        }
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    func delete(object: NSManagedObject) {
        CoreDataManager.shared.context.delete(object)
        do {
            CoreDataManager.shared.appDelegate.saveContext()
        } catch let error {
            print(error.localizedDescription)
            CoreDataManager.shared.context.rollback()
        }
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
                let imageData = image.pngData()!
                cell.imageView.image = UIImage(data: imageData)
                cell.title.text = " "
            } else {
                print(previews[indexPath.row-1])
                guard let imageData = previews[indexPath.row-1].image else { return UICollectionViewCell() }
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: imageData)
                }
                cell.title.text = previews[indexPath.row-1].title
            }
            return cell
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - category
        if collectionView == category {
            categoryIndex = indexPath.item
            currentFilter = categoryButtons[indexPath.item]
            fetchPreviews(filter: currentFilter)
            category.reloadData()
            return
        }
        
        // MARK: - preview cell: searchPreview
        if indexPath.item == 0 {
            showViewController(identifier: "SearchWorkbookViewController", isFull: false)
            return
        }
        
        // MARK: - preview cell: selectSectionView
        let index = indexPath.item - 1
        if showSelectSectionView(index: index) {
            print("goToSelectSectionViewController")
            //move to selectSectionViewController
            return
        }
        
        if self.previews[index].sids.isEmpty { return }
        
        // MARK: - preview cell: get sectionData
        let sid = self.previews[index].sids[0]
        
        NetworkUsecase.downloadPages(sid: sid) { views in
            print("NETWORK RESULT")
            print(views)
        }
        
//        if let section = sectionOfCoreData(sid: sid) {
//            print("section of CoreData")
//            //get section from CoreData
//            print(section)
//            showViewController(identifier: "SolvingViewController", isFull: true) //해당 section 문제 풀이
//        } else {
//            print("views of DB")
//            //download views from DB
//            Network.downloadSection(sid: self.previews[index].sids[0]) { views in
//                print(views)
//            }
//            //convert views to section, view to CoreData
//
//            //then, showSolvingViewController
//            showViewController(identifier: "SolvingViewController", isFull: true) //해당 section 문제 풀이
//        }
    }
    
    func showSelectSectionView(index: Int) -> Bool {
        return self.previews[index].sids.count > 1
    }
    
    func sectionOfCoreData(sid: Int) -> Section_Core? {
        var sections: [Section_Core] = []
        let fetchRequest: NSFetchRequest<Section_Core> = Section_Core.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sid = %@", sid)
        
        do {
            sections = try CoreDataManager.shared.context.fetch(fetchRequest)
            return !sections.isEmpty ? sections[0] : nil
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
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

// MARK: - Protocol: SideMenuViewControllerDelegate
extension MainViewController: SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int) {
        print(sideMenuViewController.testTitles[row])
        self.currentMode.setTitle(sideMenuViewController.testTitles[row], for: .normal)
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }
}

// MARK: - Protocol: PreviewDatasource
extension MainViewController: PreviewDatasource {
    func reloadData() {
        self.preview.reloadData()
    }
    
    func deleteAlert(title: String?) {
        let alert = UIAlertController(title: title,
            message: "삭제하시겠습니까?",
            preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        let delete = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.delete(object: self.previews[idx])
            self.fetchPreviews(filter: self.currentFilter)
        })
        
        alert.addAction(cancle)
        alert.addAction(delete)
        present(alert,animated: true,completion: nil)
    }
}
