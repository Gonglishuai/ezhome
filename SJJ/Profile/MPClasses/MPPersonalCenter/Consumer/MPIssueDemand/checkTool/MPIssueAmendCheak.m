
#import "MPIssueAmendCheak.h"

#define SPACE_PATTERN @"^\\s{1,}$"
#define COMMUNITY_PATTERN @"^[A-Za-z0-9\u4e00-\u9fa5]+$"
#define DECIMAL_PATTERN @"^\\d+(\\.\\d+)?$"
#define PHONE_NUM_PATTERN @"1[3|4|5|7|8|][0-9]{9}"
#define NICK_NAME_PATTERN @"^^\\S[a-zA-Z\\s\\d\\u4e00-\\u9fa5]{1,20}$"
#define DETAIL_ADDRESS_PATTERN @"[a-zA-Z0-9\u4e00-\u9fa5]+$"


@implementation MPIssueAmendCheak

+ (void)showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle : @"提示"
                                message : message
                               delegate : nil
                      cancelButtonTitle : @"确定"
                      otherButtonTitles : nil];
    [alert show];
}

+ (BOOL)checkContactsName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",NICK_NAME_PATTERN];
    BOOL isMatchName = [predicate evaluateWithObject:name];
    
    if (name.length == 0 || name == nil){
        [self showAlertViewWithMessage:@"姓名不能为空"];
        return NO;
    }
    
    //控制字符数在2~20
    if (!isMatchName || name.length > 20|| name.length < 2) {
        [self showAlertViewWithMessage:@"姓名应为2-20个中文、英文、数字字符"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkContactsMobile:(NSString *)phoneNumber {
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHONE_NUM_PATTERN];
    BOOL isPhoneNum = [phoneTest evaluateWithObject:phoneNumber];
    
    if (phoneNumber.length == 0 || phoneNumber == nil) {
        [self showAlertViewWithMessage:@"手机号码不能为空"];
        return NO;
    }
    
    if (phoneNumber.length != 11 || !isPhoneNum) {
        [self showAlertViewWithMessage:@"请输入正确的手机号码"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkDesignBudget:(NSString *)designBudget {
    if (designBudget.length == 0) {
        [self showAlertViewWithMessage:@"请选择设计预算"];
        return NO;
    }
    return YES;
}


+ (BOOL)checkRenovationBudget:(NSString *)renovationBudget {
    if (renovationBudget.length == 0) {
        [self showAlertViewWithMessage:@"请选择装修预算"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkHouseArea:(NSString *)houseArea {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", DECIMAL_PATTERN];
    BOOL isMatch = [predicate evaluateWithObject:houseArea];
    NSArray *array = [houseArea componentsSeparatedByString:@"."];
    NSString *str1 = array[0];
    NSString *str2;
    if (array.count >= 2)
        str2 = array[1];
    
    if (!isMatch || str1.length > 4 || ([str1 integerValue] == 0 && [str2 integerValue] == 0) || str2.length >2 || [str1 integerValue] < 1) {
        [self showAlertViewWithMessage:@"房屋面积必须是1到9999之间的值"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkOptionHouseArea:(NSString *)houseArea {
     if (houseArea && houseArea.length !=0) {
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", DECIMAL_PATTERN];
         BOOL isMatch = [predicate evaluateWithObject:houseArea];
         NSArray *array = [houseArea componentsSeparatedByString:@"."];
         NSString *str1 = array[0];
         NSString *str2;
         if (array.count >= 2)
             str2 = array[1];
         if (!isMatch || str1.length > 4 || str2.length >2) {
             [self showAlertViewWithMessage:@"房屋面积必须是1到9999之间的值"];
             return NO;
         }

    }
      return YES;
}


+ (BOOL)checkNeighbourhoods:(NSString *)neighbourhoods {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", COMMUNITY_PATTERN];
    BOOL isMatchDetail = [predicate evaluateWithObject:neighbourhoods];
    if (neighbourhoods.length == 0 || neighbourhoods == nil) {
        [self showAlertViewWithMessage:@"小区名称不能为空"];
        return NO;
    }
    if (neighbourhoods.length < 2 || neighbourhoods.length > 16 || !isMatchDetail) {
        [self showAlertViewWithMessage:@"小区名称应为2-16个中文、英文、数字字符"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkOptionNeighbourhoods:(NSString *)neighbourhoods {
    
    if (neighbourhoods && neighbourhoods.length!=0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", COMMUNITY_PATTERN];
        BOOL isMatchDetail = [predicate evaluateWithObject:neighbourhoods];
        if (neighbourhoods.length <= 1 || neighbourhoods.length >= 33 || !isMatchDetail) {
            [self showAlertViewWithMessage:@"请输入正确的小区名称(字符长度为2-32之间且不包含特殊字符)"];
            return NO;
        }

    }
    
     return YES;
}

+ (BOOL)checkHouseType:(NSString *)houseType {
    if (houseType.length == 0) {
        [self showAlertViewWithMessage:@"请选择房屋类型"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkHouseSize:(NSString *)houseSize {
    if (houseSize.length == 0) {
        [self showAlertViewWithMessage:@"请选择户型"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkRenovationStyle:(NSString *)renovationStyle {
    if (renovationStyle.length == 0) {
        [self showAlertViewWithMessage:@"请选择风格"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAddress:(NSString *)address {
    if (address.length == 0) {
        [self showAlertViewWithMessage:@"请选择地址"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkMeasureTime:(NSString *)measure {
    if (measure == nil) {
        [self showAlertViewWithMessage:@"请选择量房时间"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkDetailedAddress:(NSString *)detailAddress{
    if (detailAddress.length == 0) {
        [self showAlertViewWithMessage:@"详细地址不能为空"];
        return NO;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",DETAIL_ADDRESS_PATTERN];
        BOOL isMatchDetailAddress = [predicate evaluateWithObject:detailAddress];
        //控制字符数在2~20
        if (!isMatchDetailAddress || detailAddress.length <2 || detailAddress.length > 32) {
            [self showAlertViewWithMessage:@"详细地址应为2-32个中文、英文、数字字符"];
            return NO;
        }
    }
    
    return YES;
}

@end
