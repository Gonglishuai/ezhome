/**
 * @file    MTPFormCheck.m
 * @brief   表单检验类.
 * @author  Shaco(Jiao)
 * @version 1.0
 * @date    2016-06-02
 *
 */

#import "MTPFormCheck.h"

#define HANZINUM @"^[\u4e00-\u9fa5]{2,10}$"
#define MOBILE @"^(((13[0-9]{1})|14[57]{1}|15[012356789]{1}|17[0678]{1}|18[0-9]{1})+\\d{8})$"
#define EMAIL @"^([a-zA-Z0-9]+[\\-|\\_|\\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[\\-|\\_|\\.]?)*[a-zA-Z0-9]+\\.[a-zA-Z]{2,}$"
#define JURANID @"[0-9]{9}"

@implementation MTPFormCheck

+ (BOOL)checkHanziNumber:(NSString *)string {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", HANZINUM];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (BOOL)chectMobile:(NSString *)string {

    NSString * CJR = @"^1\\d{10}$";
    NSPredicate *regextestcymh = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CJR];
    
    if ([regextestcymh evaluateWithObject:string] == YES) {//要求1开头，11位数字即可
        return YES;
    } else {
        return NO;
    }
    
    
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    BOOL isMatch = [pred evaluateWithObject:string];
//    return isMatch;
    
}

+ (BOOL)checkEmail:(NSString *)string {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (BOOL)chectCharacterLength:(NSString *)string {
    
    if ([string isEqualToString:@""] || string ==nil) {
        return YES;
    }

    NSInteger len = string.length;
    if (len <2 || len > 32) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkJuranID:(NSString *)string {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", JURANID];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

+ (BOOL)checkCommodityNumber:(NSString *)string {
    if ([string isEqualToString:@""] || string ==nil) {
        return YES;
    }
//    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^([0-9]{1,4})$"];
    //[1-9]\d{0,2}
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^((?!0)[0-9]{1,4})$"];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^((?!0)[0-9]{1,4})[\u4e00-\u9fa5]{1,2}$"];
    BOOL isMatch1 = [pred1 evaluateWithObject:string];
    BOOL isMatch2 = [pred2 evaluateWithObject:string];
    if (isMatch1 || isMatch2) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkCommodityDimension:(NSString *)string {
    
    
    NSInteger len = string.length;
    if (len > 32) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkCommodityRemarks:(NSString *)string {
    NSInteger len = string.length;
    if (len > 200) {
        return NO;
    }
    return YES;
}

+ (BOOL)checkNameNumber:(NSString *)string {
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z\u4e00-\u9fa5\\s]{2,20}$"];
//    BOOL isMatch = [pred evaluateWithObject:string];
//   
//    return isMatch;
    
    NSInteger len = string.length;
    if (len <2 || len > 20) {
        return NO;
    }
    return YES;

}

+ (BOOL)checkCommunityName:(NSString *)string {
    NSInteger len = string.length;
    if (len < 2 || len > 16) {
        return NO;
    }
    return YES;
}
@end
