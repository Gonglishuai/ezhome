//
//  ESEditAddressViewModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/29.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESEditAddressViewModel.h"
#import "JRLocationServices.h"
#import "ESAddrerssAPI.h"
#import "CoStringManager.h"

@implementation ESEditAddressViewModel

+ (NSString *)getAddressName:(NSDictionary *)address {
    if (address && [address objectForKey:@"name"]) {
        return [address objectForKey:@"name"];
    }
    return @"";
}

+ (NSString *)getAddressPhone:(NSDictionary *)address {
    if (address && [address objectForKey:@"phone"]) {
        return [address objectForKey:@"phone"];
    }
    return @"";
}

+ (NSString *)getLocation:(NSDictionary *)address {
    @try {
        if (address) {
            NSString *province = [address objectForKey:@"province"];
            NSString *city     = [address objectForKey:@"city"];
            NSString *district = [address objectForKey:@"district"];
            
            NSMutableString *str = [NSMutableString string];
            [str appendString:province ? province : @""];
            [str appendString:city ? [NSString stringWithFormat:@"-%@", city] : @""];
            [str appendString:district ? [NSString stringWithFormat:@"-%@", district] : @""];
            
            return str;
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return @"";
    }
}

+ (NSString *)getAddressDetail:(NSDictionary *)address {
    if (address && [address objectForKey:@"addressInfo"]) {
        return [address objectForKey:@"addressInfo"];
    }
    return @"";
}

+ (BOOL)isDefaultAddress:(NSDictionary *)address {
    if (address && [address objectForKey:@"isPrimary"]) {
        return [[address objectForKey:@"isPrimary"] boolValue];
    }
    return NO;
}

+ (void)saveAddress:(NSDictionary *)addressDict
        withAddress:(ESAddress *)address
        withSuccess:(void(^)(NSString *successMsg))success
         andFailure:(void(^)(NSString *errorMsg))failure {

    if (address) {//更新
        [ESAddrerssAPI updateAddressWithAddressID:address.addressId withAddressInfo:addressDict withSuccess:^{
            if (success) {
                success(@"编辑地址成功!");
            }
        } andFailure:^(NSError *error) {
            NSString *msg = [self getErrorMessage:error];
            if (failure) {
                failure(msg);
            }
        }];
    }else {//新建
        [ESAddrerssAPI createNewAddress:addressDict withSuccess:^{
            if (success) {
                success(@"添加地址成功!");
            }
        } andFailure:^(NSError *error) {
            NSString *msg = [self getErrorMessage:error];
            if (failure) {
                failure(msg);
            }
        }];
    }
}

+ (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = nil;
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

+ (NSMutableDictionary *)getInfoFromAddress:(ESAddress *)address {
    
    if (!address) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //省
        NSString *provinceCode = [JRLocationServices sharedInstance].locationCityInfo.provinceCode;
        NSString *provinceName = [JRLocationServices sharedInstance].locationCityInfo.province;
        //市
        NSString *cityCode = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
        NSString *cityName = [JRLocationServices sharedInstance].locationCityInfo.locatedCityName;
        //区
        NSString *districtCode = [JRLocationServices sharedInstance].locationCityInfo.districtCode;
        NSString *districtName = [JRLocationServices sharedInstance].locationCityInfo.district;
        
        if (provinceCode && ![provinceCode isEqualToString:@""] &&
            provinceName && ![provinceName isEqualToString:@""] &&
            cityCode && ![cityCode isEqualToString:@""] &&
            cityName && ![cityName isEqualToString:@""] &&
            districtCode && ![districtCode isEqualToString:@""] &&
            districtName && ![districtName isEqualToString:@""]) {
            
            [dict setObject:provinceCode forKey:@"provinceCode"];
            [dict setObject:provinceName forKey:@"province"];
            [dict setObject:cityCode forKey:@"cityCode"];
            [dict setObject:cityName forKey:@"city"];
            [dict setObject:districtCode forKey:@"districtCode"];
            [dict setObject:districtName forKey:@"district"];
        }
        
        return dict;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict setObject:@(address.isPrimary) forKey:@"isPrimary"];
    if (address.name) {
        [dict setObject:address.name forKey:@"name"];
    }
    if (address.phone) {
        [dict setObject:address.phone forKey:@"phone"];
    }
    if (address.province) {
        [dict setObject:address.province forKey:@"province"];
    }
    if (address.provinceCode) {
        [dict setObject:address.provinceCode forKey:@"provinceCode"];
    }
    if (address.city) {
        [dict setObject:address.city forKey:@"city"];
    }
    if (address.cityCode) {
        [dict setObject:address.cityCode forKey:@"cityCode"];
    }
    if (address.district) {
        [dict setObject:address.district forKey:@"district"];
    }
    if (address.districtCode) {
        [dict setObject:address.districtCode forKey:@"districtCode"];
    }
    if (address.addressInfo) {
        [dict setObject:address.addressInfo forKey:@"addressInfo"];
    }
    
    return dict;
}

+ (NSMutableDictionary *)updateAddressInfoWithDict:(NSDictionary *)dict
                                   withCurrentInfo:(NSDictionary *)curInfo {
    NSMutableDictionary *address = [NSMutableDictionary dictionaryWithDictionary:curInfo];
    
    if (dict && [dict objectForKey:@"isPrimary"]) {
        [address setObject:[dict objectForKey:@"isPrimary"] forKey:@"isPrimary"];
    }
    if (dict && [dict objectForKey:@"memberId"]) {
        [address setObject:[dict objectForKey:@"memberId"] forKey:@"memberId"];
    }
    if (dict && [dict objectForKey:@"name"]) {
        [address setObject:[dict objectForKey:@"name"] forKey:@"name"];
    }
    if (dict && [dict objectForKey:@"phone"]) {
        [address setObject:[dict objectForKey:@"phone"] forKey:@"phone"];
    }
    if (dict && [dict objectForKey:@"email"]) {
        [address setObject:[dict objectForKey:@"email"] forKey:@"email"];
    }
    if (dict && [dict objectForKey:@"province"]) {
        [address setObject:[dict objectForKey:@"province"] forKey:@"province"];
    }
    if (dict && [dict objectForKey:@"provinceCode"]) {
        [address setObject:[dict objectForKey:@"provinceCode"] forKey:@"provinceCode"];
    }
    if (dict && [dict objectForKey:@"city"]) {
        [address setObject:[dict objectForKey:@"city"] forKey:@"city"];
    }
    if (dict && [dict objectForKey:@"cityCode"]) {
        [address setObject:[dict objectForKey:@"cityCode"] forKey:@"cityCode"];
    }
    if (dict && [dict objectForKey:@"district"]) {
        [address setObject:[dict objectForKey:@"district"] forKey:@"district"];
    }
    if (dict && [dict objectForKey:@"districtCode"]) {
        [address setObject:[dict objectForKey:@"districtCode"] forKey:@"districtCode"];
    }
    if (dict && [dict objectForKey:@"addressInfo"]) {
        [address setObject:[dict objectForKey:@"addressInfo"] forKey:@"addressInfo"];
    }

    return address;
}

+ (NSString *)checkInputWithDict:(NSDictionary *)dict {
    NSString *error = nil;
    if (!dict || ![dict objectForKey:@"name"] || [[dict objectForKey:@"name"] isEqualToString:@""]) {
        error = @"请填写收件人!";
        return error;
    }else {
        NSString *name = [dict objectForKey:@"name"];
        if (name.length < 2 || name.length > 15) {
            error = @"收货人姓名：2-15个字符限制";
            return error;
        }
        if ([CoStringManager stringContainsEmoji:name]) {
            error = @"收货人姓名不符合规则, 请重新输入!";
            return error;
        }
    }
    if (!dict || ![dict objectForKey:@"phone"] || [[dict objectForKey:@"phone"] isEqualToString:@""]) {
        error = @"请填写手机号!";
        return error;
    }else {
        NSString *phone = [dict objectForKey:@"phone"];
        if (phone.length < 11) {
            error = @"手机号码为11位数字";
            return error;
        }
    }
    if (!dict || ![dict objectForKey:@"province"] || [[dict objectForKey:@"province"] isEqualToString:@""] ||
        ![dict objectForKey:@"provinceCode"] || [[dict objectForKey:@"provinceCode"] isEqualToString:@""]) {
        error = @"请选择省、市、区!";
        return error;
    }
    if (!dict || ![dict objectForKey:@"addressInfo"] || [[dict objectForKey:@"addressInfo"] isEqualToString:@""]) {
        error = @"请填写详细地址!";
        return error;
    }else {
        NSString *addressInfo = [dict objectForKey:@"addressInfo"];
        if (addressInfo.length < 5 || addressInfo.length > 60) {
            error = @"详细地址：5-60个字符限制";
            return error;
        }
        if ([CoStringManager stringContainsEmoji:addressInfo]) {
            error = @"详细地址不符合规则, 请重新输入!";
            return error;
        }
    }
    
    return error;
}
@end
