//
//  RetailerDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/12/13.
//
//

#import "RetailerDO.h"

@implementation RetailerDO
+ (RKObjectMapping*)jsonMapping
{
 
    
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"url" : @"url",
     @"name" : @"name",
     }];
    

    
    return entityMapping;
}

-(id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init])
    {
        self.url = [dict objectForKey:@"url"];
        self.name = [dict objectForKey:@"name"];

    }
    
    return self;
}

@end
