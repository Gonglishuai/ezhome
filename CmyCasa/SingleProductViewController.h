//
//  SingleProductViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "ModelsHandler.h"
#import "ServerUtils.h"
#import "PopOverViewController.h"

@class CatalogProductDO;

@interface SingleProductViewController : UIViewController <PopoverDelegate>
{
    @private
    
    NSString* _productSku;
    NSString* _retailerWebSiteUrl;
    NSString* _imagePath;
    NSString* _vendorImagePath;
    NSString* _imageUrl;
    NSString* _vendorImageUrl;
    NSString* _timeStamp;
    NSString* _vendorName;
    int _numOfDownloadTries;
}

@property (weak, nonatomic) IBOutlet UIButton *imagePressButton;
@property (weak, nonatomic) IBOutlet UILabel *lblNewRibbon;
@property (weak, nonatomic) IBOutlet UIImageView *roundRibbon;
@property (weak, nonatomic) id <ProductsCatalogDelegate> delegate;
@property (weak, nonatomic) id <GenericWebViewDelegate> genericWebViewDelegate;
@property (weak, nonatomic) IBOutlet UIView *extraInfoView;
@property (weak, nonatomic) IBOutlet UIButton *getExtraInfoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *vendorImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *productDetailsBtn;
@property (weak, nonatomic) IBOutlet UIButton *addToWishListBtn;
@property (weak, nonatomic) IBOutlet UIView * wishListNotificationView;
@property (weak, nonatomic) IBOutlet UILabel * wishListNotificationLabel;
@property (weak, nonatomic) IBOutlet UILabel * status;
@property (weak, nonatomic) PopOverViewController* wishListTypesViewController;
@property (weak, nonatomic) NSString* productId;


-(void)closeExtraInfo;
-(void)setProduct:(CatalogProductDO*) product ;
-(void)updateImages;
-(IBAction)getExtraInfoAction:(id)sender;
-(IBAction)imagePressed:(id)sender;
-(IBAction)webSitePressed:(id)sender;
-(IBAction)toggleAddToWishList:(id)sender;
-(void)addWishListButtonToView;

@end
