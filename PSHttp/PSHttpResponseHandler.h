//
//  PSHttpResponseHandler.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/23.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PSHttpResponseHandler : NSObject
@property (nonatomic, readonly) NSStringEncoding encoding;/**< 编码 */
@property (nonatomic, readonly) NSInteger statusCode;/**< 状态码 */
@property (nonatomic, readonly, nullable) __kindof NSURLRequest *request;
@property (nonatomic, readonly, nullable) __kindof NSURLResponse *response;
@property (nonatomic, readonly, nullable) NSData *responseData;

//以下函数在被调用时, 仍处于异步线程中, 不要在此线程中更新UI
- (void)processSuccessWithData:(nullable NSData *)data;/**< 处理成功数据 */
- (void)processFailureWithData:(nullable NSData *)data error:(NSError *)error;/**< 处理失败数据 */
- (void)processProgressWithWritten:(long long)bytesWritten/*当前一共写入的量*/ total:(long long)totalBytesExpectedToWrite/*期望一共写入的量*/;/**< 处理下传或下载过程 */
- (BOOL)shouldRetry;/**< 失败时是否重试, 默认NO */

- (void)cancel;/**< 取消 */
- (void)suspend;/**< 暂停 */
- (void)resume;/**< 恢复 */
@end
NS_ASSUME_NONNULL_END