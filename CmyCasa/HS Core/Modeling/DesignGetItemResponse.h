//
//  DesignGetItemResponse.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/12/13.
//
//

#import "DesignBaseClass.h"
#import "ShoppingListItem.h"
@interface DesignGetItemResponse : DesignBaseClass


@property (nonatomic,strong) NSMutableArray * shoppingListItems;
@property (nonatomic,strong) NSMutableArray * uniqueContentItemsIds;
@property (nonatomic,strong) NSMutableDictionary *productsToVariationsMapping;

@end
