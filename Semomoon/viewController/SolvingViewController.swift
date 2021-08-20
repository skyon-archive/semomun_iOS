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
            bt.layer.cornerRadius = 15
        }
//        sol_1.layer.cornerRadius = 15
//        sol_2.layer.cornerRadius = 15
//        sol_3.layer.cornerRadius = 15
//        sol_4.layer.cornerRadius = 15
//        sol_5.layer.cornerRadius = 15
    }
    
    func setBorderWidth() {
        for bt in buttons {
            bt.layer.borderWidth = 0.5
        }
//        sol_1.layer.borderWidth = 0.5
//        sol_2.layer.borderWidth = 0.5
//        sol_3.layer.borderWidth = 0.5
//        sol_4.layer.borderWidth = 0.5
//        sol_5.layer.borderWidth = 0.5
    }
    
    func setBorderColor() {
        for bt in buttons {
            bt.layer.borderColor = UIColor.black.cgColor
        }
//        sol_1.layer.borderColor = UIColor.black.cgColor
//        sol_2.layer.borderColor = UIColor.black.cgColor
//        sol_3.layer.borderColor = UIColor.black.cgColor
//        sol_4.layer.borderColor = UIColor.black.cgColor
//        sol_5.layer.borderColor = UIColor.black.cgColor
    }
}
