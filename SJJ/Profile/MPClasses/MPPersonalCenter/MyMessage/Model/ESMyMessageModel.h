//
//  ESMyMessageModel.h
//  Consumer
//
//  Created by zhangdekai on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "SHModel.h"

@interface ESMyMessageModel : SHModel

@property (nonatomic,assign) NSInteger readStatus;

@property (nonatomic,copy) NSString *mid;
@property (nonatomic,copy) NSString *theme;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *sender;
@property (nonatomic,copy) NSString *receiver;
@property (nonatomic,copy) NSString *sendTime;

+ (NSMutableArray<ESMyMessageModel *> *)getmodelArrayWithDic:(NSDictionary *)dic;

@end
