
#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface ESHTTPSessionManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, strong) NSMutableDictionary *defaultHeader;

+ (instancetype)sharedInstance;

/**
 初始化默认头
 
 @param defaultHeader 默认头
 */
- (void)initDefaultHeader:(NSDictionary *)defaultHeader;

- (NSDictionary *)getRequestHeader:(NSDictionary *)header;

@end
