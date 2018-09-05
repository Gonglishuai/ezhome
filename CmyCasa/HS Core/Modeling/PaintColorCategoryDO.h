//
//  PaintColorCategoryDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <Foundation/Foundation.h>
#import "PaintColorPalletItemDO.h"

@interface PaintColorCategoryDO : NSObject



@property(nonatomic,readonly)NSString * categoryID;
@property(nonatomic,readonly)NSString * categoryColorHex;
@property(nonatomic,readonly)NSMutableArray * categoryColors;


-(id)initWithDict:(NSDictionary*)dictionary;
-(void)addColorPalletItemForCategory:(PaintColorPalletItemDO*)palletItem;
@end
