//
//  FullScreenBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+Scale.h"
#import "HSSharingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "HSViewController.h"
#import "ProductTagBaseView.h"
#import "DiscussionViewController.h"
#import "HSWebView.h"

#import "LoginDefs.h"
#import "ProtocolsDef.h"
#import "ProfileProtocols.h"

@class AppDelegate;
@class DesignBaseClass;
@class MessageUI;
@class GalleryItemDO;

typedef enum FullScreenDataSourceTypes{
    
    eFScreenEmptyRooms =1,
    eFScreenGalleryStream=2,
    eFScreenUserDesigns=3
    
}FullScreenDataSourceType;

@protocol SelectedGalleryViewDelegate <NSObject>
@required
-(NSString*)getDesignTitle;
-(NSString*)getDesignDescription;
-(NSString*)getDesignAuthor;
-(NSString*)getUserID;
-(NSString*)getItemID;
-(DesignBaseClass*)getItemItself;
-(ItemType)getItemType;
-(NSString*)getRoomType;
-(int)getLikesCount;
-(int)getCommentsCount;
-(int) getProductsCount;
-(void)setLikeCount:(BOOL) incr;
-(void)setCommentCount:(BOOL) incr;
-(bool)isProfessional;
-(bool)canRedesign;
-(bool)isLikedByUser;
-(UIImage*)getYourPresentingImage;
-(NSString*) getUserImageURL;
-(NSString*)getItemContent;
-(NSString*)getImageURL;
-(NSString*)getThumbnailURL;
-(NSString*)getBaseImageURL;
-(NSString*)getBGImageURL;
-(NSString*)getOrigImageURL;
-(NSString*)getMaskImageURL;
-(void)loadUI;
-(BOOL) getMyItemDetail;
-(void)resetItemDetail;
-(void)clearUI;
-(void)changeCommentLikeVisibility:(BOOL)isVisible;
-(UIImage*)getCurrentPresentingImage;
-(void)setCommentsViewForInitialFrame;
-(BOOL)isCommentsOpen;
-(void)closeCommentsView;
@end

@class GalleryItemBaseViewController;

@interface FullScreenBaseViewController : HSViewController <UIScrollViewDelegate,
ProductTagActionsDelegate,
GenericWebViewDelegate,
GalleryImageDesignItemDelegate,
MyDesignEditDelegate,
ProfileCountersDelegate,
HSSharingViewControllerDelegate,
MFMailComposeViewControllerDelegate>
{
    @protected
    BOOL canAnimateControls;
    BOOL isInFullScreenMode;
}

@property (weak, nonatomic) UIViewController * sourceViewController;
@property (nonatomic,strong) HSSharingViewController *hsSharingViewController;
@property (nonatomic,weak) GalleryItemBaseViewController *currentItemDelegate;
@property (nonatomic) FullScreenDataSourceType dataSourceType;
@property (nonatomic) BOOL isFullScreenFromProfessionals;
@property (nonatomic) BOOL openCommentsLayer;
@property (nonatomic) BOOL itemDetailsRequestNeeded;
@property (nonatomic) BOOL isPublishApproved;
@property (nonatomic) BOOL shouldDisableAutorotate;
@property (nonatomic) BOOL isHelpArticle;
@property (nonatomic) NSInteger selectedItemIndex;
@property (nonatomic, strong) NSMutableArray * itemIdsArray;
@property (nonatomic, strong) NSMutableArray * visibleLayouts;
@property (nonatomic, strong) ProductTagBaseView * productInfo;

@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;
@property (weak, nonatomic) IBOutlet UIButton * backButton;

-(void)hideControls;
-(void)showControls;
-(void)pageChange;
-(void)validateRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask ;
-(void)presentCurrentDesign;
-(void)tileLayout:(BOOL)animated;
-(void)hideProductInfoView;
-(void)removeObservers;
-(void)addObservers;
-(NSInteger)getScreenWidth;
-(void)clearVisibleLayout;

- (IBAction)navBack:(id)sender;
- (IBAction)sharePressed:(id)sender;

@end
