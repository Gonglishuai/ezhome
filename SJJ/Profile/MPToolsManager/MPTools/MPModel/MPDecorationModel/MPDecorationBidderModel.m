
#import "MPDecorationBidderModel.h"

@implementation MPDecorationBidderModel

-  (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (![dict isKindOfClass:[NSNull class]]) {
            [self setValuesForKeysWithDictionary:dict];
            [self getModelWithDict:dict];
        }
    }
    return self;
}

- (void)getModelWithDict:(NSDictionary *)dict {
    NSMutableArray *arrayOrders = [NSMutableArray array];
    if (![dict[@"orders"] isKindOfClass:[NSNull class]]) {
        for (NSDictionary *dic in dict[@"orders"]) {
            MPBidderOrderModel *model = [[MPBidderOrderModel alloc] initWithDictionary:dic];
            [arrayOrders addObject:model];
        }
        self.orders = (id)arrayOrders;
    }
    
    if (![dict[@"design_contract"] isKindOfClass:[NSNull class]]) {
        MPDesiContractModel *model = [[MPDesiContractModel alloc] initWithDictionary:[dict[@"design_contract"] firstObject]];
        self.design_contract = model;
    }
    
    NSMutableArray *arraySubNodeId = [NSMutableArray array];
    if (![dict[@"wk_next_possible_sub_node_ids"] isKindOfClass:[NSNull class]]) {
        for (NSDictionary *dic in dict[@"wk_next_possible_sub_node_ids"]) {
            MPDecoWkSubNodeIds *model = [[MPDecoWkSubNodeIds alloc] initWithDictionary:dic];
            [arraySubNodeId addObject:model];
        }
        self.wk_next_possible_sub_node_ids = (id)arraySubNodeId;
    }
}

@end
