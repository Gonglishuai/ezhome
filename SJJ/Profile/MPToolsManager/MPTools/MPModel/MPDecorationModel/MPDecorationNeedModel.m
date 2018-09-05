
#import "MPDecorationNeedModel.h"
#import "MPTranslate.h"

@implementation MPDecorationNeedModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSNull class]]) {
            [self setValuesForKeysWithDictionary:dictionary];
            [self setBidderListWithDict:dictionary];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setBidderListWithDict:(NSDictionary *)dict {
    NSMutableArray *arrayBidder = [NSMutableArray array];
    
    if ([dict[@"bidders"] isKindOfClass:[NSNull class]]) {
        
    }else{
        for (NSDictionary *dic in dict[@"bidders"]) {
            MPDecorationBidderModel *model = [[MPDecorationBidderModel alloc] initWithDictionary:dic];
            model.template_id = self.wk_template_id;
            [arrayBidder addObject:model];
        }
        self.bidders = (id)arrayBidder;
    }
  
}

/// english to chinese
- (NSString *)house_type {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_house_type lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_house_type:str;
}

- (NSString *)room {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_room lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_room:str;
}

- (NSString *)living_room {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[[NSString stringWithFormat:@"%@_living",_living_room] lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_living_room:str;
}

- (NSString *)toilet {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[[NSString stringWithFormat:@"%@_toilet",_toilet] lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_toilet:str;
}

- (NSString *)decoration_style {
    NSString *str = [MPTranslate stringTypeEnglishToChineseWithString:[_decoration_style lowercaseString]];
    return ([str isEqualToString:@"(null)"])?_decoration_style:str;
}

- (NSString *)district_name {
    if ([_district_name isEqualToString:@"none"]) {
        return @" ";
    }
    return _district_name;
}

@end
