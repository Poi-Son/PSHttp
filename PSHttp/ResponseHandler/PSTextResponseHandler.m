//
//  PSTextResponseHandler.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSTextResponseHandler.h"
#import "PSHttpResponseHandler_Private.h"

@implementation PSTextResponseHandler
+ (instancetype)success:(void (^)(NSString *))success failure:(void (^)(NSString *result, NSError *))failure{
    PSTextResponseHandler *instance = [self new];
    instance.onSuccess = success;
    instance.onFailure = failure;
    return instance;
}

- (void)processProgressWithWritten:(long long)bytesWritten total:(long long)totalBytesExpectedToWrite{
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onProgress, self.onProgress(bytesWritten, totalBytesExpectedToWrite));
    });
}

- (void)processSuccessWithData:(NSData *)data{
    NSString *result = [[NSString alloc] initWithData:data encoding:self.encoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onSuccess, self.onSuccess(result));
    });
}

- (void)processFailureWithData:(NSData *)data error:(NSError *)error{
    NSString *result = [[NSString alloc] initWithData:data encoding:self.encoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onFailure, self.onFailure(result, error));
    });
}

@end
