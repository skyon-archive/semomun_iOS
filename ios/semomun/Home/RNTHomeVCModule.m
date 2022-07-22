//
//  RCTHomeVc.m
//  semomun
//
//  Created by 신영민 on 2022/07/21.
//

/*
#import <React/RCTBridgeModule.h>
#import "semomun-Swift.h"

@interface RCTHomeVCModule : NSObject <RCTBridgeModule>
@end

@implementation RCTHomeVCModule

// To export a module named RCTCalendarModule
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initVC)
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *view = [storyboard instantiateInitialViewController];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [rootViewController presentViewController:view animated:true completion:nil];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

@end
*/


#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(RNTHomeVCManager, RCTViewManager)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end


