//
//  YMAnalytics.h
//  YMFramework
//
//  Created by 涛 陈 on 4/21/15.
//  Copyright (c) 2015 cornapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMAnalytics : NSObject

+ (void)start;

+ (void)beginLogPageView:(NSString *)pageName;
+ (void)endLogPageView:(NSString *)pageName;

+ (void)event:(NSString *)eventId;
+ (void)event:(NSString *)eventId label:(NSString *)label;

+ (NSString * )macString;
+ (NSString *)idfaString;
+ (NSString *)idfvString;

@end