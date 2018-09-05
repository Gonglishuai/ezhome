//
//  ESMemberInfoData.h
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  基本信息-数据处理

#import <Foundation/Foundation.h>
#import "ESMemberInfoViewModel.h"
#import "ESMemberInfo.h"

@interface ESMemberInfoData : NSObject

/**
 获取用户信息

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMemberInfoWithSuccess:(void(^)(ESMemberInfo *memberInfo))success
                      andFailure:(void(^)(void))failure;

/**
 获取viewModel内容
 
 @param memberInfo 用户信息
 @return viewModel
 */
+ (void)getItemContentWithViewModel:(NSArray <ESMemberInfoViewModel *>*)items
                                                   withMemberInfo:(ESMemberInfo *)memberInfo;

/**
 获取用户头像

 @param info 用户信息
 @return 头像
 */
+ (NSString *)getMemberAvatar:(ESMemberInfo *)info;

/**
 更新头像

 @param image 头像
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateMemberAvatar:(UIImage *)image
               withSuccess:(void(^)(NSString *url))success
                andFailure:(void(^)(void))failure;

/**
 更新昵称

 @param memberInfo 用户信息
 @param items 项
 */
+ (void)updateMemberNickName:(ESMemberInfo *)memberInfo
                   withItems:(NSArray <ESMemberInfoViewModel *>*)items;

/**
 更新地区

 @param memberInfo 用户信息
 @param viewModel 视图模型
 @param provinceCode 省code
 @param cityCode 市code
 @param districtCode 区code
 */
+ (void)updateRegionInfo:(ESMemberInfo *)memberInfo
               withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel
        withProvinceCode:(NSString *)provinceCode
            withCityCode:(NSString *)cityCode
         andDistrictCode:(NSString *)districtCode;

/**
 更新性别

 @param memberInfo 用户信息
 @param viewModel 视图模型
 @param title 选择的内容
 */
+ (void)updateSexInfo:(ESMemberInfo *)memberInfo
            withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel
            withTitle:(NSString *)title;

/**
 保存用户信息

 @param memberInfo 用户信息
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateMemberInfo:(ESMemberInfo *)memberInfo
             withSuccess:(void(^)(void))success
              andFailure:(void(^)(NSString *msg))failure;

/**
 处理输入项
 
 @param textField 输入框
 @param key 输入项标识
 @param viewModel 视图模型
 */
+ (void)manageTextField:(UITextField *)textField
                editing:(BOOL)editing
                withKey:(NSString *)key
              withItems:(NSArray <ESMemberInfoViewModel *>*)viewModel;
@end
