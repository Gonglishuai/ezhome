//
//  DoneNavigationDelegate.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SavedDesign.h"
#import "DesignBaseClass.h"
#import "RestKit.h"
#import "GalleryItemDO.h"
#import "GalleryServerUtils.h"


static NSString * const  PUSH_MESSAGE_GENERAL_UNDEFINED    = @"PUSH_MESSAGE_GENERAL_UNDEFINED";
static NSString * const  PUSH_MESSAGE_GENERAL_NOTIFICATION = @"MESSAGE_GENERAL_NOTIFICATION";
static NSString * const  PUSH_MESSAGE_FEATURED             = @"MESSAGE_FEATURED";
static NSString * const  PUSH_MESSAGE_LIKED_ASSET          = @"MESSAGE_LIKED_ASSET";
static NSString * const  PUSH_MESSAGE_COMMENT              = @"MESSAGE_COMMENT";
static NSString * const  PUSH_MESSAGE_COMMENT_UPDATE       = @"MESSAGE_COMMENT_UPDATE";
static NSString * const  PUSH_MESSAGE_FOLLOW               = @"MESSAGE_FOLLOW";
static NSString * const  PUSH_MESSAGE_PRIVATE              = @"MESSAGE_PRIVATE";
static NSString * const  PUSH_MESSAGE_PUBLISHED_ASSET      = @"MESSAGE_PUBLISHED_ASSET";

@class SingleProductViewController;
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

@class MyDesignDO;

typedef enum OperationType{
    OPERATION_TYPE_ADD,
    OPERATION_TYPE_REMOVE
}OperationType;

typedef enum {
    PRODUCTS_CATALOG,
    WISHLIST_CATALOG
}CatalogType;

typedef enum {
 STATUS_PRIVATE = 0,
 STATUS_PUBLIC = 1,
 STATUS_DELETED = 2,
 STATUS_PUBLISHED= 3
}ServerStatusType;

@protocol DoneNavigationDelegate<NSObject>
- (void)donePressed:(id)sender;
- (void)cancelPressed:(id)sender;
@end

@protocol RoundedRectDelegate <NSObject>
- (void)rectPressed:(id)sender :(UIColor*)color ;
@end

@protocol WarningPopupDelegate <NSObject>
- (void)leavePressed;
- (void)saveDesignOnExit;
@end

@protocol ColorPickerDelegate <NSObject>
- (IBAction)cancelPressed:(id)sender;
- (IBAction)closePressed:(id)sender;
- (void)colorSelected:(id)sender :(UIColor*)color;
- (void)wallpaperSelected:(id)sender :(NSString*)wallpaperId;
@end


@protocol SaveDesignPopupDelegate <NSObject>
- (void)saveDesign:(NSString*)name;
- (void)homePressed;
@optional
- (void)saveDesignOnExit;
- (void)saveDesignPopupClosed;
- (void)saveDesignPopupClosedOnCancel;
- (UIImage*)getScreenShot;
- (NSString*)getDesignOwner;
- (NSString*)getDesignName;
- (NSString*)generateShareUrl;
- (void)updateDesignTitle:(NSString*)title andDescription:(NSString*)desc andURL:(NSString*)url;
- (BOOL)saveRequestedBeforeLeave;
- (void)backPressedOnIphoneAfterSave;
@end

@protocol SaveDesignViewDelegate
- (void)savedDesignSelected:(SavedDesign*)design;
@end

@protocol GalleryImagesDelegate <NSObject>
- (void)fullScreenGalleryViewClickedForItemNumber:(NSInteger)itemNumber;
- (void)createFullScreenGalleryView: (NSString*)itemID withOpenComment:(BOOL)commOpen;
- (void)createLayerViewController;
- (UIViewController *)superViewController;
@end

@protocol DesignStreamCellDelegate <NSObject>
@optional
- (void)didTapOnCell:(id)cell;
- (UIViewController *)superViewContoller;
@end



@protocol IPadGalleryDelegate

- (void) commentsPressed:(NSString*)itemID;
- (void) likesPressed:(DesignBaseClass*)item :(BOOL) bIsLiked;
- (void)requestThumbnail: (NSString*) strID URL:(NSString*) strURL;
- (void)createFullScreen: (NSString*) itemID :(int) itemType;

@end


@protocol GalleryImageDesignItemDelegate <NSObject>

@optional
- (void)updateLikeButtonState;
- (void)showFullDesignImage:(DesignBaseClass*)design;
- (void)showUserProfile:(DesignBaseClass*)design;
- (void)showDesignLikes:(DesignBaseClass*)design;
- (void)showShoppingList:(DesignBaseClass*)design;

@end


@protocol LandscapeDesignViewControllerDelegate_iPhone

-(void)landscapeViewWillDismiss;

@end

/////////////////////////////////////////////////////////////
@protocol NewDesignViewControllerDelegate
@optional
- (void)cameraPressed;
- (void)deviceGalleryPressed:(UIViewController *)senderView;
@end

/////////////////////////////////////////////////////////////
@protocol ProfessionalInfoCellDelegate <NSObject>

- (void)changeFollowStatusForProfessional;
- (void)changeFirstCellHeight:(NSNumber*)newHeight;
- (void)openProfessionalDetails;

@end

/////////////////////////////////////////////////////////////
@protocol MyDesignEditDelegate

@optional
- (void)designUpdated:(DesignMetadata *)metadata;
- (void)designDuplicated:(NSString *)designId;
- (void)designDeleted:(NSString *)designId;
- (void)redesign:(DesignBaseClass *)design;
- (void)designPublishStateChanged:(NSString *)designId status:(DesignStatus)status;
- (void)articleSelected:(NSString*)articleId :(NSMutableArray*)articleIds :(int)selectedArticleIdx;
@end

/////////////////////////////////////////////////////////////
@protocol AddCommentDelegate
- (BOOL)addCommentPressed:(id)sender;
- (BOOL)dicusssionViewClosed:(id)sender;
@end

@protocol DiscussionViewControllerDelegate <NSObject>
- (BOOL)addCommentPressed:(id)sender;
- (BOOL)addCommentPressedAfterLogin:(id)sender :(BOOL)createNewComment;
@optional
- (void)textFieldBeginEdit:(CGRect)textOwnerRect;
- (void)textFieldEndEdit:(CGRect)textOwnerRect;
- (void)positionCommentInTopScroll:(CGRect)textOwnerRect;
@end

@protocol ProfessionalDelegate <NSObject>
- (void) professionalSelected:(NSString*)profId;
@end

@protocol ProfessionalPageDelegate
- (void) designSelected:(NSMutableArray*)designIds :(int)selectedDesignIdx;
@end

@protocol ProductsCatalogDelegate <NSObject>
- (void) productSelected:(NSString*)productId andVariateId:(NSString*)variateId andVersion:(NSString*)timeStamp;
@optional
-(void)updateProductSelection:(SingleProductViewController*)catalogItem;
-(void)noCategoriesWereRetrieved;
-(void)categorySelected:(NSString*)categoryId catalogType:(CatalogType)catalogType;
-(void)willShowWishList:(NSString*)productId;
-(void)willHideWishList;
-(void)refreshTableView:(NSString *)itemId catalogType:(CatalogType)catalogType;
-(void)searchCatalog:(NSString*)searchString;
@end


typedef enum SaveDesignDialogs {
    SaveDesignSaveKey = 0,
    SaveDesignImageEffectsKey = 1,
    SaveDesignShareKey = 2,
    
	
} SaveDesignDialog;


@protocol SaveDesignFlowBaseControllerDelegate <NSObject>
-(void)prevStepRequested:(SaveDesignDialog)currentState;
-(void)nextStepRequested:(UIImage*)finalImage;
-(void)skipStepRequested;
@end

@protocol ComeBackArViewControllerDelegate <NSObject>
-(void)comeBackFromArController;
@end

@protocol PopoverDelegate <NSObject>
@optional
- (void)roomTypeSelectedKey:(NSString*)key value:(NSString*)value;
- (void)sortTypeSelectedKey:(NSString*)key value:(NSString*)value;
- (void)langSelectedkey:(NSString*)key value:(NSString*)value;
- (void)countrySelectedkey:(NSString*)key value:(NSString*)value;
- (void)wishlistAddProductToWishLists:(NSArray*)wishlistsSelection removeWishList:(NSArray*)wishlistsToRemove;
- (void)wishlistCancelPressed;
- (void)addNewWishList:(NSString*)name;
@end

////////////////////////////////////////////////////
@protocol ProductTagActionsDelegate <NSObject>

@optional
- (void)removeProduct:(Entity*)entity;
- (void)duplicateProduct:(Entity*)entity;
- (void)resetScaleForProduct:(Entity*)entity;
- (void)adjustBrightnessForProduct:(Entity*)entity brightness:(float)val;
- (void)variateEntity:(Entity*)entity withVariationId:(NSString*)variationId;
- (void)productEntityWithProductId:(NSString*)productId;
@end
////////////////////////////////////////////////////

@protocol  GenericWebViewDelegate <NSObject>

-(void)openInteralWebViewWithUrl:(NSString *)url;

@end

typedef enum {
    ProductCellTypeTitle = 0,
    ProductCellTypeGroups = 1,
    ProductCellTypeSwappableVariation = 2,
    ProductCellTypeAssemblyWithVariation = 3,
    ProductCellTypeAssemblyInfo = 4,
    ProductCellTypeProductDetails = 5,
    ProductCellTypeDuplicateProduct = 6,
    ProductCellTypeRestoreScale = 7,
    ProductCellTypeBrightness = 8,
    ProductCellTypeRemoveItem = 9,
    ProductcellTypeTagGroupTitleCell = 10,
    ProductcellTypeTagGroupHeaderCell = 11
} ProductCellType;


