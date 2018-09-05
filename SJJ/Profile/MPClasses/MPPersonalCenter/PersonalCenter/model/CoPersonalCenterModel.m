//
//  CoPersonalCenterModel.m
//  Consumer
//
//  Created by Jiao on 16/7/13.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoPersonalCenterModel.h"
#import "JRKeychain.h"
#import "ESMemberAPI.h"
#import "ESMemberInfo.h"

@implementation CoPersonalCenterModel

///获取当前登录者信息
+ (void)getMemberInfoWithSuccess:(void(^)(CoPersonalCenterModel *model))success
                  andUnreadCount:(void(^)(NSInteger count))unread
                      andFailure:(void(^)(NSError *error))failure {
    
    NSString *j_member_id = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    
    [ESMemberAPI getMemberInfoWithID:j_member_id andSucceess:^(NSDictionary *dict) {
        CoPersonalCenterModel *pcModel = [[CoPersonalCenterModel alloc] init];

        ESMemberInfo *member = [ESMemberInfo objFromDict:dict];
        
        pcModel.headIconLink    = member.basic.avatar;
        pcModel.userName        = member.basic.nickName;
        pcModel.mobile_number   = member.basic.mobileNumber;
        pcModel.pointAmount     = member.extension.pointAmount;
        pcModel.couponsAmount   = member.extension.couponsAmount;
        
        pcModel.code   = member.extension.code;
        pcModel.ablAmt   = member.extension.ablAmt;
        pcModel.limitAmt   = member.extension.limitAmt;
        pcModel.status   = member.extension.status;
        pcModel.statusName   = member.extension.statusName;
        pcModel.creditStatus   = member.extension.creditStatus;
        pcModel.creditLimitAmt   = member.extension.creditLimitAmt;
        pcModel.prodId   = member.extension.prodId?member.extension.prodId:@"";
        pcModel.limitAmountInfo   = member.extension.limitAmountInfo?member.extension.limitAmountInfo:@"";
        pcModel.statusInfo   = member.extension.statusInfo?member.extension.statusInfo:@"";
        pcModel.validLimit   = member.extension.validLimit?member.extension.validLimit:@"";
        pcModel.canRecommend   = member.extension.canRecommend;
        
        [JRKeychain saveSingleInfo:pcModel.mobile_number infoCode:UserInfoCodePhone];
        [JRKeychain saveSingleInfo:pcModel.userName infoCode:UserInfoCodeName];
        [JRKeychain saveSingleInfo:pcModel.headIconLink infoCode:UserInfoCodeAvatar];
        
        if (success) {
            success(pcModel);
        }
    } andFailure:failure];

    
}
@end
