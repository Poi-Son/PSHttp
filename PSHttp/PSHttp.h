//
//  PSHttp.h
//  PSExtensions
//
//  Created by PoiSon on 15/9/22.
//  Copyright (c) 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSHttp/PSHttpResponseHandlers.h>
#import <PSHttp/convenientmacros.h>

typedef NS_ENUM(NSInteger, PSNetworkStatus) {
    PSEnumOption(PSNetworkStatusUnknown, -1, "未知网络状态"),
    PSEnumOption(PSNetworkStatusNotReachable, 0, "无网络"),
    PSEnumOption(PSNetworkStatusReachableViaWWAN, 1, "移动网络"),
    PSEnumOption(PSNetworkStatusReachableViaWiFi, 2, "Wifi网络")
};
@protocol PSHttpDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface PSHttp : NSObject
/* 不要以此网络状态来决定是否发送请求, 但可以决定是否重试. 因为网络是波动的. */
+ (PSNetworkStatus)networkStatus;/**< 当前网络状态 */

+ (void)reinitWithBaseURL:(NSURL *)url;/**< 重新初始化 */
+ (void)setDelegate:(id<PSHttpDelegate>)delegate;/**< 设置代理 */
+ (NSURL *)baseURL;/**< BaseURL */
+ (instancetype)UTF8Client;/**< UTF8编码 */
+ (instancetype)GB18030_2000Client;/**< GBK编码 */

- (__kindof PSHttpResponseHandler *)GET:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)HEAD:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)POST:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)PUT:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)PATCH:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)DELETE:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)REQUEST:(NSURLRequest *)request handler:(nullable PSHttpResponseHandler *)handler;

- (__kindof PSHttpResponseHandler *)UPLOAD:(NSString *)URL params:(nullable id)params data:(NSData *)data filename:(NSString *)filename handler:(nullable PSHttpResponseHandler *)handler;
- (__kindof PSHttpResponseHandler *)DOWNLOAD:(NSString *)URL params:(nullable id)params handler:(nullable PSHttpResponseHandler *)handler/*如果传入PSFileResponseHandler, 则支持断点续传*/;
@end

@protocol PSHttpDelegate <NSObject>
@optional
- (void)httpHasResponseWithHandler:(PSHttpResponseHandler *)handler;/**< 检测数据回复 */
- (void)reachabilityChanged:(PSNetworkStatus)status;/**< 检测网络状态 */
@end
NS_ASSUME_NONNULL_END