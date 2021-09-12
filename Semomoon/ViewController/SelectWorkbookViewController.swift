//
//  selectWorkbookViewController.swift
//  selectWorkbookViewController
//
//  Created by qwer on 2021/09/12.
//

import UIKit

class SelectWorkbookViewController: UIViewController {

    @IBOutlet weak var frame: UIView!
    @IBOutlet var selectButtons: [UIButton]!
    
    let dataOfSubject: [String] = ["국어", "수학", "영어", "과학"]
    let dataOfGrade: [String] = ["1학년", "2학년", "3학년"]
    let dataOfYear: [String] = ["2021년", "2020년", "2019년", "2018년"]
    let dataOfMonth: [String] = ["1월", "2월", "3월", "4월", "5월"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadiusOfFrame()
        setRadiusOfSelectButtons()
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func showSubject(_ sender: UIButton) {
        let idx = Int(sender.tag)
        switch idx {
        case 0:
            showAlertController(title: "과목 선택", index: idx, data: dataOfSubject)
        case 1:
            showAlertController(title: "학년 선택", index: idx, data: dataOfGrade)
        case 2:
            showAlertController(title: "년도 선택", index: idx, data: dataOfYear)
        case 3:
            showAlertController(title: "월 선택", index: idx, data: dataOfMonth)
        default:
            break
        }
    }
}


extension SelectWorkbookViewController {
    func setRadiusOfFrame() {
        frame.layer.cornerRadius = 30
    }
    
    func setRadiusOfSelectButtons() {
        selectButtons.forEach {
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.cornerRadius = 10
        }
    }
    
    func showAlertController(title: String, index: Int, data: [String]) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        data.forEach { title in
            let button = UIAlertAction(title: title, style: .default) { _ in
                self.selectButtons[index].setTitle(title, for: .normal)
            }
            alertController.addAction(button)
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.selectButtons[index]
            popoverController.sourceRect = CGRect(x: self.selectButtons[index].bounds.midX, y: self.selectButtons[index].bounds.maxY, width: 0, height: 0)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
