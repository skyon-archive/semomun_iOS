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
    let categoryButtons: [String] = ["전체", "국어", "수학"]
    var previews: [Preview_Core] = []
    
    var categoryIndex: Int = 0
    let addImage = UIImage(named: "workbook_1")!
    let dumyImage = UIImage(named: "256img_2")!
    var queryDictionary: [String:NSPredicate] = [:]
    var currentFilter: String = "전체"
    
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var sideMenuShadowView: UIView!
    private var revealSideMenuOnTop: Bool = true
    private var isExpanded: Bool = false
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category.delegate = self
        preview.delegate = self
        addLongpressGesture(target: preview)
        
        queryDictionary["국어"] = NSPredicate(format: "subject = %@", "국어")
        queryDictionary["수학"] = NSPredicate(format: "subject = %@", "수학")
        queryDictionary["영어"] = NSPredicate(format: "subject = %@", "영어")
        
        fetchPreviews(filter: currentFilter)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPreviews(_:)), name: ShowDetailOfWorkbookViewController.refresh, object: nil)
        
        //MARK:- set userInfo button action
        let interaction = UIContextMenuInteraction(delegate: self)
        userInfo.addInteraction(interaction)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Shadow Background View
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        view.insertSubview(self.sideMenuShadowView, at: 4)
        
        // MARK:- setting sidebar ViewController
        self.sideMenuViewController = storyboard?.instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
        self.sideMenuViewController.defaultHighlightedCell = 0
        self.sideMenuViewController.delegate = self
        
        view.insertSubview(self.sideMenuViewController!.view, at: 5)
        addChild(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParent: self)
        
        // MARK:- setting sidebar autolayout
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false

        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
            self.sideMenuTrailingConstraint.isActive = true
        }
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    @IBAction func userInfo(_ sender: UIButton) {
        print("userInfo")
    }
    
    @objc func refreshPreviews(_ notification: Notification) {
        fetchPreviews(filter: "전체")
    }
    
    @IBAction func showSidebar(_ sender: Any) {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
}
// MARK:- sidebar viewController codes
extension MainViewController {
    
    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            // When targetPosition is 0, which means side menu is expanded, the shadow opacity is 0.6
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.3 : 0.0
        }
    }
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.3 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}

extension MainViewController {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // Show system share sheet
            }
            
            // Create an action for renaming
            let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { action in
                // Perform renaming
            }
            
            // Here we specify the "destructive" attribute to show that it’s destructive in nature
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
            }
            
            // Create and return a UIMenu with all of the actions as children
            return UIMenu(title: "", children: [share, rename, delete])
        }
    }
    
    func showViewController(identifier: String, isFull: Bool) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        if isFull {
            nextVC?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        }
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    func fetchPreviews(filter: String) {
        previews.removeAll()
        let fetchRequest: NSFetchRequest<Preview_Core> = Preview_Core.fetchRequest()
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
//        // MARK:- dumy image setting
//        previews.forEach {
//            $0.image = tempData
//        }
        self.preview.reloadData()
    }
    
    func deleteAlert(idx: Int) {
        let alert = UIAlertController(title: previews[idx].title,
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
        
        Network.downloadPages(sid: self.previews[index].sids[0]) { views in
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


extension MainViewController: SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int) {
        print(sideMenuViewController.testTitles[row])
        self.currentMode.setTitle(sideMenuViewController.testTitles[row], for: .normal)
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }
}
