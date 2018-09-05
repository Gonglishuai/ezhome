//
//  ESMemberInfoViewModel.h
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  基本信息-页面数据模型

#import <Foundation/Foundation.h>

@interface ESMemberInfoViewModel : NSObject
@property (nonatomic, strong) NSString *key;    //标识
@property (nonatomic, strong) NSString *title;  //标题
@property (nonatomic, assign) BOOL edit;        //是否可编辑
@property (nonatomic, assign) BOOL input;       //是否为输入项
@property (nonatomic, strong) NSString *content;//内容
@property (nonatomic, assign) UIKeyboardType keyboardType;

+ (instancetype)objFromDict:(NSDictionary *)dict;

/**
 获取基本信息默认配置项

 @return 配置
 */
+ (NSMutableArray <ESMemberInfoViewModel *>*)getDefaultConfig;
@end
