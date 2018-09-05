//
//  ProductItemResponse.m
//  Homestyler
//
//  Created by Gil Hadas on 8/20/13.
//

#import "ProductItemResponse.h"
#import "ModelsHandler.h"
#import "RetailerDO.h"
@implementation ProductItemResponse

+ (RKObjectMapping*)jsonMapping
{
    
     RKObjectMapping* entityMapping = [super jsonMapping];

    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"item"
                                                 toKeyPath:@"shoppingListItem"
                                               withMapping:[ProductDO jsonMapping]]];
    
    return entityMapping;
}

-(void)applyPostServerActions{
    
    if (self.shoppingListItem && [self.shoppingListItem respondsToSelector:@selector(applyPostServerActions)]) {

        [self.shoppingListItem applyPostServerActions];
    }
}
@end
