//
//  ProductResponse.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 9/30/14.
//
//

#import "ProductResponse.h"
#import "ShoppingListItem.h"
@implementation ProductResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                                                  toKeyPath:@"shoppingListItems"
                                                                                withMapping:[ShoppingListItem jsonMapping]]];
    return entityMapping;
}

- (void)applyPostServerActions{
    
    for (ShoppingListItem *prod in self.shoppingListItems)
    {
        [prod applyPostServerActions];
    }

}

@end
