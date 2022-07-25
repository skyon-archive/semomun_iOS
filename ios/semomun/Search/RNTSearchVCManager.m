//
//  RNTSearchVCManager.m
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTSearchVCManager : RCTViewManager
@end

@implementation RNTSearchVCManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[SearchVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


