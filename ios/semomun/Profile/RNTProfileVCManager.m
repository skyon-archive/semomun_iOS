//
//  RNTProfileVCManager.m
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTProfileVCManager : RCTViewManager
@end

@implementation RNTProfileVCManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onNavigate, RCTDirectEventBlock)

- (UIView *)view
{
  return [[ProfileVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


