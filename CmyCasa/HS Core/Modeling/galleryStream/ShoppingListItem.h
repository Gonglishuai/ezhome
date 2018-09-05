//
//  ShoppingListItem.h
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
#import "ProductDO.h"

@class ProductVendorDO;

@interface ShoppingListItem : ProductDO

- (NSString *) serializeAsHTML;


@end
