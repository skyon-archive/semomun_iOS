//
//  RNTHomeVCManager.m
//  semomun
//
//  Created by 신영민 on 2022/07/21.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTHomeVCManager : RCTViewManager
@end

@implementation RNTHomeVCManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[HomeVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


