//
//  SolvingViewController.swift
//  Semomoon
//
//  Created by qwer on 2021/08/20.
//

import UIKit

class SolvingViewController: UIViewController {

    @IBOutlet weak var solvInputFrame: UIView!
    @IBOutlet weak var sol_1: UIButton!
    @IBOutlet weak var sol_2: UIButton!
    @IBOutlet weak var sol_3: UIButton!
    @IBOutlet weak var sol_4: UIButton!
    @IBOutlet weak var sol_5: UIButton!
    var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [sol_1, sol_2, sol_3, sol_4, sol_5]
        setRadius()
        setBorderWidth()
        setBorderColor()
        setShadowFrame()
    }
    
    @IBAction func sol_click(_ sender: UIButton) {
        let num: Int = sender.tag
        for bt in buttons {
            if(bt.tag == num) {
                bt.backgroundColor = UIColor(named: "mint")
                bt.setTitleColor(UIColor.white, for: .normal)
            } else {
                bt.backgroundColor = UIColor.white
                bt.setTitleColor(UIColor(named: "mint"), for: .normal)
            }
        }
    }
    
    

}

extension SolvingViewController {
    func setRadius() {
        solvInputFrame.layer.cornerRadius = 20
        for bt in buttons {
            bt.layer.cornerRadius = 20
        }
    }
    
    func setBorderWidth() {
        for bt in buttons {
            bt.layer.borderWidth = 0.5
        }
    }
    
    func setBorderColor() {
        for bt in buttons {
            bt.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func setShadowFrame() {
        solvInputFrame.layer.shadowColor = UIColor.lightGray.cgColor
        solvInputFrame.layer.shadowOpacity = 0.3
        solvInputFrame.layer.shadowOffset = CGSize(width: 3, height: 3)
        solvInputFrame.layer.shadowRadius = 5
        solvInputFrame.layer.masksToBounds = false
    }
}
