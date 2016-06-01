//
//  YMProgress.m
//  YMFramework
//
//  Created by Tristen on 12/8/15.
//  Copyright © 2015 cornapp. All rights reserved.
//

#import "YMProgress.h"

#import "SVProgressHUD.h"

#import "UIColor+YMAdditions.h"
#import "YMDeviceInfo.h"
#import "NSBundle+YMAdditions.h"

@implementation YMProgress

static UIImage *kFailTypeForNormal;
static UIImage *kFailTypeForNotReachable;
static UIImage *kFailTypeForLocation;

+ (void)load
{
    [super load];
    
    [SVProgressHUD setBackgroundColor:[UIColor ym_colorWithHexString:@"2a4885" alpha:0.8]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:5];
    
    if (kYm_iPhone6Plus) {
        [SVProgressHUD setFont:[UIFont systemFontOfSize:15]];
        [SVProgressHUD setTextToTop:109];
    }
    else {
        [SVProgressHUD setTextToTop:84];
        [SVProgressHUD setFont:[UIFont systemFontOfSize:13]];
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    if (kYm_iPhone6Plus) {
        kFailTypeForNormal = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"error@3x"
                                                                                    ofType:@"png"
                                                                               inDirectory:@"/Progress"]];
        
        kFailTypeForNotReachable = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"failTypeForNotReachable@3x"
                                                                                          ofType:@"png"
                                                                                     inDirectory:@"/Progress"]];
        
        kFailTypeForLocation = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"failTypeForLocation@3x"
                                                                                      ofType:@"png"
                                                                                 inDirectory:@"/Progress"]];
    }
    else {
        kFailTypeForNormal = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"error@2x"
                                                                                    ofType:@"png"
                                                                               inDirectory:@"/Progress"]];
        
        kFailTypeForNotReachable = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"failTypeForNotReachable@2x"
                                                                                          ofType:@"png"
                                                                                     inDirectory:@"/Progress"]];
        
        kFailTypeForLocation = [UIImage imageWithContentsOfFile:[bundle ym_pathForResource:@"failTypeForLocation@2x"
                                                                                      ofType:@"png"
                                                                                 inDirectory:@"/Progress"]];
    }
}

+ (void)showWithStatus:(NSString *)status
{
    if (kYm_iPhone6Plus) {
        [SVProgressHUD setTextToTop:100];
    }
    else {
        [SVProgressHUD setTextToTop:77];
    }
    
    [SVProgressHUD showWithStatus:status];
}

+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

+ (void)showSuccessStatus:(NSString *)text
{
    [SVProgressHUD showSuccessWithStatus:text];
}

+ (void)showFailStatus:(NSString *)text
{
    [YMProgress showFailStatus:text
                  withFailType:YMProgrssFailTypeForNormal];
}

+ (void)showFailStatus:(NSString *)text
          withFailType:(YMProgrssFailType)failType
{
    switch (failType) {
        case YMProgrssFailTypeForNormal:
            [SVProgressHUD setErrorImage:kFailTypeForNormal];
            break;
        case YMProgrssFailTypeForNotReachable:
            [SVProgressHUD setErrorImage:kFailTypeForNotReachable];
            break;
        case YMProgrssFailTypeForLocation:
            [SVProgressHUD setErrorImage:kFailTypeForLocation];
            break;
        default:
            [SVProgressHUD setErrorImage:kFailTypeForNormal];
            break;
    }
    
    [SVProgressHUD showErrorWithStatus:text];
}

+ (void)showInfoWithStatus:(NSString *)text
{
    [SVProgressHUD showInfoWithStatus:text];
}

@end
