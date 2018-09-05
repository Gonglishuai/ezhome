
#import "ESSignatureUtil.h"
#import "SHSecurity.h"

#define ACCESS_KEY @"bcc22eecaa445676"
#define SECRET_ACCESS_KEY @"ed0f1133bcc22eecaa445676ca8f1d14"

@implementation ESSignatureUtil

/// 获取X-Sign Value
+ (NSString *)getXSignValueWithRequest:(NSURLRequest *)request
{
    NSString *timeInterval = [NSString stringWithFormat:@"%.lf", [[NSDate date] timeIntervalSince1970]];
    NSString *signature = [self getSignatureStringWithRequest:request
                                                 timeInterval:timeInterval];
    NSString *format = @"j-auth-v1/%@/%@/%@";
    NSString *value = [NSString stringWithFormat:format,
                       ACCESS_KEY,
                       timeInterval,
                       signature];
    return value;
}

/// 获取加密后的Signature
+ (NSString *)getSignatureStringWithRequest:(NSURLRequest *)request
                               timeInterval:(NSString *)timeInterval
{
    NSString *signingKey = [self getSigningKeyTimeInterval:timeInterval];
    NSString *canonicalRequest = [self getCanonicalRequest:request];
    NSString *originalSignature = [signingKey stringByAppendingString:canonicalRequest];
    NSString *signature = [[SHSecurity md5String:originalSignature
                                       isShorter:NO] lowercaseString];
    return signature;
}

#pragma mark - CanonicalRequest
/// 获取CanonicalRequest
+ (NSString *)getCanonicalRequest:(NSURLRequest *)request
{
    if (!request
        || ![request isKindOfClass:[NSURLRequest class]])
    {
        return @"";
    }
    
    NSString *httpMethod = [self getHttpMethod:request.HTTPMethod];
    NSString *canonicalURI = [self getCanonicalURI:request.URL.path];
    NSString *canonicalQueryString = [self getCanonicalQueryString:request.URL.query
                                      ];
    NSString *bodyParam = [self getBodyParam:request.HTTPBody];
    
    NSString *canonicalRequest = [NSString stringWithFormat:@"%@%@%@%@",
                                  httpMethod,
                                  canonicalURI,
                                  canonicalQueryString,
                                  bodyParam];
    return canonicalRequest;
}

/// 获取HTTP Method
+ (NSString *)getHttpMethod:(NSString *)httpMethod
{
    if (!httpMethod
        || ![httpMethod isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    return [httpMethod uppercaseString];
}

/// 获取CanonicalURI
+ (NSString *)getCanonicalURI:(NSString *)uri
{
    if (!uri
        || ![uri isKindOfClass:[NSString class]])
    {
        return @"";
    }
    
    return uri;
}

/// 获取BodyParam
+ (NSString *)getBodyParam:(NSData *)bodyData
{
    if (!bodyData
        || ![bodyData isKindOfClass:[NSData class]])
    {
        return @"";
    }
    
    
    NSString *bodyString = [[NSString alloc]initWithData:bodyData
                                                encoding:NSUTF8StringEncoding];
    return bodyString;
}

/// 获取CanonicalQueryString
+ (NSString *)getCanonicalQueryString:(NSString *)originalStr
{
    if (!originalStr
        || ![originalStr isKindOfClass:[NSString class]]
        || originalStr.length <= 0)
    {
        return @"";
    }
    
    NSArray *arrOriginal = [originalStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (NSString *str in arrOriginal)
    {
        if ([str isKindOfClass:[NSString class]])
        {
            NSArray *arrKeyValue = [str componentsSeparatedByString:@"="];
            if (arrKeyValue.count >= 2)
            {
                [dictM setObject:arrKeyValue[1]
                          forKey:arrKeyValue[0]];
            }
            //            else
            //            {
            //                [dictM setObject:@""
            //                          forKey:[arrKeyValue firstObject]];
            //            }
        }
    }
    
    NSArray *keys = [dictM allKeys];
    NSArray *sortKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
                         {
                             return [obj1 compare:obj2 options:NSNumericSearch];
                         }];
    
    NSString *canonicalQueryString = @"";
    for (NSString *key in sortKeys)
    {
        NSString *value = dictM[key];
        NSString *format = @"&%@=%@";
        if (!value
            || value.length <= 0)
        {
            continue;
        }
        // 因java和Oc对url中特殊字符utf8的规则不一致, 此处拼接加密字串时先进性解码
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *str = [NSString stringWithFormat:format, key, value];
        canonicalQueryString = [canonicalQueryString stringByAppendingString:str];
    }
    
    if (canonicalQueryString.length > 0)
    {
        canonicalQueryString = [canonicalQueryString substringFromIndex:1];
    }
    
    return canonicalQueryString;
}

#pragma mark - AuthStringPrefix
/// 获取加密后的认证字符串的前缀部分
+ (NSString *)getSigningKeyTimeInterval:(NSString *)timeInterval
{
    NSString *authStringPrefix = [self getAuthStringPrefixTimeInterval:timeInterval];
    NSString *originalKey = [SECRET_ACCESS_KEY stringByAppendingString:authStringPrefix];
    NSString *signingKey = [[SHSecurity md5String:originalKey
                                        isShorter:NO] lowercaseString];
    return signingKey;
}

/// 认证字符串的前缀部分
+ (NSString *)getAuthStringPrefixTimeInterval:(NSString *)timeInterval
{
    NSString *authStringPrefixFormat = @"j-auth-v1/%@/%@";
    NSString *authStringPrefix = [NSString stringWithFormat:authStringPrefixFormat,
                                  ACCESS_KEY,
                                  timeInterval];
    return authStringPrefix;
}

@end

