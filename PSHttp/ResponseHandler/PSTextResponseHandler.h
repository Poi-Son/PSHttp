//
//  PSTextResponseHandler.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSHttp/PSHttpResponseHandler.h>

/** 将HttpRespone的数据解析成字符串 */
@interface PSTextResponseHandler : PSHttpResponseHandler
@property (nonatomic, copy) void (^onSuccess)(NSString *result);
@property (nonatomic, copy) void (^onProgress)(long long bytesWritten, long long totalBytesExpectedToWrite);
@property (nonatomic, copy) void (^onFailure)(NSString *result, NSError *error);

+ (instancetype)success:(void (^)(NSString *result))success failure:(void (^)(NSString *result, NSError *error))failure;
@end
