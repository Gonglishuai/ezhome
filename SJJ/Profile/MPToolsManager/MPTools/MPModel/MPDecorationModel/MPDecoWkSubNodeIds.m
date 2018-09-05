
#import "MPDecoWkSubNodeIds.h"

@implementation MPDecoWkSubNodeIds

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        self.sub_node_id = value;
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (![dict isKindOfClass:[NSNull class]]) {
            [self setValuesForKeysWithDictionary:dict];
        }
    }
    return self;
}

@end
