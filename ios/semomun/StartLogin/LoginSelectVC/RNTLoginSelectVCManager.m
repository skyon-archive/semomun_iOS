//
//  RNTLoginSelectVCManager.m
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTLoginSelectVCManager : RCTViewManager
@end

@implementation RNTLoginSelectVCManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[LoginSelectVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


