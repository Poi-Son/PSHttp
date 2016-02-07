//
//  PSHttpResponseHandler_Private.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <PSHttp/PSHttp.h>
#import "AFNetworking.h"
#import "convenientmacros.h"

@interface PSHttpResponseHandler (Private)
@property (nonatomic, strong) __kindof NSURLSessionTask *_task;
@property (nonatomic, weak) AFHTTPSessionManager *_session;
@property (nonatomic, weak) id<PSHttpDelegate> _delegate;

- (void)_processSuccessWithTask:(__kindof NSURLSessionTask *)task object:(id)responseObject;
- (void)_processFailureWithTask:(__kindof NSURLSessionTask *)task error:(NSError *)error;
- (void)_processProgress:(NSProgress *)progress;
@end
