//
//  ViewController.swift
//  Semomoon
//
//  Created by Kang Minsang on 2021/08/17.
//

import UIKit
import PencilKit

class ViewController: UIViewController {
    @IBOutlet var img: UIImageView!
    
    @IBOutlet var send: UIButton!
    @IBOutlet var check_1: UIButton!
    @IBOutlet var check_2: UIButton!
    @IBOutlet var check_3: UIButton!
    @IBOutlet var check_4: UIButton!
    @IBOutlet var check_5: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var timeFrame: UIView!
    
    @IBOutlet var bottomFrame: UIView!
    
    var tempBts: [String] = []
    let canvas = PKCanvasView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...20 { tempBts.append("\(i)") }
        
        setRadius()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.doPinch(_:)))
        self.view.addGestureRecognizer(pinch) // 핀치 제스처 등록
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        canvas.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: img.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: img.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: img.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: img.trailingAnchor),
        ])
    }
    
    @IBAction func showPencle(_ sender: Any) {
        DispatchQueue.main.async {
            self.showPencleView()
        }
    }
    
    func showPencleView() {
        guard let window = view.window,
              let toolPicker = PKToolPicker.shared(for: window) else { return }
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        toolPicker.setVisible(true, forFirstResponder: canvas)
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        // 이미지를 스케일에 맞게 변환
        img.transform = img.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        // 다음 변환을 위해 핀치의 스케일 속성을 1로 설정
        pinch.scale = 1
    }
}

extension ViewController {
    func setRadius() {
        let buttons: [UIButton] = [send, check_1, check_2, check_3, check_4, check_5, nextButton]
        for button in buttons {
            button.layer.cornerRadius = 15
        }
        timeFrame.layer.cornerRadius = 15
        bottomFrame.layer.cornerRadius = 30
        bottomFrame.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func selectNum(_ num: String) {
        print("선택 : \(num)")
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //버튼 개수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempBts.count
    }
    //버튼 화면 뿌리기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "probButtonCell", for: indexPath) as? probButtonCell else {
            return UICollectionViewCell()
        }
        cell.num.text = tempBts[indexPath.row]
        cell.round.layer.cornerRadius = 20
        return cell
    }
    //버튼 클릭시 이벤트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectNum(tempBts[indexPath.row])
    }
}

class probButtonCell: UICollectionViewCell {
    @IBOutlet var num: UILabel!
    @IBOutlet var round: UIView!
}
