//
//  ESMemberInfoData.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfoData.h"
#import "ESMemberAPI.h"
#import "JRKeychain.h"
#import "MPRegionManager.h"

@implementation ESMemberInfoData

+ (void)getMemberInfoWithSuccess:(void(^)(ESMemberInfo *memberInfo))success
                      andFailure:(void(^)(void))failure {
    NSString *j_member_id = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    
    [ESMemberAPI getMemberInfoWithID:j_member_id andSucceess:^(NSDictionary *dict) {
        
        ESMemberInfo *info = [ESMemberInfo objFromDict:dict];
        if (success) {
            success(info);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (void)getItemContentWithViewModel:(NSArray <ESMemberInfoViewModel *>*)items
                                                   withMemberInfo:(ESMemberInfo *)memberInfo {
    if (items && items.count > 0) {
        for (ESMemberInfoViewModel *obj in items) {
            if ([obj.key isEqualToString:@"nick_name"]) {
                obj.content = memberInfo.basic.nickName;
                continue;
            }
            if ([obj.key isEqualToString:@"user_name"]) {
                obj.content = memberInfo.basic.userName;
                continue;
            }
            if ([obj.key isEqualToString:@"mobile"]) {
                NSString *mobile = memberInfo.basic.mobileNumber;
                if (!mobile || [mobile isEqualToString:@""]) {
                    obj.content = @"未绑定手机";
                }else {
                    obj.content = mobile;
                }
                continue;
            }
            if ([obj.key isEqualToString:@"sex"]) {
                NSString *sex = memberInfo.basic.gender;
                if (sex && [sex isEqualToString:@"1"]) {
                    sex = @"女";
                }else if (sex && [sex isEqualToString:@"2"]) {
                    sex = @"男";
                }else {
                    sex = @"保密";
                }
                obj.content = sex;
                continue;
            }
            if ([obj.key isEqualToString:@"region"]) {
                NSString *region = @"未设置";
                if (memberInfo.basic.province && memberInfo.basic.provinceAbbname &&
                    ![memberInfo.basic.province isEqualToString:@""] && ![memberInfo.basic.provinceAbbname isEqualToString:@""]) {
                    region = [NSString stringWithFormat:@"%@ %@ %@", memberInfo.basic.provinceAbbname, memberInfo.basic.cityAbbname, memberInfo.basic.districtAbbname  ?: @""];
                }
                obj.content = region;
                continue;
            }
            if ([obj.key isEqualToString:@"email"]) {
                NSString *email = memberInfo.basic.email;
                if (email == nil || [email isEqualToString:@""]) {
                    obj.content = @"未绑定邮箱";
                }else {
                    obj.content = email;
                }
                continue;
            }
        }
    }
}

+ (NSString *)getMemberAvatar:(ESMemberInfo *)info {
    if (info && info.basic.avatar) {
        return info.basic.avatar;
    }
    
    return [JRKeychain loadSingleUserInfo:UserInfoCodeAvatar];
}

+ (void)updateMemberAvatar:(UIImage *)image
               withSuccess:(void(^)(NSString *url))success
                andFailure:(void(^)(void))failure {
    
    NSData *dataImage = UIImagePNGRepresentation(image);
    
    [ESMemberAPI updateMemberAvatarWithFile:dataImage witSuccess:^(NSDictionary *dict) {
        if (dict && [dict objectForKey:@"url"]) {
            [JRKeychain saveSingleInfo:[dict objectForKey:@"url"] infoCode:UserInfoCodeAvatar];
        }
        if (success) {
            success([dict objectForKey:@"url"]);
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure();
        }
    }];
}

+ (void)updateMemberNickName:(ESMemberInfo *)memberInfo
                   withItems:(NSArray <ESMemberInfoViewModel *>*)items {
    @try {
        for (ESMemberInfoViewModel *item in items) {
            if ([item.key isEqualToString:@"nick_name"]) {
                memberInfo.basic.nickName = item.content;
                continue;
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (void)updateRegionInfo:(ESMemberInfo *)memberInfo
               withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel
        withProvinceCode:(NSString *)provinceCode
            withCityCode:(NSString *)cityCode
         andDistrictCode:(NSString *)districtCode {
    @try {
        NSDictionary *addressDict = [[MPRegionManager sharedInstance] getRegionWithProvinceCode:provinceCode
                                                                                   withCityCode:cityCode
                                                                                andDistrictCode:districtCode];
        memberInfo.basic.province = provinceCode;
        memberInfo.basic.provinceAbbname = addressDict[@"province"];
        memberInfo.basic.city = cityCode;
        memberInfo.basic.cityAbbname = addressDict[@"city"];
        
        if ([districtCode isEqualToString:@" "]) {
            memberInfo.basic.districtAbbname = @"none";
            memberInfo.basic.district = @"0";
            
        }else {
            memberInfo.basic.district = districtCode;
            memberInfo.basic.districtAbbname = [NSString stringWithFormat:@"%@",addressDict[@"district"]];
        }
        
        for (ESMemberInfoViewModel *item in viewModel) {
            if ([item.key isEqualToString:@"region"]) {
                item.content = [NSString stringWithFormat:@"%@ %@ %@", memberInfo.basic.provinceAbbname, memberInfo.basic.cityAbbname, memberInfo.basic.districtAbbname];
                break;
            }
        }
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (void)updateSexInfo:(ESMemberInfo *)memberInfo
            withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel
            withTitle:(NSString *)title {
    @try {
        if ([title isEqualToString:@"男"]) {
            memberInfo.basic.gender = @"2";
        }else if ([title isEqualToString:@"女"]) {
            memberInfo.basic.gender = @"1";
        }else {
            memberInfo.basic.gender = @"0";
        }
        
        for (ESMemberInfoViewModel *item in viewModel) {
            if ([item.key isEqualToString:@"sex"]) {
                item.content = title;
                break;
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}

+ (void)updateMemberInfo:(ESMemberInfo *)memberInfo
             withSuccess:(void(^)(void))success
              andFailure:(void(^)(NSString *msg))failure {
    @try {
        NSString *error = [self checkInfo:memberInfo];
        NSDictionary *dict = [ESMemberInfo dictFromObj:memberInfo];
        
        if (error || dict == nil) {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        NSString *j_member_id = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
        [ESMemberAPI updataMemberInfoWithID:j_member_id withDict:dict withSuccess:^(NSDictionary *dict) {
            if (success) {
                success();
            }
        } andFailure:^(NSError *error) {
            if (failure) {
                failure(@"保存信息失败, 请稍后重试!");
            }
        }];
        
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        if (failure) {
            failure(@"保存信息失败, 请稍后重试!");
        }
    }
}

+ (void)manageTextField:(UITextField *)textField
                editing:(BOOL)editing
                withKey:(NSString *)key
              withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel {
    @try {
        if (editing) {
            
        }else {
            for (ESMemberInfoViewModel *vm in viewModel) {
                if ([vm.key isEqualToString:key]) {
                    vm.content = textField.text;
                }
            }
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    }
}


+ (NSString *)checkInfo:(ESMemberInfo *)memberInfo {
    NSString *result = nil;
    if (memberInfo.basic.nickName.length < 2 || memberInfo.basic.nickName.length > 20) {
        result = @"昵称应为2-20个字符";
        return result;
    }
    
    return result;
}
@end
