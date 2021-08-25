//
//  parentViewController.swift
//  parentViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit

class parentViewController: UIViewController {
    
    // link to the NSView Container
    @IBOutlet weak var container : UIView!

    var vc1: UIViewController = test_1ViewController()
    var vc2: UIViewController = test_2ViewController()
    var vc3: UIViewController = test_3ViewController()
    var viewNum: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        vc1 = self.storyboard?.instantiateViewController(withIdentifier: "test_1ViewController") ?? test_1ViewController()
        vc2 = self.storyboard?.instantiateViewController(withIdentifier: "test_2ViewController") ?? test_2ViewController()
        vc3 = self.storyboard?.instantiateViewController(withIdentifier: "test_3ViewController") ?? test_3ViewController()
        self.addChild(vc1)
        self.addChild(vc2)
        self.addChild(vc3)
    }
//
//    // You can link this action to both buttons
//    @IBAction func switchViews(sender: NSButton) {
//
//        for sView in self.container.subviews {
//            sView.removeFromSuperview()
//        }
//
//        if vc1Active == true {
//
//            vc1Active = false
//            vc2.view.frame = self.container.bounds
//            self.container.addSubview(vc2.view)
//
//        } else {
//
//            vc1Active = true
//            vc1.view.frame = self.container.bounds
//            self.container.addSubview(vc1.view)
//        }
//
//    }
    
    @IBAction func change(_ sender: UIButton) {
        for child in self.container.subviews { child.removeFromSuperview() }
        
        switch(sender.tag) {
        case 1:
            vc1.view.frame = self.container.bounds
            self.container.addSubview(vc1.view)
        case 2:
            vc2.view.frame = self.container.bounds
            self.container.addSubview(vc2.view)
        case 3:
            vc3.view.frame = self.container.bounds
            self.container.addSubview(vc3.view)
        default:
            break
        }
//        vc1.willMove(toParent: nil)
//        vc1.view.removeFromSuperview()
//        vc1.removeFromParent()
//
//        vc2 = self.storyboard?.instantiateViewController(withIdentifier: "test_2ViewController") ?? test_2ViewController()
//        self.addChild(vc2)
//        vc2.view.frame = self.container.bounds
//        self.container.addSubview(vc2.view)
    }
}
