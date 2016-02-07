//
//  PSJsonResponseHandler.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSHttp/PSHttpResponseHandler.h>

/** 将HttpRespone的Json字符串解析成对象, 可能是NSMutableArray或NSMutableDictionary */
@interface PSJsonResponseHandler : PSHttpResponseHandler
@property (nonatomic, copy) void (^onSuccess)(id result);
@property (nonatomic, copy) void (^onProgress)(long long bytesWritten, long long totalBytesExpectedToWrite);
@property (nonatomic, copy) void (^onFailure)(id result, NSError *error);

+ (instancetype)success:(void (^)(id result))success failure:(void (^)(id result, NSError *error))failure;
@end
