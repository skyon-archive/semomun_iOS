//
//  RNTCoreUseCase.m
//  semomun
//
//  Created by 신영민 on 2022/07/23.
//

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import "React/RCTBridgeModule.h"
#endif

#import <CoreData/CoreData.h>
#import "semomun-swift.h"
#import <React/RCTLog.h>

@interface RNTCoreUseCase : NSObject <RCTBridgeModule>
@end
  
@implementation RNTCoreUseCase

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(sectionOfCoreData:(NSInteger)sid
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    Section_Core *sectionCore = [CoreUsecase sectionOfCoreDataWithSid:sid];
    if(sectionCore != nil) {
        NSArray *keys = [[[sectionCore entity] attributesByName] allKeys];
        NSDictionary *dict = [sectionCore dictionaryWithValuesForKeys:keys];
        resolve(dict);
    } else {
        reject(@"Error", nil, nil);
    }
}


RCT_EXPORT_METHOD(fetchUserInfo:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    UserCoreData *userCoreData = [CoreUsecase fetchUserInfo];
    if(userCoreData != nil) {
        NSArray *keys = [[[userCoreData entity] attributesByName] allKeys];
        NSDictionary *dict = [userCoreData dictionaryWithValuesForKeys:keys];
        resolve(dict);
    } else {
        reject(@"Error", nil, nil);
    }
}

@end
