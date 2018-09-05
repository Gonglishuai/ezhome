//
//  GetLayoutsDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/29/13.
//
//

#import "GetLayoutsDO.h"
#import "GalleryLayoutDO.h"
@implementation GetLayoutsDO


+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"flow" : @"flows"
     }];
    
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"layouts"
                                                 toKeyPath:@"layouts"
                                               withMapping:[GalleryLayoutDO jsonMapping]]];
    
    return entityMapping;
}
-(void)applyPostServerActions
{
    
    for (id<RestkitObjectProtocol> currResponseObject in self.layouts)
    {
        if ([currResponseObject respondsToSelector:@selector(applyPostServerActions)])
        {
            [currResponseObject applyPostServerActions];
        }
    }

    
    
       NSLog(@"");
}
@end
