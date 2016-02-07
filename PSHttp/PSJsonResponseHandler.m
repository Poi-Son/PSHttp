//
//  PSJsonResponseHandler.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSJsonResponseHandler.h"
#import "PSHttpResponseHandler_Private.h"

@implementation PSJsonResponseHandler
+ (instancetype)success:(void (^)(id))success failure:(void (^)(id result, NSError *))failure{
    PSJsonResponseHandler *instance = [self new];
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
    NSError *error;
    id result = [self _processDataToJson:data error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
    if (error) {
        doIf(self.onFailure, self.onFailure(nil, error));
    }else{
        doIf(self.onSuccess, self.onSuccess(result));
    }
    });
}

- (void)processFailureWithData:(NSData *)data error:(NSError *)error{
    NSError *parseError;
    id result = [self _processDataToJson:data error:&parseError];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onFailure, self.onFailure(result, parseError ?: error));
    });
}


- (id)_processDataToJson:(NSData *)data error:(NSError **)error{
    NSData *json = data;
    if (self.encoding != NSUTF8StringEncoding) {
        NSString *tempStr = [[NSString alloc] initWithData:data encoding:self.encoding];
        json = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    id result = nil;
    if (json.length) {
        result = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:error];
    }
    return result;
}
@end
