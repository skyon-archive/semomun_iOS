//
//  WarningOfflineStatusViewManager.swift
//  semomun
//
//  Created by 신영민 on 2022/07/21.
//

import UIKit


@objc(WarningOfflineStatusViewManager)
class WarningOfflineStatusViewManager : RCTViewManager {
  
  override func view() -> UIView! {
    return WarningOfflineStatusView();
  }
    
}
