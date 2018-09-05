//
//  CatalogCell.h
//  CmyCasa
//
//  Created by Dor Alon on 2/10/13.
//
//

#import <UIKit/UIKit.h>

@class CatalogCategoryDO;
@class WishListProductDO;

@interface CatalogCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *catalogTitle;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIView *selectionBackground;
@property (weak, nonatomic) IBOutlet UILabel *deleteIndicator;

-(void)updateWithCategory:(CatalogCategoryDO*)category isRoot:(BOOL)isRoot;
-(void)updateWithWishList:(WishListProductDO*)wishlist isRoot:(BOOL)isRoot;

@end
