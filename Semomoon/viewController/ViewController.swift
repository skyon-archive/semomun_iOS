//
//  ViewController.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    @IBOutlet weak var testView: UIView!
    var show: Bool = false
    
    lazy var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        return canvasView
    }()
    
    lazy var toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(self)
        return toolPicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        testView.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: testView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: testView.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: testView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: testView.trailingAnchor),
        ])
//        canvasView.frame = testView.bounds
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.delegate = self
        canvasView.becomeFirstResponder()
    }
    @IBAction func pencil(_ sender: Any) {
        show = !show
        toolPicker.setVisible(show, forFirstResponder: canvasView)
    }
}
