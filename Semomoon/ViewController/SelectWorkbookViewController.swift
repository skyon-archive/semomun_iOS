//
//  selectWorkbookViewController.swift
//  selectWorkbookViewController
//
//  Created by qwer on 2021/09/12.
//

import UIKit

class SelectWorkbookViewController: UIViewController {

    @IBOutlet weak var frame: UIView!
    @IBOutlet weak var selectSubject: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setRadiusOfFrame()
        setRadiusOfButtons()
        
    }
    @IBAction func test(_ sender: Any) {
        selectSubject.setTitle("국어영역", for: .normal)
    }
    
}


extension SelectWorkbookViewController {
    func setRadiusOfFrame() {
        frame.layer.cornerRadius = 30
    }
    
    func setRadiusOfButtons() {
        selectSubject.layer.borderWidth = 2
        selectSubject.layer.borderColor = UIColor.lightGray.cgColor
        selectSubject.layer.cornerRadius = 10
    }
}
