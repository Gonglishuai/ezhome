
#import "ESHTTPSessionManager.h"

@interface ESHTTPSessionManager()

@end

@implementation ESHTTPSessionManager

+ (instancetype)sharedInstance
{
    static ESHTTPSessionManager *s_request = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        s_request = [[super allocWithZone:NULL] init];
    });
    
    return s_request;
}


///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [ESHTTPSessionManager sharedInstance];
}

///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone
{
    return [ESHTTPSessionManager sharedInstance];
}

- (NSMutableDictionary *)defaultHeader {
    if (_defaultHeader == nil) {
        _defaultHeader = [NSMutableDictionary dictionary];
    }
    return _defaultHeader;
}

- (AFHTTPSessionManager *)manager
{
    if (_manager == nil)
    {
        // 设计家https证书
        NSString *cerPath=[[NSBundle mainBundle]pathForResource:@"shejijia" ofType:@"cer"];
        NSData *cerData=[NSData dataWithContentsOfFile:cerPath];
        NSSet *cerSet=[NSSet setWithObjects:cerData, nil];
        AFSecurityPolicy *securityPolicy=[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [securityPolicy setPinnedCertificates:cerSet];
        
        // 初始化网络请求对象
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 20.0f;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                              @"application/json",
                                                              @"text/json",
                                                              @"text/javascript",
                                                              @"text/html",
                                                              @"audio/mpeg",
                                                              @"text/plain",
                                                              @"binary/octet-stream",
                                                              nil];
    }
    return _manager;
}

- (void)initDefaultHeader:(NSDictionary *)defaultHeader {
    if (defaultHeader != nil) {
        [ESHTTPSessionManager sharedInstance].defaultHeader = [NSMutableDictionary dictionaryWithDictionary:defaultHeader];
    }
}

- (NSDictionary *)getRequestHeader:(NSDictionary *)header {
    NSMutableDictionary *dict = [[ESHTTPSessionManager sharedInstance].defaultHeader mutableCopy];
    @try {
        if (header != nil) {
            [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [dict setObject:obj forKey:key];
            }];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    } @finally {
        return [dict copy];
    }
    
}
@end

