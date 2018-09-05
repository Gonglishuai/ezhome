
#import <UIKit/UIKit.h>

@interface SHRequestTool : NSObject

/// cheak 401.
+ (BOOL)statueIsOverdue:(NSInteger)statusCode;

+ (NSDictionary *)addAuthorizationForHeader:(NSDictionary *)header;

// 更新header
+ (NSDictionary *)updateHeader:(NSDictionary *)header
                   withRequest:(NSURLRequest *)request;

// 添加签名参数
+ (NSDictionary *)addXSignForHeader:(NSDictionary *)header
                        withRequest:(NSURLRequest *)request;

/**
 网络请求返回错误信息
 
 @param error NSError
 @return NSString
 */
+ (NSString *)getErrorMessage:(NSError *)error;

@end
