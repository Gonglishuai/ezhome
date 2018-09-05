
#import <Foundation/Foundation.h>

#define HEADER_AUTHORIZATION_KEY @"Authorization"
#define HEADER_HS_UID @"hs_uid"

@interface SHModel : NSObject

//+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void(^) (NSArray *array))success failure:(void(^) (NSError *error))failure;

/// 获取请求头,只有X-Token
+ (NSDictionary *)getHeaderAuthorization;

/// 获取请求头,Authorization和hs_uid
+ (NSDictionary *)getHeaderAuthorizationHsUid;

/// 获取请求头,只有hs_uid
+ (NSDictionary *)getHeaderHsUid;
//
///// 获取当前用户的id
//+ (NSString *)GetMemberID;

+ (NSString *)toString:(NSString *)instr;
+ (NSInteger )toNsInt:(NSString *)inData default:(NSInteger )val;

/// 获得当前时间.
- (NSString*)getRequrieDate;

+(NSString *)formatDic:(id)obj;
+(NSString *)addressToForm:(NSString *)string;

@end
