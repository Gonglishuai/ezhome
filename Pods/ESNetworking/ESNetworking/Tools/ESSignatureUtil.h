
#import <Foundation/Foundation.h>

@interface ESSignatureUtil : NSObject

/// 获取签名的值
+ (NSString *)getXSignValueWithRequest:(NSURLRequest *)request;

@end
