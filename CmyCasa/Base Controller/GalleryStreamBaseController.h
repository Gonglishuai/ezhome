//
//  GalleryStreamBaseController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import "AppCore.h"

static double prevCallTime = 0;
static double prevCallOffset = 0;

@class PopOverViewController;
@class GalleryStreamHeaderView;

@protocol GalleryStreamViewControllerDelegate <NSObject>
@optional
- (NSString*)getItemID:(int)itemPos;
- (int)getGalleryItemLikesCount:(int)itemPos;
- (BOOL)isEmptyRoomsGalleryMode;
- (void)imageUploadStarted;
- (void)imageUploadFinished;
- (void)commentButtonPressedForDesign:(GalleryItemDO*)item;
- (void)likeButtonPressedForDesign:(GalleryItemDO*)item;
- (void)shareButtonPressedForDesign:(GalleryItemDO*)item withDesignImage:(UIImage *)designImage;
- (void)profileButtonPressedForDesign:(GalleryItemDO*)item;
@end
//GAITrackedViewController
@interface GalleryStreamBaseController : UIViewController <UINavigationControllerDelegate, UIScrollViewDelegate, PopoverDelegate, MFMailComposeViewControllerDelegate>
{
    @protected
    NSString* commentsPressedID;
}

@property (nonatomic) DesignFilterType  designsFilterType;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *offlineIcon;
@property (weak, nonatomic) IBOutlet UILabel *roomTypeTitle;
@property (nonatomic, strong) PopOverViewController* roomTypesPopover;
@property (nonatomic, strong) PopOverViewController* sortTypesPopover;
@property (nonatomic, strong) NSMutableArray*      roomTypesArr;
@property (nonatomic, strong) NSMutableArray*      sortTypesArr;
@property (nonatomic, strong) NSString*            selectedRoomTypeKey;
@property (nonatomic, strong) NSString*            selectedSortTypeKey;
@property (nonatomic) BOOL bRequestRefreshSent;
@property (nonatomic) BOOL isStreamOfEmptyRooms;
@property (nonatomic) BOOL isOneOptionActive;
@property (nonatomic) BOOL isUserChangedFilter;
@property (nonatomic) BOOL roomTypesEvailable;

@property (nonatomic, weak) GalleryStreamHeaderView *headerView;
@property (nonatomic, assign) BOOL hasEmptyView;
@property (nonatomic, assign) CGFloat bannerImgAspect;
@property (nonatomic, assign) CGFloat emptyRoomDesignImgAspect;

-(void)sortTypeSelectedKey:(NSString*)key value:(NSString*)value;
-(void)roomTypeSelectedKey:(NSString*)key value:(NSString*)value;
-(NSString*)getEventOriginForItemType:(GalleryItemDO*)item;
-(void)setOfflineIndicatorAccordingToNetworkStatus;
-(void)virtualClearObservers;
-(void)virtualAddObservers;
-(void)onGetGalleryItemsCompletionWithState:(BOOL) state;
-(IBAction)scrollToTop:(id)sender;
-(void)refreshFiltersAfterSelection;
-(void)resetFiltersAndSortButtons;
-(void)refreshDataStream;
-(void)getGalleryStreamLayouts;
- (void)signIn;
- (void)refreshCollection;

- (CGFloat)textBoundingHeight:(NSString *)designDesc width:(CGFloat)width;

@end
