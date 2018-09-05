//
//  VariationDO.m
//  Homestyler
//
//

#import "VariationDO.h"

@implementation VariationDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
        @"id" : @"variationId",
        @"name" : @"variationName",
        @"sku" : @"variationSku",
        @"files" : @"files",
     }];
    
    return entityMapping;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.variationId = [dict objectForKey:@"id"];
        self.variationName = [dict objectForKey:@"name"];
        self.variationSku = [dict objectForKey:@"sku"];
        self.files = [dict objectForKey:@"files"];
    }
    
    return self;
}
@end
