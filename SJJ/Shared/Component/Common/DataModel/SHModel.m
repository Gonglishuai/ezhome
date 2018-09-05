
#import "SHModel.h"
#import "JRKeychain.h"

@implementation SHModel

//+ (void)getDataWithParameters:(NSDictionary *)dictionary success:(void(^) (NSArray *array))success failure:(void(^) (NSError *error))failure {
//
//}

//+ (NSString *)GetMemberSecssion {
//    
//    return ([SHAppGlobal AppGlobal_GetMemberInfoObj]).acs_x_session;
//    
//}
//
//+ (NSString *)GetMemberACSToken {
//    SHMember* member=[SHAppGlobal AppGlobal_GetMemberInfoObj];
//    return member.ACS_Token;
//}
//
//+ (NSString *)GetMemberType {
//    SHMember* member=[SHAppGlobal AppGlobal_GetMemberInfoObj];
//    return member.memberType;
//}
//
+ (NSString *)getAuthorization {
    return [NSString stringWithFormat:@"Basic %@",[JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];//[SHAppGlobal AppGlobal_GetMemberInfoObj].X_Token];
}
//
//+ (NSString *)GetMemberToken {
//    SHMember* member=[SHAppGlobal AppGlobal_GetMemberInfoObj];
//    return member.X_Token;
//}
//
//+ (NSString *)GetHsUid {
//    SHMember* member=[SHAppGlobal AppGlobal_GetMemberInfoObj];
//    return member.hs_uid;
//}
//
//+ (NSString *)GetMemberID {
//    SHMember* member=[SHAppGlobal AppGlobal_GetMemberInfoObj];
//    return member.acs_member_id;
//}

+ (NSDictionary *)getHeaderAuthorization {
    return @{HEADER_AUTHORIZATION_KEY : [self getAuthorization]};
}

/// 获取请求头,Authorization和hs_uid
+ (NSDictionary *)getHeaderAuthorizationHsUid {
    return @{HEADER_AUTHORIZATION_KEY : [self getAuthorization],
             HEADER_HS_UID            : [JRKeychain loadSingleUserInfo:UserInfoCodeUid]};//[self GetHsUid]};
}

+ (NSDictionary *)getHeaderHsUid {
    return @{HEADER_HS_UID : [JRKeychain loadSingleUserInfo:UserInfoCodeUid]};//[self GetHsUid]};
}

+ (void)CheckFormatException:(NSString *)str {
    
    
    SHLog(@"%@",[NSString stringWithFormat:@"%@",str]);
}

+ (NSString *)toString:(NSString *)instr {
    
    NSString * data=instr;
    
    if (data==nil)
    {
        [self CheckFormatException:@"string error"];
        return @"err";
    }
    return data;
}

+(BOOL) stringIsNumeric:(NSString *) str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    
    return !!number; // If the string is not numeric, number will be nil
}

+ (NSInteger )toNsInt:(NSString *)inData default:(NSInteger )val {
    
    
    if (inData==nil)
    {
        [self CheckFormatException:@"int error"];
        return val;
    }
    
    if (![SHModel stringIsNumeric:inData])
    {
        [self CheckFormatException:@"int error"];
        return val;
    }
    
    NSInteger IntVal=[inData integerValue];
    
    
    return IntVal;
}

/// Get the current time.
- (NSString*)getRequrieDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}


+(NSString *)formatDic:(id)obj {
    
    if ([obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    NSString *string =[NSString stringWithFormat:@"%@",obj];
    NSString *strUrls = [string stringByReplacingOccurrencesOfString:@"<null>" withString:@""];

    NSString *strUrl = [strUrls stringByReplacingOccurrencesOfString:@"null" withString:@""];
    
    return strUrl;
}

+(NSString *)addressToForm:(NSString *)string {
    
    NSString *address = nil;
    if ([string isEqualToString:@"none"]||[string isEqualToString:@"0"]) {
        address = @"";
    }else {
        address = [SHModel formatDic:string];;
        
    }

    return address;
}
@end
