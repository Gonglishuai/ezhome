//
//  CoCertificationModel.m
//  Consumer
//
//  Created by Jiao on 16/7/14.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCertificationModel.h"
#import "JRKeychain.h"
#import "SHCenterTool.h"

@implementation CoCertificationModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSString *audit_status = [NSString stringWithFormat:@"%@",dict[@"audit_status"]];
        self.cerType = [CoCertificationModel getCertificationTypeWithAuditStatus:audit_status];
        
        NSString *high_level_audit_status = [NSString stringWithFormat:@"%@",dict[@"high_level_audit_status"]];
        self.cerHighType = [CoCertificationModel getCertificationHighTypeWithAuditStatus:high_level_audit_status];
    }
    return self;
}

+ (CertificationType)getCertificationTypeWithAuditStatus:(NSString *)audit_status {
    CertificationType type = CerTypeForNone;
    if (audit_status) {
        switch ([audit_status integerValue]) {
            case 0:
                type = CerTypeForInProgress;
                break;
            case 1:
                type = CerTypeForFailed;
                break;
            case 2:
                type = CerTypeForPassed;
                break;
            case 3:
                type = CerTypeForUnaudited;
                break;
                
            default:
                break;
        }
        if ([audit_status isKindOfClass:[NSNull class]] || [audit_status isEqualToString:@""] || [audit_status rangeOfString:@"null"].location != NSNotFound) {
            type = CerTypeForUnaudited;
        }
    }
    
    return type;
}

+ (CertificationHighType)getCertificationHighTypeWithAuditStatus:(NSString *)high_level_audit_status {
    CertificationHighType type = CerHighTypeForNone;
    if (high_level_audit_status) {
        switch ([high_level_audit_status integerValue]) {
            case 0:
                type = CerHighTypeForInProgress;
                break;
            case 1:
                type = CerHighTypeForFailed;
                break;
            case 2:
                type = CerHighTypeForPassed;
                break;
            case -1:
                type = CerHighTypeForUnaudited;
                break;
                
            default:
                break;
        }
        if ([high_level_audit_status isKindOfClass:[NSNull class]] || [high_level_audit_status isEqualToString:@""] || [high_level_audit_status rangeOfString:@"null"].location != NSNotFound) {
            type = CerHighTypeForUnaudited;
        }
    }
    
    return type;
}



@end
