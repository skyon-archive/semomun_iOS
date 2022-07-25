//
//  RNTSearchTagVCModule.m
//  semomun
//
//  Created by 신영민 on 2022/07/22.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTSearchTagVCManager : RCTViewManager
@end

@implementation RNTSearchTagVCManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[SearchTagVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


