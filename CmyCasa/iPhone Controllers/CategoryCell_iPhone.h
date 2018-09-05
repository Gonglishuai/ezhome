//
//  CategoryCell_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import <UIKit/UIKit.h>
#import "CatalogCategoryDO.h"
#import "WishListProductDO.h"

@interface CategoryCell_iPhone : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deleteIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *catTitle;
@property (weak, nonatomic) IBOutlet UIView *selectionBackground; //In order to make this property useful, assign it a nuiClass when relevant

-(void)updateWithCategory:(CatalogCategoryDO*)category  isRoot:(BOOL)isRoot;
-(void)updateWithWishList:(WishListProductDO*)wishList isRoot:(BOOL)isRoot;

@end
