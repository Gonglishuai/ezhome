//
//  ShoppingListManager.h
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ModelsHandler.h"
#import "ShoppingListItem.h"

typedef void (^ shoppingListDataAvailableBlock)(NSString* designitems);

@interface ShoppingListManager : NSObject
{
    @private
    NSMutableArray* _currentDesignitems;
    DesignBaseClass* _design;
}

+ (id) sharedInstance;
+ (NSString*) loadEmailTempladeFile:(NSString*) fileName;
- (void) setDesign:(DesignBaseClass*) design withComplition:(shoppingListDataAvailableBlock) notifyDataAvailableBlock;
- (NSString*) getShoppingListAsHTML;
- (NSMutableArray*) getShoppingList;

@end

