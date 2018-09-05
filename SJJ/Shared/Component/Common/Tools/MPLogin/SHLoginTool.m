
#import "SHLoginTool.h"
#import "SHMemberModel.h"
#import "SHFileUtility.h"
#import <ESFoundation/UMengServices.h>
#import "MBProgressHUD.h"

#define LOGIN_RECORD_INDORMATION @"APP_SETTING/LOGIN_RECORD_INDORMATION"
#define LOGIN_RECORD_INDORMATION_NAME @"member_record.plist"

@implementation SHLoginTool

+ (void)saveNickName:(NSString *)nick_name {
    if (!nick_name || ![nick_name isKindOfClass:[NSString class]])
        nick_name = @"";
    [JRKeychain saveSingleInfo:nick_name infoCode:UserInfoCodeName];
}

+ (void)checkMemberTypeWithUpdate:(void(^)(NSString *))update
{
//    [[SHRNAPIManager sharedInstance] getMemberTypeSucces:^(NSDictionary *dict) {
//        if (dict                                      &&
//            [dict isKindOfClass:[NSDictionary class]] &&
//            dict[@"userType"]                        &&
//            [dict[@"userType"] isKindOfClass:[NSString class]])
//        {
//            if ([[JRKeychain loadSingleUserInfo:UserInfoCodeType] isEqualToString:dict[@"userType"]])
//                return ;
//
//            // 如果用户类型发生改变, 则回调新的用户类型
//            if (update)
//                update(dict[@"userType"]);
//        }
//    } failure:^(NSError *error) {
//        SHLog(@"获取用户类型信息失败");
//        if (update) {
//            update(nil);
//        }
//    }];
}

+ (void)saveLoginAvatar:(NSString *)avatar
                account:(NSString *)account
{
    NSDictionary *localDict = [self getLoginRecordInformation];
    NSMutableDictionary *dict = nil;
    if (localDict)
    {
        dict = [localDict mutableCopy];
    }
    else
    {
        dict = [NSMutableDictionary dictionaryWithDictionary:@{@"avatar":@"",@"account":@""}];
    }
    
    NSInteger paramCount = 0;
    
    if (avatar && [avatar isKindOfClass:[NSString class]])
    {
        if (![avatar isEqualToString:dict[@"avatar"]])
        {
            paramCount++;
            [dict setObject:avatar forKey:@"avatar"];
        }
    }
    
    if (account && [account isKindOfClass:[NSString class]])
    {
        if (![account isEqualToString:dict[@"account"]])
        {
            paramCount++;
            [dict setObject:account forKey:@"account"];
        }
    }
    
    if (paramCount==0)
        return;
    
    NSString *path = [SHFileUtility createFolderInDocDir:LOGIN_RECORD_INDORMATION];
    NSString *localFilePath = [path stringByAppendingPathComponent:LOGIN_RECORD_INDORMATION_NAME];
    BOOL status = [dict writeToFile:localFilePath atomically:YES];
    if (status)
    {
        SHLog(@"写入成功");
    }
    else
    {
        SHLog(@"写入失败");
    }
}

+ (void)updateMobileAccount:(NSString *)account
{
    NSDictionary *localDict = [self getLoginRecordInformation];
    if (localDict)
    {
        if ([self checkMobile:localDict[@"account"]])
        {
            [self saveLoginAvatar:nil account:account];
        }
    }
}

+ (NSDictionary *)getLoginRecordInformation
{
    NSString *path = [[SHFileUtility getDocumentDirectory] stringByAppendingPathComponent:LOGIN_RECORD_INDORMATION];
    NSString *localFilePath = [path stringByAppendingPathComponent:LOGIN_RECORD_INDORMATION_NAME];
    
    if (![SHFileUtility isFileExist:localFilePath])
        return nil;
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:localFilePath];
    if ([dict isKindOfClass:[NSDictionary class]])
        return dict;
    
    return nil;
}

#pragma mark - Methods
+ (BOOL)checkMobile:(NSString *)mobile
{
    if (!mobile ||
        ![mobile isKindOfClass:[NSString class]])
        return NO;
    
    if (mobile.length != 11)
        return NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"0?(1)[0-9]{10}"];
    BOOL isMatchName = [predicate evaluateWithObject:mobile];
    return isMatchName;
}

@end
