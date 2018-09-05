//
//  ProductItemResponse.h
//  Homestyler
//  
//  Created by Gil Hadas on 8/20/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
#import "ShoppingListItem.h"

@interface ProductItemResponse : BaseResponse<RestkitObjectProtocol>
@property(nonatomic,strong) ShoppingListItem *shoppingListItem;


@end
