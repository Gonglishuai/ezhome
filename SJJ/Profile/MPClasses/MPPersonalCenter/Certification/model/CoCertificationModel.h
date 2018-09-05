//
//  CoCertificationModel.h
//  Consumer
//
//  Created by Jiao on 16/7/14.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "SHModel.h"

typedef NS_ENUM(NSInteger, CertificationType) {
    CerTypeForNone = 0,         //未知
    CerTypeForUnaudited,        //未审核
    CerTypeForInProgress,       //审核中
    CerTypeForFailed,           //审核未通过
    CerTypeForPassed,           //审核通过
};

typedef NS_ENUM(NSInteger, CertificationHighType) {
    CerHighTypeForNone = 0,         //未知
    CerHighTypeForUnaudited,        //-1 未认证
    CerHighTypeForInProgress,       //0  认证中
    CerHighTypeForFailed,           //1 认证失败
    CerHighTypeForPassed,           //2 认证通过
};
@interface CoCertificationModel : SHModel

@property (nonatomic, assign) CertificationType cerType;
@property (nonatomic, assign) CertificationHighType cerHighType;

+ (CertificationType)getCertificationTypeWithAuditStatus:(NSString *)audit_status;
+ (CertificationHighType)getCertificationHighTypeWithAuditStatus:(NSString *)high_level_audit_status;

@end
