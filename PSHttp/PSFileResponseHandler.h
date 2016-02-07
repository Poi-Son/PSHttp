//
//  PSFileResponseHandler.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSHttp/PSHttpResponseHandler.h>

/** 下载文件 */
@interface PSFileResponseHandler : PSHttpResponseHandler
@property (nonatomic, weak) NSMutableURLRequest *downloadRequest;

@property (nonatomic, readonly) NSData *cacheConfig;/**< 配置 */
@property (nonatomic, readonly) NSString *cacheConfigPath;/**< 配置文件路径 */

@property (nonatomic, copy) void (^onSuccess)(NSString *filename, NSData *data);
@property (nonatomic, copy) void (^onProgress)(long long bytesWritten, long long totalBytesExpectedToWrite);
@property (nonatomic, copy) void (^onFailure)(NSError *error);

+ (instancetype)progress:(void (^)(long long bytesWritten, long long totalBytesExpectedToWrite))progress
                 success:(void (^)(NSString *filename, NSData *data))success
                 failure:(void (^)(NSError *error))failure;
@end
