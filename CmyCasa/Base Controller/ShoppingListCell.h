//
//  ShoppingListCell.h
//  Homestyler
//
//  Created by Dor Alon on 6/15/13.
//
//

#import <UIKit/UIKit.h>
@class ShoppingListItem;
@interface ShoppingListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *vendorLabel;
@property (weak, nonatomic) IBOutlet UILabel *gotoWebLabel;
@property (nonatomic, retain) NSString *vendorProductUrl;

-(void)initShoppingListCell:(ShoppingListItem*)item;
@end
