//
//  ProductInfoTitleSwappableCell.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import "SwappableVariationView.h"
#import "Entity.h"
#import "ShoppingListItem.h"
#import "VariationDO.h"

//////////////////////////////////////////////////////////////////////
// Data Structures
/////////////////////////////////////////////////////////////////////

@interface SwappableCellVariationData : NSObject

@property (strong, nonatomic) Entity *entity;
@property (strong, nonatomic) ShoppingListItem *productItem;

-(instancetype)initWithEntity:(Entity*)entity shoppingListItem:(ProductDO*)shoppingListItem;

@end


//////////////////////////////////////////////////////////////////////
// PROTOCOLS
/////////////////////////////////////////////////////////////////////

@protocol ProductSwappableVariationCellDelegate <NSObject>
@optional
- (void)swapEntity:(Entity*)entity withVariation:(VariationDO*)variation ;
- (void)swapEntityWithProduct:(ProductDO*)product;

@end

//////////////////////////////////////////////////////////////////////
// CLASS
/////////////////////////////////////////////////////////////////////

@interface ProductSwappableVariationCell : UITableViewCell <SwappableVariationViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *variationTitleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *swappableVariationScrollView;
@property (strong, nonatomic) NSMutableArray * swappableVariationViewsArray;
@property (weak, nonatomic) id<ProductSwappableVariationCellDelegate> productSwappableVariationCellDelegate;
@property (weak, nonatomic) id<GenericWebViewDelegate> genericWebViewDelegate;
@property (weak, nonatomic) IBOutlet UIImageView *assemblyProductImageView;
@property (weak, nonatomic) IBOutlet UILabel *assemblyProductTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *assemblyProductInformationButton;
@property (weak, nonatomic) SwappableCellVariationData *dataForCell;
@property (strong, nonatomic) NSArray * swappableVariationArray;
@property (nonatomic) ProductCellType type;

- (IBAction)assemblyProductInformationPressed:(id)sender;

- (void)generateSwappableVariationViews:(NSArray*)swappableVariation
                  withSelectedVariation:(NSString*)selectedVariation;


@end
