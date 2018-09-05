//
//  UIManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 1/17/13.
//
//

#import <Foundation/Foundation.h>
#import "ProtocolsDef.h"
#import "TakePictureOverlay.h"
#import "FullScreenViewController_iPhone.h"
#import "GenericWebViewBaseViewController.h"

#define LOADING_VIEW_TAG 1000

@class MainViewController;
@interface UIManager : NSObject <UINavigationControllerDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) MainViewController* mainViewController;
@property (nonatomic, strong) UIViewController * pushDelegate;
@property (nonatomic, strong) NSString * variationId;
@property (nonatomic, strong) NSString * productId;
@property (nonatomic, strong) NSString * timeStamp;
@property (nonatomic) BOOL isRedirectToLogin;


+ (id)sharedInstance;
+ (BOOL)dismissKeyboard:(UIView *)view;

-(FullScreenBaseViewController *)createFullScreenGallery:(NSArray *)itemsArray withSelectedIndex:(NSInteger)selectedIndex eventOrigin:(NSString *)loadOrigin;
-(FullScreenViewController_iPhone *)createIphoneFullScreenGallery:(NSArray *)itemsArray withSelectedIndex:(NSInteger)selectedIndex eventOrigin:(NSString *)loadOrigin;
-(GenericWebViewBaseViewController*)createGenericWebBrowser:(NSString*)url;
-(UIViewController *)createUniversalFullScreen:(NSArray *)itemsArray withSelectedIndex:(NSInteger)selectedIndex eventOrigin:(NSString *)loadOrigin;
-(UIViewController*)createUniversalFindFriends;
-(void)openGalleryFullScreenFromDesignID:(BOOL)withComments
                                 designid:(NSString *)designID
                                 withType:(ItemType)designType
                                 eventOrigin:(NSString*)openOrigin;
- (void)showRetakePhotoScreen;
- (UIViewController*)createImageEffectsViewController;
- (void)cameraPressed;
- (void)arPressed;
- (void)deviceGalleryPressed:(UIViewController*)mview ;
- (void)askMainViewControllerToClose;
- (void)askMainViewControllerToOpenCatalog;
- (void)OpenURLFromExternalLinkNotification:(NSNotification*)notification;
- (void)openHelpArticle;
- (void)openHomeCatalog;
- (BOOL)isDisplayingStreamOfEmptyRooms;
- (NSArray *)getCachedActivities;
- (void)galleryDesignBGImageRecieved :(UIImage*)image andOrigImage: (UIImage*)in_OrigImage andMaskImage: (UIImage*)in_maskImage;
- (void)galleryDesignSelected:(SavedDesign*)design withOriginalDesign:(GalleryItemDO*)originalDesign withOriginEvent:(NSString*)origin;
- (BOOL)likePressedForItemId:(NSString *)itemId andItemType:(ItemType)type withState:(BOOL)isLiked sender:(UIViewController*)senderView  shouldUsePushDelegate:(BOOL)usePushDelegate withCompletionBlock:(ROCompletionBlock)completion;
@end
