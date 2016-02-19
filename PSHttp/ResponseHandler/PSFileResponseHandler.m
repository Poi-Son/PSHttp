//
//  PSFileResponseHandler.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSFileResponseHandler.h"
#import "PSHttpResponseHandler_Private.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PSFileResponseHandler{
    BOOL _isFirstResume;
}
+ (instancetype)progress:(void (^)(long long, long long))progress success:(void (^)(NSString *, NSData *))success failure:(void (^)(NSError *))failure{
    PSFileResponseHandler *instance = [self new];
    instance.onProgress = progress;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onSuccess, self.onSuccess(self.response.suggestedFilename, data));
    });
}

- (void)processFailureWithData:(NSData *)data error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        doIf(self.onFailure, self.onFailure(error));
    });
}

#pragma mark - 处理断点下载相关的
- (NSString *)_cacheName{
    return [self ps_MD5Encoding:[_downloadRequest.URL absoluteString]];
}

- (void)setDownloadRequest:(NSMutableURLRequest *)downloadRequest{
    _downloadRequest = downloadRequest;
    _isFirstResume = YES;
    
    NSString *tmpDir = NSTemporaryDirectory();
    
    _cacheConfigPath = [tmpDir stringByAppendingPathComponent:[[self _cacheName] stringByAppendingString:@".ps.cfg"]];
}

- (NSData *)cacheConfig{
    return [NSData dataWithContentsOfFile:self.cacheConfigPath];
}

/** 取消下载, 清除缓存 */
- (void)cancel{
    [self suspend];
    
    NSDictionary *cacheConfig = [NSDictionary dictionaryWithContentsOfFile:self.cacheConfigPath];
    NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:cacheConfig[@"NSURLSessionResumeInfoTempFileName"]];
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager changeCurrentDirectoryPath:NSTemporaryDirectory()];
    [manager removeItemAtPath:dataPath error:nil];
}

/** 暂停下载, 将已下载的数据写入缓存 */
- (void)suspend{
    NSURLSessionDownloadTask *task = self._task;
    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [resumeData writeToFile:self.cacheConfigPath atomically:YES];
    }];
}

/** 恢复下载 */
- (void)resume{
    self._task = [self._session downloadTaskWithResumeData:self.cacheConfig
                                                  progress:^(NSProgress * _Nonnull downloadProgress) {
                                                      [self _processProgress:downloadProgress];
                                                  }
                                               destination:nil
                                         completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                             if (error) {
                                                 [self _processFailureWithTask:self._task error:error];
                                             }else{
                                                 [self _processSuccessWithTask:self._task object:[NSData dataWithContentsOfURL:filePath]];
                                             }
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                         }];
    [self._task resume];
}

- (NSString *)ps_MD5Encoding:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1],
            result[2], result[3],
            result[4], result[5],
            result[6], result[7],
            result[8], result[9],
            result[10], result[11],
            result[12], result[13],
            result[14], result[15]
            ];
}
@end
