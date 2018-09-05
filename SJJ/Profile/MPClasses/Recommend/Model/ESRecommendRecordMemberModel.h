//
//  ESRecommendFromDesingerModel.h
//  Consumer
//
//  Created by shejijia on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESRecommendRecordMemberModel : NSObject
//设计师姓名
@property (nonatomic, copy) NSString *name;
//设计师头像
@property (nonatomic, copy) NSString *avatar;
//推荐类型
@property (nonatomic, assign) NSInteger sourceType;
//清单名称
@property (nonatomic, copy) NSString *inventoryName;
//清单id
@property (nonatomic, assign)  NSInteger baseId;
//推荐时间
@property (nonatomic, copy) NSString *time;
// 预览图
@property (nonatomic, copy) NSString *preview;

+ (NSMutableArray<ESRecommendRecordMemberModel *> *)getmodelArrayWithDic:(NSDictionary *)dic;

@end
