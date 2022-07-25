//
//  RNTBookshelfVCManager.m
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import "semomun-Swift.h"

@interface RNTBookshelfVCManager : RCTViewManager
@end

@implementation RNTBookshelfVCManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[BookshelfVCAdapterView alloc] init];
}


+ (BOOL)requiresMainQueueSetup
{
  return true;
}

@end


