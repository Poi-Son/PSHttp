//
//  PSHttpResponseHandler.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSHttpResponseHandler.h"
#import "PSHttpResponseHandler_Private.h"

@interface PSHttpResponseHandler ()
@property (nonatomic, strong) __kindof NSURLSessionTask *_task;
@property (nonatomic, weak) AFHTTPSessionManager *_session;
@property (nonatomic, weak) id<PSHttpDelegate> _delegate;
@property (nonatomic, strong) NSData *_responseData;
@end

@implementation PSHttpResponseHandler (Private)
@dynamic _task;
@dynamic _session;
@dynamic _delegate;

- (void)_processProgress:(NSProgress *)progress{
    [self processProgressWithWritten:progress.completedUnitCount total:progress.totalUnitCount];
}

- (void)_processSuccessWithTask:(__kindof NSURLSessionTask *)task object:(id)responseObject{
    [self._delegate httpHasResponseWithHandler:self];
    self._responseData = responseObject;
    [self processSuccessWithData:responseObject];
}

- (void)_processFailureWithTask:(__kindof NSURLSessionTask *)task error:(NSError *)error{
    [self._delegate httpHasResponseWithHandler:self];
    self._responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    [self processFailureWithData:self._responseData error:error];
}

@end


@implementation PSHttpResponseHandler
- (NSStringEncoding)encoding{
    return self._session.requestSerializer.stringEncoding;
}

- (NSInteger)statusCode{
    return ((NSHTTPURLResponse *)self._task.response).statusCode;
}

- (NSURLRequest *)request{
    return self._task.originalRequest;
}

- (NSURLResponse *)response{
    return self._task.response;
}

- (NSData *)responseData{
    return self._responseData;
}

- (void)processSuccessWithData:(NSData *)data{}
- (void)processFailureWithData:(NSData *)data error:(NSError *)error{}
- (void)processProgressWithWritten:(long long)bytesWritten total:(long long)totalBytesExpectedToWrite{};
- (BOOL)shouldRetry{ return NO;}

- (void)cancel{
    [self._task cancel];
}

- (void)suspend{
    [self._task suspend];
}

- (void)resume{
    [self._task resume];
}
@end
