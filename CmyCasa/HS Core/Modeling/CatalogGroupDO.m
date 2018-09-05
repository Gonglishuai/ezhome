//
//  CatalogGroupDO.m
//  Homestyler
//
//  Created by Dan Baharir on 3/26/15.
//
//

#import "CatalogGroupDO.h"

@implementation CatalogGroupDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"name" : @"groupName",
       @"id" : @"groupId",
       @"parentId" : @"groupParentId",
       @"logo" : @"groupLogo",
       
       }];
    
    return entityMapping;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self)
    {
        self.groupName = [dict objectForKey:@"name"];
        self.groupId = [dict objectForKey:@"id"];
        self.groupLogo = [dict objectForKey:@"logo"];
        self.groupParentId = [dict objectForKey:@"parentId"];
    }

    return self;
}


@end
