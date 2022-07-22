//
//  HomeVCManager.swift
//  semomun
//
//  Created by 신영민 on 2022/07/22.
//

import UIKit


@objc(RNTHomeVCManager)
class RNTHomeVCManager : RCTViewManager {
  
  override func view() -> UIView! {
    return HomeVCAdapterView()
  }
    
}
