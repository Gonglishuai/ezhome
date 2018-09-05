//
//  ESCommodity.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCommodity.h"
#import "CoStringManager.h"

@implementation ESCommodity

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.itemId         = [CoStringManager judgeNSString:dict forKey:@"itemId"];
        self.itemQuantity   = [CoStringManager judgeNSString:dict forKey:@"itemQuantity"];
        self.itemPrice      = [CoStringManager judgeNSString:dict forKey:@"itemPrice"];
        self.itemAmount     = [CoStringManager judgeNSString:dict forKey:@"itemAmount"];
        self.itemName       = [CoStringManager judgeNSString:dict forKey:@"itemName"];
        self.itemImg        = [CoStringManager judgeNSString:dict forKey:@"itemImg"];
        
        if (dict[@"promotions"]
            && [dict[@"promotions"] isKindOfClass:[NSArray class]])
        {
            NSArray *promotions = dict[@"promotions"];
            if (promotions.count > 0
                && [promotions[0] isKindOfClass:[NSDictionary class]])
            {
                self.promotion = [ESCartCommodityPromotion createModelWithDic:promotions[0]];
            }
        }
        
        self.skuList        = [NSMutableArray array];
        if (![CoStringManager objectIsNull:dict forKey:@"skuList"]) {
            for (NSDictionary *dic in [dict objectForKey:@"skuList"]) {
                [self.skuList addObject:[ESStockKeepingUnit objFormDict:dic]];
            }
        }
        
        self.sku            = [CoStringManager judgeNSString:dict forKey:@"sku"];
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCommodity alloc] initWithDict:dict];
}
@end
