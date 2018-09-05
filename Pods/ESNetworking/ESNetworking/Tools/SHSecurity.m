
#import "SHSecurity.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SHSecurity

+(NSString *)md5String:(NSString *)str
             isShorter:(NSInteger)isShorter
{
    if (!str)
        return nil;
    
    const char *cString = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cString, (CC_LONG)strlen(cString), result);
    NSMutableString *resultString = [[NSMutableString alloc]init];
    for (int i = 0;i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [resultString  appendFormat:@"%02x",result[i]];
    }

    NSString *returnStr = [resultString copy];
    if (isShorter && resultString.length>=32)
    {
        returnStr = [returnStr substringWithRange:NSMakeRange(8, 16)];
    }
    
    return returnStr;
}

@end
