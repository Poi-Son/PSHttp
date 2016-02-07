//
//  PSHttp.m
//  PSExtensions
//
//  Created by PoiSon on 15/9/22.
//  Copyright (c) 2015年 yerl. All rights reserved.
//

#import "PSHttp.h"
#import "AFNetworking.h"
#import "PSHttpResponseHandler_Private.h"

@interface PSHttp()
@property (nonatomic, strong) AFHTTPSessionManager *session;
@end

@implementation PSHttp
static PSHttp *_instance;
static PSHttp *instance(){
    return _instance ?: ({_instance = [[PSHttp alloc] initWithBaseUrl:nil]; });
}

static NSString *baseUrl;
static id<PSHttpDelegate> _delegate;
static PSNetworkStatus _status;

+ (void)load{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        _status = (PSNetworkStatus)status;
        doIf([_delegate respondsToSelector:@selector(reachabilityChanged:)], [_delegate reachabilityChanged:(PSNetworkStatus)status]);
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (PSNetworkStatus)networkStatus{
    return _status;
}

- (instancetype)initWithBaseUrl:(NSURL *)baseUrl{
    if (self = [super init]) {
        self.session = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
        self.session.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.session.securityPolicy.allowInvalidCertificates = YES;
        self.session.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

+ (AFHTTPRequestSerializer *)_serializerWithEncoding:(NSStringEncoding)encoding{
    static NSMutableDictionary<NSNumber *, AFHTTPRequestSerializer *> *serializerCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializerCache = [NSMutableDictionary new];
    });
    
    AFHTTPRequestSerializer *serializer = [serializerCache objectForKey:@(encoding)];
    if (serializer == nil) {
        serializer = [AFHTTPRequestSerializer serializer];
        serializer.stringEncoding = encoding;
        [serializerCache setObject:serializer forKey:@(encoding)];
    }
    return serializer;
}

+ (void)setDelegate:(id<PSHttpDelegate>)delegate{
    _delegate = delegate;
}

+ (void)reinitWithBaseURL:(NSURL *)url{
    _instance = [[PSHttp alloc] initWithBaseUrl:url];
}

+ (NSURL *)baseURL{
    return instance().session.baseURL;
}

+ (instancetype)clientWithEncoding:(NSStringEncoding)encoding{
    PSHttp *client = instance();
    [client.session setRequestSerializer:[self _serializerWithEncoding:encoding]];
    return client;
}

+ (instancetype)UTF8Client{
    return [self clientWithEncoding:NSUTF8StringEncoding];
}

+ (instancetype)GB18030_2000Client{
    return [self clientWithEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
}

- (void)setupHandler:(PSHttpResponseHandler *)handler withTask:(NSURLSessionTask *)task{
    handler._task = task;
    handler._session = self.session;
    handler._delegate = _delegate;
}

- (PSHttpResponseHandler *)GET:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session GET:URL
                                        parameters:params
                                          progress:^(NSProgress * _Nonnull downloadProgress) {
                                              [handler _processProgress:downloadProgress];
                                          }
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                               [handler _processSuccessWithTask:task object:responseObject];
                                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                           }
                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                               [handler _processFailureWithTask:task error:error];
                                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                           }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)HEAD:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session HEAD:URL
                                         parameters:params
                                            success:^(NSURLSessionDataTask * _Nonnull task) {
                                                [handler _processSuccessWithTask:task object:nil];
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                [handler _processFailureWithTask:task error:error];
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)POST:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session POST:URL
                                         parameters:params
                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                               [handler _processProgress:uploadProgress];
                                           }
                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                [handler _processSuccessWithTask:task object:responseObject];
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            }
                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                [handler _processFailureWithTask:task error:error];
                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)PUT:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session PUT:URL
                                        parameters:params
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                               [handler _processSuccessWithTask:task object:responseObject];
                                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                           }
                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                               [handler _processFailureWithTask:task error:error];
                                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                           }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)PATCH:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session PATCH:URL
                                          parameters:params
                                             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                 [handler _processSuccessWithTask:task object:responseObject];
                                                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             }
                                             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                 [handler _processFailureWithTask:task error:error];
                                                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)DELETE:(NSString *)URL params:(id)params handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session DELETE:URL
                                           parameters:params
                                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                  [handler _processSuccessWithTask:task object:responseObject];
                                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                              }
                                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                  [handler _processFailureWithTask:task error:error];
                                                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                              }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)REQUEST:(NSURLRequest *)request handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                     if (!error) {
                                                         [handler _processSuccessWithTask:task object:responseObject];
                                                     }else{
                                                         [handler _processFailureWithTask:task error:error];
                                                     }
                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                 }];
    [self setupHandler:handler withTask:task];
    return handler;
}

- (PSHttpResponseHandler *)UPLOAD:(NSString *)URL params:(id)params data:(NSData *)data filename:(NSString *)filename handler:(PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableURLRequest *request = [self.session.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                        URLString:URL
                                                                                       parameters:params
                                                                        constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                                            [formData appendPartWithFormData:data name:filename];
                                                                        } error:nil];

    NSURLSessionUploadTask *task = [self.session uploadTaskWithStreamedRequest:request
                                                                      progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                          [handler _processProgress:uploadProgress];
                                                                      }
                                                             completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                                 if (error) {
                                                                     [handler _processFailureWithTask:task error:error];
                                                                 }else{
                                                                     [handler _processSuccessWithTask:task object:responseObject];
                                                                 }
                                                                 
                                                                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                             }];
    [self setupHandler:handler withTask:task];
    [handler resume];
    return handler;
}

- (PSHttpResponseHandler *)DOWNLOAD:(NSString *)URL params:(id)params handler:(__kindof PSHttpResponseHandler *)handler{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest *request = [[self.session requestSerializer] requestWithMethod:@"GET"
                                                                             URLString:[[NSURL URLWithString:URL relativeToURL:[[self class] baseURL]] absoluteString]
                                                                            parameters:params
                                                                                 error:nil];
    
    //如果是PSFileResponseHander, 则支持断点续传
    if ([handler isKindOfClass:[PSFileResponseHandler class]]) {
        PSFileResponseHandler *fileHandler = handler;
        fileHandler.downloadRequest = request;
        //如果之前已经有下载的, 则继续下载
        if (fileHandler.cacheConfig.length) {
            [self setupHandler:handler withTask:nil];
            [fileHandler resume];
            return handler;
        }
    }
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request
                                                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                      [handler _processProgress:downloadProgress];
                                                                  }
                                                               destination:nil
                                                         completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                             if (error) {
                                                                 [handler _processFailureWithTask:task error:error];
                                                             }else{
                                                                 [handler _processSuccessWithTask:task object:[NSData dataWithContentsOfURL:filePath]];
                                                             }
                                                             
                                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                         }];
    
    [self setupHandler:handler withTask:task];
    [task resume];
    return handler;
}
@end
