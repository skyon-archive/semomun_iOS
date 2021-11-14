//
//  PreviewViewController.swift
//  PreviewViewController
//
//  Created by qwer on 2021/09/11.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UIContextMenuInteractionDelegate {
    static let identifier = "MainViewController"
    
    @IBOutlet weak var currentMode: UIButton!
    @IBOutlet weak var category: UICollectionView!
    @IBOutlet weak var preview: UICollectionView!
    @IBOutlet weak var userInfo: UIButton!
    
    //임시적인 데이터
    var addImageData: Data!
    
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
        self.configureAddImage()
        self.configureManager()
        self.configureCollectionView()
        self.configureObserve()
        self.previewManager.fetchPreviews()
        self.configureUserInfoAction()
        
//        self.createMockCoreDataForMath()
//        self.createMockCoreDataForKorean()
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
    
    func configureAddImage() {
        guard let addImage = UIImage(named: "addButton") else {
            print("Error: addImage not corrent")
            return
        }
        addImageData = addImage.pngData()
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
            if indexPath.item-1 >= 0 {
                self.previewManager.deletePreview(at: indexPath.item-1)
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
    
    func showSolvingVC(section: Section_Core) {
        guard let solvingVC = self.storyboard?.instantiateViewController(withIdentifier: SolvingViewController.identifier) as? SolvingViewController else { return }
        solvingVC.modalPresentationStyle = .fullScreen
        solvingVC.sectionCore = section
        self.present(solvingVC, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 문제수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == category {
            return self.previewManager.categoryCount
        } else {
            return self.previewManager.previewCount+1
        }
    }
    
    // 문제버튼 생성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == category {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            // 문제번호 설정
            cell.category.text = self.previewManager.category(at: indexPath.item)
            cell.underLine.alpha = indexPath.item == self.previewManager.categoryIndex ? 1 : 0
            cell.setRadiusOfUnderLine()
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath) as? PreviewCell else { return UICollectionViewCell() }
            // Preview cell 설정
            if indexPath.item == 0 {
                cell.imageView.image = UIImage(data: addImageData)
                cell.title.text = " "
                cell.disappearShadow()
                return cell
            } else {
                let preview = self.previewManager.preview(at: indexPath.item-1)
                cell.title.text = preview.title
                guard let imageData = preview.image else { return cell }
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: imageData)
                }
                cell.showShadow()
                return cell
            }
        }
    }
    
    // 문제 버튼 클릭시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // MARK: - category
        if collectionView == category {
            self.previewManager.updateCategory(idx: indexPath.item)
            return
        }
        
        // MARK: - preview cell: searchPreview
        if indexPath.item == 0 {
            showViewController(identifier: SearchWorkbookViewController.identifier, isFull: false)
            return
        }
        
        // MARK: - preview cell: selectSectionView
        let index = indexPath.item-1
        if self.previewManager.showSelectSectionView(index: index) {
            print("goToSelectSectionViewController")
            return
        }
        
        let preview = self.previewManager.preview(at: index)
        guard let sid = preview.sids.first else { return }
        
        // MARK: - Section: form CoreData
        if let section = CoreUsecase.sectionOfCoreData(sid: sid) {
            self.showSolvingVC(section: section)
            return
        }
        
        // MARK: - Section: Download from DB
        NetworkUsecase.downloadPages(sid: sid) { views in
            print("NETWORK RESULT")
            print(views)
            // save to coreData
            let loading = self.startLoading(count: views.count)
            CoreUsecase.savePages(sid: sid, pages: views, loading: loading) { section in
                guard let section = section else {
                    loading.terminate()
                    self.showAlertWithOK(title: "서버 데이터 오류", text: "문제집 데이터가 올바르지 않습니다.")
                    return
                }
                DispatchQueue.main.async {
                    loading.terminate()
                    self.showSolvingVC(section: section)
                }
                return
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
        self.category.reloadData()
        self.preview.reloadData()
    }
    
    func deleteAlert(title: String, idx: Int) {
        let alert = UIAlertController(title: title,
            message: "삭제하시겠습니까?",
            preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default, handler: nil)
        let delete = UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.previewManager.delete(at: idx)
        })
        
        alert.addAction(cancle)
        alert.addAction(delete)
        present(alert,animated: true,completion: nil)
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
}

extension MainViewController {
    func createMockCoreDataForMath() {
        let context = CoreDataManager.shared.context
        
        let problemOfCore1 = Problem_Core(context: context)
        problemOfCore1.setMocks(pid: -111, type: 5, btName: "1", imgName: "mock1", expName: "exp1")
        let pageOfCore1 = Page_Core(context: context)
        pageOfCore1.setMocks(vid: -11, form: 0, type: 5, pids: [-111], mateImgName: nil)
        
        let problemOfCore2 = Problem_Core(context: context)
        problemOfCore2.setMocks(pid: -222, type: 5, btName: "2", imgName: "mock2", expName: "exp2")
        let pageOfCore2 = Page_Core(context: context)
        pageOfCore2.setMocks(vid: -22, form: 0, type: 5, pids: [-222], mateImgName: nil)
        
        let problemOfCore3 = Problem_Core(context: context)
        problemOfCore3.setMocks(pid: -333, type: 5, btName: "3", imgName: "mock3", expName: "exp3")
        let pageOfCore3 = Page_Core(context: context)
        pageOfCore3.setMocks(vid: -33, form: 0, type: 5, pids: [-333], mateImgName: nil)
        
        let problemOfCore4 = Problem_Core(context: context)
        problemOfCore4.setMocks(pid: -444, type: 5, btName: "4", imgName: "mock4", expName: "exp4")
        let pageOfCore4 = Page_Core(context: context)
        pageOfCore4.setMocks(vid: -44, form: 0, type: 5, pids: [-444], mateImgName: nil)
        
        let problemOfCore5 = Problem_Core(context: context)
        problemOfCore5.setMocks(pid: -555, type: 1, btName: "5", imgName: "mock5")
        let pageOfCore5 = Page_Core(context: context)
        pageOfCore5.setMocks(vid: -55, form: 0, type: 1, pids: [-555], mateImgName: nil)
        
        let sectionCore = Section_Core(context: context)
        let buttons = ["1", "2", "3", "4", "5"]
        let dict = ["1": -11, "2": -22, "3": -33, "4": -44, "5": -55]
        sectionCore.setMocks(sid: -1, buttons: buttons, dict: dict)
        
        do { try context.save() } catch let error { print(error.localizedDescription) }
        print("MOCK SAVE COMPLETE")
    }
    
    func createMockCoreDataForKorean() {
        let context = CoreDataManager.shared.context
        
        let problemOfCore1 = Problem_Core(context: context)
        problemOfCore1.setMocks(pid: -101, type: 5, btName: "1", imgName: "mockImg11")
        let problemOfCore2 = Problem_Core(context: context)
        problemOfCore2.setMocks(pid: -202, type: 5, btName: "2", imgName: "mockImg12")
        let problemOfCore3 = Problem_Core(context: context)
        problemOfCore3.setMocks(pid: -303, type: 5, btName: "3", imgName: "mockImg13")
        let problemOfCore4 = Problem_Core(context: context)
        problemOfCore4.setMocks(pid: -404, type: 5, btName: "4", imgName: "mockImg13")
        
        let pageOfCore1 = Page_Core(context: context)
        pageOfCore1.setMocks(vid: -10, form: 1, type: 5, pids: [-101, -202, -303, -404], mateImgName: "material1")
        
        let problemOfCore5 = Problem_Core(context: context)
        problemOfCore5.setMocks(pid: -505, type: 5, btName: "5", imgName: "mockImg21")
        let problemOfCore6 = Problem_Core(context: context)
        problemOfCore6.setMocks(pid: -606, type: 5, btName: "6", imgName: "mockImg22")
        let problemOfCore7 = Problem_Core(context: context)
        problemOfCore7.setMocks(pid: -707, type: 5, btName: "7", imgName: "mockImg23")
        let problemOfCore8 = Problem_Core(context: context)
        problemOfCore8.setMocks(pid: -808, type: 5, btName: "8", imgName: "mockImg24")
        
        let pageOfCore2 = Page_Core(context: context)
        pageOfCore2.setMocks(vid: -20, form: 1, type: 5, pids: [-505, -606, -707, -808], mateImgName: "material2")
        
        let sectionCore = Section_Core(context: context)
        let buttons = ["1", "2", "3", "4", "5", "6", "7", "8"]
        let dict = ["1": -10, "2": -10, "3": -10, "4": -10,
                    "5": -20, "6": -20, "7": -20, "8": -20]
        sectionCore.setMocks(sid: -2, buttons: buttons, dict: dict)
        
        do { try context.save() } catch let error { print(error.localizedDescription) }
        print("MOCK SAVE COMPLETE")
    }
}
