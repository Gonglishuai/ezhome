
#import "SHCenterTool.h"
#import "SHMemberModel.h"
#import "SHCenterInfo.h"
#import "UIButton+WebCache.h"
#import "MPImages.h"

#define USERINFO @"MPUserInformation"
#define AUDITSTATUS @"mp_designer_auditstatus"

@implementation SHCenterTool

#pragma mark - person info.
+ (void)savePersonCenterInfo:(SHMemberModel *)model {
    SHCenterInfo *info = [self getCenterInfo:model];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info];
    [self writeInUserDefaults:data key:USERINFO];
}

+ (SHMemberModel *)getPersonCenterInfo {
    NSData *data = [self readValueForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [self getMemberModel:info];
}

#pragma mark - set head button.
+ (void)setHeadIcon:(UIButton *)btn
             avator:(NSString *)netAvator
{
    NSString *placeholderImageName = ICON_HEADER_DEFAULT;
    NSString *cacheAvator = [self getCacheAvator];
    if([SHAppGlobal isHaveNetwork])
    {
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:netAvator]
                                 forState:UIControlStateNormal
                         placeholderImage:[UIImage imageNamed:placeholderImageName]
                                  options:SDWebImageRetryFailed] ;
    }
    else
    {
        if (cacheAvator)
        { /// no net can not to set SDWebImageRetryFailed.
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:cacheAvator]
                                     forState:UIControlStateNormal
                             placeholderImage:[UIImage imageNamed:placeholderImageName]];
        }
        else
        {
            [btn setBackgroundImage:[UIImage imageNamed:placeholderImageName]
                           forState:UIControlStateNormal];
        }
    }
}

#pragma mark - audit_status
+ (void)saveAuditStatus:(NSString *)audit_status {
    [self writeInUserDefaults:audit_status key:AUDITSTATUS];
}

+ (NSString *)getAuditStatus {
    return [self readValueForKey:AUDITSTATUS];
}

#pragma mark - nick_name;
+ (NSString *)getNickName {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return info.nick_name;
}

+ (NSString *)getPhoneNum {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return info.mobile_number;
}

+ (void)saveNickName:(NSString *)nick_name {
//    SHCenterInfo *info = [[SHCenterInfo alloc] init];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    info.nick_name = nick_name;
    data = [NSKeyedArchiver archivedDataWithRootObject:info];
    [self writeInUserDefaults:data key:USERINFO];
}

#pragma mark - loho
+ (void)saveIsLoho:(NSString *)is_loho {
    SHCenterInfo *info = [[SHCenterInfo alloc] init];
    info.is_loho = is_loho;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info];
    [self writeInUserDefaults:data key:USERINFO];
}

+ (NSString *)getIsLoho {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return info.is_loho;
}

#pragma mark - method
+ (void)writeInUserDefaults:(id)value key:(NSString *)key {
    NSUserDefaults * UserDefaults = [NSUserDefaults standardUserDefaults];
    [UserDefaults setObject:value forKey:key];
    [UserDefaults synchronize];
}

+ (id)readValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)getCacheAvator {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USERINFO];
    SHCenterInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return info.avatar;
}

+ (SHCenterInfo *)getCenterInfo:(SHMemberModel *)model {
    
    SHCenterInfo *info = [[SHCenterInfo alloc] init];
    info.nick_name          = model.nick_name;
    info.avatar             = model.avatar;
    info.is_loho            = model.is_loho;
    info.hitachi_account    = model.hitachi_account;
    info.gender             = model.gender;
    info.mobile_number      = model.mobile_number;
    info.email              = model.email;
    info.province           = model.province;
    info.city               = model.city;
    info.district           = model.district;
    info.design_price_max   = model.design_price_max;
    info.design_price_min   = model.design_price_min;
    info.measurement_price  = model.measurement_price;
    info.acount             = model.acount;
    info.true_name          = model.true_name;
    info.msgCenter_thread_id= model.thread_id;
    return info;
}

+ (SHMemberModel *)getMemberModel:(SHCenterInfo *)model {
    
    SHMemberModel *info = [[SHMemberModel alloc] init];
    info.nick_name          = model.nick_name;
    info.avatar             = model.avatar;
    info.is_loho            = model.is_loho;
    info.hitachi_account    = model.hitachi_account;
    info.gender             = model.gender;
    info.mobile_number      = model.mobile_number;
    info.email              = model.email;
    info.province           = model.province;
    info.city               = model.city;
    info.district           = model.district;
    info.design_price_max   = model.design_price_max;
    info.design_price_min   = model.design_price_min;
    info.measurement_price  = model.measurement_price;
    info.acount             = model.acount;
    info.true_name          = model.true_name;
    info.thread_id          = model.msgCenter_thread_id;
    return info;
}

@end
