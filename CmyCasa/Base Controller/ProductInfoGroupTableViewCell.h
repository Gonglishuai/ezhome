//
//  ProductInfoGroupTableViewCell.h
//  Homestyler
//
//  Created by Dan Baharir on 2/16/15.
//
//

#import <UIKit/UIKit.h>
#import "CatalogGroupDO.h"
#import "ProductTagGroupView.h"

@interface ProductInfoGroupTableViewCell : ProductSwappableVariationCell <UIScrollViewDelegate, SwappableProductDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *groupScrollView;
@property (weak, nonatomic) IBOutlet UILabel * loadingLbl;

-(void)generateGroupViews:(NSArray *)products currentProductId:(NSString*)productId;
-(void)swappableProduct:(ProductDO *)product;
-(void)clearCell;

@end
