//
//  ESMemberBaseInfo.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/2.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  当前用户基础信息

#import <Foundation/Foundation.h>

@interface ESMemberBaseInfo : NSObject

@property (nonatomic, strong) NSString *userName;           // 用户名
@property (nonatomic, strong) NSString *nickName;           // 昵称
@property (nonatomic, strong) NSString *birthday;           // 生日
@property (nonatomic, strong) NSString *mobileNumber;       // 手机号
@property (nonatomic, strong) NSString *gender;             // 性别
@property (nonatomic, strong) NSString *province;           // 省code
@property (nonatomic, strong) NSString *provinceAbbname;    // 省name
@property (nonatomic, strong) NSString *city;               // 市code
@property (nonatomic, strong) NSString *cityAbbname;        // 市name
@property (nonatomic, strong) NSString *district;           // 区code
@property (nonatomic, strong) NSString *districtAbbname;    // 区name
@property (nonatomic, strong) NSString *email;              // 邮箱
@property (nonatomic, strong) NSString *homePhone;          // 固话
@property (nonatomic, strong) NSString *avatar;             // 头像

@end
