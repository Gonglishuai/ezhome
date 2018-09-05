
#import <Foundation/Foundation.h>

@interface SHSecurity : NSObject

/**
 * MD5加密 isShorter Yes 16 ,  NO 32
 */
+(NSString *)md5String:(NSString *)str
             isShorter:(NSInteger)isShorter;

@end
