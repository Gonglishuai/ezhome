//
//  ESAddress.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESAddress : NSObject
@property (nonatomic, strong) NSString *addressId;      //地址ID
@property (nonatomic, strong) NSString *memberId;       //用户CAS ID
@property (nonatomic, strong) NSString *name;           //姓名
@property (nonatomic, strong) NSString *phone;          //电话
@property (nonatomic, strong) NSString *email;          //邮箱
@property (nonatomic, strong) NSString *province;       //省
@property (nonatomic, strong) NSString *provinceCode;   //省ID
@property (nonatomic, strong) NSString *city;           //市
@property (nonatomic, strong) NSString *cityCode;       //市ID
@property (nonatomic, strong) NSString *district;       //区
@property (nonatomic, strong) NSString *districtCode;   //区ID
@property (nonatomic, strong) NSString *addressInfo;    //详细地址
@property (nonatomic, strong) NSString *zipcode;        //邮编
@property (nonatomic, assign) BOOL isPrimary;           //是否为默认地址
@property (nonatomic, strong) NSString *longitude;      //经度
@property (nonatomic, strong) NSString *latitude;       //纬度
@property (nonatomic, strong) NSString *createTime;     //创建时间
@property (nonatomic, strong) NSString *lastUpdate;     //最后更新时间

+ (instancetype)objFromDict: (NSDictionary *)dict;
@end
