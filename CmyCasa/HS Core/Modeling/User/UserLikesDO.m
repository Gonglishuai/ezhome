//
//  UserLikesDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/31/13.
//
//

#import "UserLikesDO.h"

@implementation UserLikesDO


+ (RKObjectMapping*)jsonMapping{
    

    
    RKObjectMapping* entityMapping = [super jsonMapping];
 

    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"assets"
                                                 toKeyPath:@"designs"
                                               withMapping:[GalleryItemDO jsonMapping]]];
    
    
    return entityMapping;
}
- (void)applyPostServerActions{
    if (self.designs==nil) {
        return;
    }
    for (int i=0; i<[self.designs count]; i++) {
       [[self.designs objectAtIndex:i] applyPostServerActions];
    }
    
}

@end
