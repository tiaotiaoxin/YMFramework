//
//  AccountTool.m
//  YuMiAssistant
//
//  Created by Tristen-MacBook on 8/15/14.
//
//

//ShareSDK必要头文件
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

#import "SDImageCache.h"

#import "YMThirdPlatformTool.h"
#import "YMThirdPlatformUserInfo.h"
#import "YMThirdPlatformShareEntity.h"
#import "YMTool.h"
#import "NSString+YMAdditions.h"
#import "YMHTTPRequestManager.h"
#import "YMFrameworkConfig.h"



@interface YMThirdPlatformTool()

@end

@implementation YMThirdPlatformTool

static NSString *kWechatAppID = nil;
static NSString *kWechatAppSecret;

static NSString *kQQAppID = nil;
static NSString *kQQAppKey = nil;

static NSString *kSinaWeiboAppKey = nil;
static NSString *kSinaWeiboAppSecret = nil;
static NSString *kSinaWeiboAppRedirectURL = nil;

+ (void)setupWeChatByAppId:(NSString *)appId
                 appSecret:(NSString *)appSecret
{
    kWechatAppID = appId;
    kWechatAppSecret = appSecret;
}

+ (void)setupQQByAppId:(NSString *)appId
                appKey:(NSString *)appKey
{
    kQQAppID = appId;
    kQQAppKey = appKey;
}

+ (void)setupSinaWeiboByAppKey:(NSString *)appKey
                     appSecret:(NSString *)appSecret
                   redirectUri:(NSString *)redirectUri
{
    kSinaWeiboAppKey = appKey;
    kSinaWeiboAppSecret = appSecret;
    kSinaWeiboAppRedirectURL = redirectUri;
}

+ (void)registerByAppKey:(NSString *)appKey
{
    if([NSString ym_isEmptyString:appKey]) {
        return;
    }
    
    NSMutableArray *platforms = [NSMutableArray array];
    
    //微信
    if ([NSString ym_isContainString:kWechatAppID] && [NSString ym_isContainString:kWechatAppSecret]) {
        [platforms addObject:@(SSDKPlatformTypeWechat)];
    }
    
    //QQ
    if ([NSString ym_isContainString:kQQAppKey] && [NSString ym_isContainString:kQQAppID]) {
        [platforms addObject:@(SSDKPlatformTypeQQ)];
    }
    
    //新浪微博
    if ([NSString ym_isContainString:kSinaWeiboAppKey] && [NSString ym_isContainString:kSinaWeiboAppSecret]
        && [NSString ym_isContainString:kSinaWeiboAppRedirectURL]) {
        [platforms addObject:@(SSDKPlatformTypeSinaWeibo)];
    }
    
    //Test
    [platforms addObject:@(SSDKPlatformTypeFacebook)];
    [platforms addObject:@(SSDKPlatformTypeTwitter)];
    
    [ShareSDK registerApp:appKey
          activePlatforms:platforms
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              switch (platformType) {
                  case SSDKPlatformTypeWechat: {
                      [appInfo SSDKSetupWeChatByAppId:kWechatAppID
                                            appSecret:kWechatAppSecret];
                      break;
                  }
                  case SSDKPlatformTypeQQ: {
                      [appInfo SSDKSetupQQByAppId:kQQAppID
                                           appKey:kQQAppKey
                                         authType:SSDKAuthTypeBoth];
                      break;
                  }
                  case SSDKPlatformTypeSinaWeibo: {
                      [appInfo SSDKSetupSinaWeiboByAppKey:kSinaWeiboAppKey
                                                appSecret:kSinaWeiboAppSecret
                                              redirectUri:kSinaWeiboAppRedirectURL
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  }
                  case SSDKPlatformTypeFacebook: {
                      [appInfo SSDKSetupFacebookByApiKey:@"107704292745179"
                                               appSecret:@"38053202e1a5fe26c80c753071f0b573"
                                                authType:SSDKAuthTypeBoth];
                      break;
                  }
                  case SSDKPlatformTypeTwitter: {
                      [appInfo SSDKSetupTwitterByConsumerKey:@"LRBM0H75rWrU9gNHvlEAA2aOy"
                                              consumerSecret:@"gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G"
                                                 redirectUri:@"http://mob.com"];
                      break;
                  }
                  default:
                      break;
              }
          }];
}

+ (void)loginForPlatformType:(YMThirdPlatformType)platformType
                     success:(void (^)(YMThirdPlatformUserInfo *platformUserInfo))success
                     failure:(void (^)(NSString *errorDescription))failure
{
    SSDKPlatformType type = SSDKPlatformTypeFromPlatformType(platformType);
    
    [ShareSDK authorize:type
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             if (error) {
                 NSDictionary *dic = error.userInfo;
                 
                 NSString *errorMessage = dic[@"error_message"];
                 if (failure) {
                     failure(errorMessage);
                 }
             }
             else if(state == SSDKResponseStateCancel) {
                 if (failure) {
                     failure(@"登录取消");
                 }
             }
             else {
                 YMThirdPlatformUserInfo *platformUserInfo = [[YMThirdPlatformUserInfo alloc] init];
                 platformUserInfo.userId = user.uid;
                 platformUserInfo.nickname = user.nickname;
                 platformUserInfo.profileImageUrl = user.icon;
                 platformUserInfo.accessToken = user.credential.token;
                 platformUserInfo.expired = user.credential.expired;
                 platformUserInfo.homepage = user.url;
                 platformUserInfo.platformType = platformType;
                 
                 if (success) {
                     success(platformUserInfo);
                 }
             }
         }];
}

+ (void)logoutForPlatformType:(YMThirdPlatformType)platformType
{
    [ShareSDK cancelAuthorize:SSDKPlatformTypeFromPlatformType(platformType)];
}

+ (BOOL)hasLoginForPlatformType:(YMThirdPlatformType)platformType
{
    return [ShareSDK hasAuthorized:SSDKPlatformTypeFromPlatformType(platformType)];
}

+ (void)shareWithEntity:(YMThirdPlatformShareEntity *)shareEntity
                success:(void (^)(YMThirdPlatformShareEntity *shareEntity))success
                failure:(void (^)(NSString *errorDescription))failure
                 cancel:(void (^)(void))cancel
{
    [ShareSDK share:SSDKPlatformTypeFromPlatformShareType(shareEntity.shareType)
         parameters:shareContentFromShareEntity(shareEntity)
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         if (state == SSDKResponseStateSuccess) {
             if(success) {
                 success(shareEntity);
             }
         }
         else if (state == SSDKResponseStateFail) {
             
             NSDictionary *dic = error.userInfo;
             
             NSString *errorMessage = dic[@"error_message"];
             if (failure) {
                 if ([NSString ym_isEmptyString:errorMessage]) {
                     errorMessage = @"分享失败";
                 }
                 failure(errorMessage);
             }
         }
         else if(state == SSDKResponseStateCancel) {
             if (cancel) {
                 cancel();
             }
         }
     }];
}

+ (BOOL)isThirdPlatformAppInstalled:(YMThirdPlatformType)platformType
{
    BOOL installed = NO;
    switch (platformType) {
        case YMThirdPlatformForWeibo:
            installed = [WeiboSDK isWeiboAppInstalled];
            break;
        case YMThirdPlatformForQQ:
            installed = [QQApiInterface isQQInstalled];
            break;
        case YMThirdPlatformForWechat:
            installed = [WXApi isWXAppInstalled];
            break;
        default:
            installed = NO;
            break;
    }
    
    return installed;
}

#pragma mark - private methods

static inline SSDKPlatformType SSDKPlatformTypeFromPlatformType(YMThirdPlatformType platformType)
{
    SSDKPlatformType type = 0;
    switch (platformType) {
        case YMThirdPlatformForWeibo:
            type = SSDKPlatformTypeSinaWeibo;
            break;
        case YMThirdPlatformForQQ:
            type = SSDKPlatformTypeQQ;
            break;
        case YMThirdPlatformForWechat:
            type = SSDKPlatformTypeWechat;
            break;
        case YMThirdPlatformForFacebook:
            type = SSDKPlatformTypeFacebook;
            break;
        case YMThirdPlatformForTwitter:
            type = SSDKPlatformTypeTwitter;
            break;
        default:
            type = SSDKPlatformTypeAny;
            break;
    }
    
    return type;
}

static inline SSDKPlatformType SSDKPlatformTypeFromPlatformShareType(YMThirdPlatformShareType platformShareType)
{
    SSDKPlatformType type = 0;
    switch (platformShareType) {
        case YMThirdPlatformShareForWeibo:
            type = SSDKPlatformTypeSinaWeibo;
            break;
        case YMThirdPlatformShareForQQSpace:
            type = SSDKPlatformSubTypeQZone;
            break;
        case YMThirdPlatformShareForWechatTimeline:
            type = SSDKPlatformSubTypeWechatTimeline;
            break;
        case YMThirdPlatformShareForWechatSession:
            type = SSDKPlatformSubTypeWechatSession;
            break;
        case YMThirdPlatformShareForQQFriend:
            type = SSDKPlatformSubTypeQQFriend;
            break;
        case YMThirdPlatformShareForFacebook:
            type = SSDKPlatformTypeFacebook;
            break;
        case YMThirdPlatformShareForTwitter:
            type = SSDKPlatformTypeTwitter;
            break;
        default:
            type = SSDKPlatformTypeAny;
            break;
    }
    
    return type;
}

static inline NSMutableDictionary* shareContentFromShareEntity(YMThirdPlatformShareEntity *shareEntity)
{
    //构造分享内容
    NSMutableDictionary *publishContent = [NSMutableDictionary dictionary];
    
    NSString *imageURL = [NSString ym_trim:shareEntity.imageURL];
    NSString *title = [NSString ym_trim:shareEntity.title];
    NSString *resourceUrl = [NSString ym_trim:shareEntity.resourceURL];
    
    BOOL isInWechat = shareEntity.shareType == YMThirdPlatformShareForWechatTimeline || shareEntity.shareType == YMThirdPlatformShareForWechatSession;
    BOOL isGif = [imageURL rangeOfString:@".gif"].location != NSNotFound;
    
    if (isInWechat && isGif) {
        NSData *imageData = [[SDImageCache sharedImageCache] diskImageDataBySearchingAllPathsForKey:imageURL];
        
        [publishContent SSDKSetupWeChatParamsByText:shareEntity.contentText
                                              title:title
                                                url:nil
                                         thumbImage:imageURL
                                              image:imageURL
                                       musicFileURL:nil
                                            extInfo:nil
                                           fileData:nil
                                       emoticonData:imageData
                                               type:SSDKContentTypeImage
                                 forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    }
    else {
        
        NSURL *url = nil;
        if ([NSString ym_isContainString:resourceUrl]) {
            url = [NSURL URLWithString:resourceUrl];
        }
        
        [publishContent SSDKSetupShareParamsByText:shareEntity.contentText
                                            images:@[imageURL]
                                               url:url
                                             title:title
                                              type:SSDKContentTypeAuto];
    }
    
    
    return publishContent;
}

@end