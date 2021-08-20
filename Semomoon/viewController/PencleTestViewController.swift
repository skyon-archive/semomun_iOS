//
//  PencleTestViewController.swift
//  PencleTestViewController
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit
import PencilKit

class PencleTestViewController: UIViewController {

    let canvas = PKCanvasView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        canvas.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let window = view.window,
              let toolPicker = PKToolPicker.shared(for: window) else { return }
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
    }

}
