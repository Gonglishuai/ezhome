//
//  PaintColorCategoryDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "PaintColorCategoryDO.h"


@interface PaintColorCategoryDO ()



@property(nonatomic)NSString * categoryID;
@property(nonatomic)NSString * categoryColorHex;
@property(nonatomic)NSMutableArray * categoryColors;

@end

@implementation PaintColorCategoryDO

-(id)initWithDict:(NSDictionary*)dictionary{
    self=[super init];
    
    self.categoryID=[dictionary objectForKey:@"cat_id"];
    self.categoryColorHex=[dictionary objectForKey:@"cat_color"];
    self.categoryColors=[NSMutableArray arrayWithCapacity:0];
    return  self;
}

-(void)addColorPalletItemForCategory:(PaintColorPalletItemDO*)palletItem{
    if (palletItem) {
        [self.categoryColors addObject:palletItem];
    }
    
}
@end
