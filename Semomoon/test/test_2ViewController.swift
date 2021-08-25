//
//  test_2ViewController.swift
//  test_2ViewController
//
//  Created by qwer on 2021/08/25.
//

import UIKit

class test_2ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func test(_ sender: Any) {
        print("hello from 2")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("2 : disappear")
    }
}
