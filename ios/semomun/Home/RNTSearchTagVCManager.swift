//
//  RNTSearchTagVCManager.swift
//  semomun
//
//  Created by 신영민 on 2022/07/22.
//

import UIKit


@objc(RNTSearchTagVCManager)
class RNTSearchTagVCManager : RCTViewManager {
  
  override func view() -> UIView! {
    return SearchTagVCAdapterView()
  }
    
}
