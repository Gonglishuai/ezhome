//
//  ESMemberInfo.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMemberBaseInfo.h"
#import "ESMemberExtension.h"

@interface ESMemberInfo : NSObject

@property (nonatomic, strong) ESMemberBaseInfo *basic;          // 基础信息
@property (nonatomic, strong) ESMemberExtension *extension;   // 扩展信息

+ (instancetype)objFromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictFromObj:(ESMemberInfo *)obj;

@end
