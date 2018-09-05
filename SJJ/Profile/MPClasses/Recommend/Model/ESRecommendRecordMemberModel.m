//
//  ESRecommendFromDesingerModel.m
//  Consumer
//
//  Created by shejijia on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendRecordMemberModel.h"
#import "CoStringManager.h"

@implementation ESRecommendRecordMemberModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];

    if (self) {
        self.name = [CoStringManager judgeNSString:dic forKey:@"name"];
        self.avatar = [CoStringManager judgeNSString:dic forKey:@"avatar"];
        self.sourceType = [CoStringManager judgeNSInteger:dic forKey:@"sourceType"];
        self.inventoryName = [CoStringManager judgeNSString:dic forKey:@"inventoryName"];
        self.baseId = [CoStringManager judgeNSInteger:dic forKey:@"baseId"];
        self.time = [CoStringManager judgeNSString:dic forKey:@"time"];
    }
    return self;
}

+ (NSMutableArray<ESRecommendRecordMemberModel *> *)getmodelArrayWithDic:(NSDictionary *)dic {
    
    NSMutableArray *datasource = [NSMutableArray new];
    NSMutableArray *preViewArr = [NSMutableArray new];
    if ([dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        

        NSArray *mesages = dic[@"list"];
        if (mesages && mesages.count > 0) {
            for (NSDictionary *contentDic in mesages) {
                NSArray *productList  = contentDic[@"productList"];
                if (productList && productList.count > 0) {
                    for (NSDictionary * productDic in productList) {
                        NSString *preViewStr = productDic[@"image"];
                        [preViewArr addObject:preViewStr];
                    }
                }
                ESRecommendRecordMemberModel *model = [[ESRecommendRecordMemberModel alloc]initWithDic:contentDic];
                if (preViewArr.count != 0) {
                      model.preview = preViewArr[0];
                }else{
                   model.preview = @"";
                }
                [datasource addObject:model];
                [preViewArr removeAllObjects];
            }
        }
    }
    return datasource;
}



@end
