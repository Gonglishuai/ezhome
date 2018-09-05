//
//  ProductTagBaseView.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/18/13.
//
//

#import <UIKit/UIKit.h>
#import "HSNUIIconLabelButton.h"
#import "ProtocolsDef.h"
#import "ProductSwappableVariationCell.h"
#import "ProductAssemblyInfoTableViewCell.h"
#import "ProductInfoDO.h"


@class ShoppingListItem;

@interface ProductTagBaseView : UIViewController <UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate, ProductSwappableVariationCellDelegate, UIGestureRecognizerDelegate>

@property (nonatomic,strong) Entity * currentProductEntity;
@property (nonatomic,strong) ProductInfoDO * currentProduct;
@property (nonatomic) BOOL holdViewWhileSwitchingObjects;
@property (nonatomic,weak) id<ProductTagActionsDelegate>productDelegate;
@property (nonatomic,weak) id<GenericWebViewDelegate> genericWebViewDelegate;
@property (nonatomic,strong) NSMutableArray* productImagesArray;
@property (nonatomic,strong) NSMutableArray* cellsArray;
@property (assign) BOOL isProductReplacedFromFamily;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView * loadingView;
@property (weak, nonatomic) IBOutlet UILabel * loadingLbl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic) BOOL editMode;
@property (nonatomic) BOOL isDockingToLeft;

/*
 updating current product info and transfering 'isActiveOjectSelected' to indicate if called from choosing a new item
 and need to reload all table data (when choosing a variation we only reload the title cell)
 */
- (void)updateCurrentProductInfo:(Entity*)entity;
- (void)productSite;
- (void)duplicateProduct:(id)sender;
- (void)restoreProductScale:(id)sender;
- (void)removeProduct:(id)sender;
- (void)openBrandHomePage:(id)sender;
- (void)removeProductAfterConfirm;
- (void)productBrightnessSliderChanged:(UISlider *)sender;
- (void)closeProductInfoView:(id)sender;

@end
