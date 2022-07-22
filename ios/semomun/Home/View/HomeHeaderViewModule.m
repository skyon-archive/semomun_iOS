//
//  HomeVCModule.m
//  semomun
//
//  Created by 신영민 on 2022/07/21.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(HomeHeaderViewManager, RCTViewManager)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end

