//
//  GalleryItemBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "NSString+JSONHelpers.h"
#import "DiscussionsBaseViewController.h"
#import "PassthroughView.h"
#import "HSWebView.h"

@class DesignBaseClass;

@interface GalleryItemBaseViewController : HSViewController
<SelectedGalleryViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate,
UserLogInDelegate, SelectedGalleryViewDelegate, DisscussionCommentsDelegate>
{
}

@property (weak, nonatomic) IBOutlet UIImageView *mainDesignImage;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *inputBox;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) DesignBaseClass* itemDetail;

@property (nonatomic) BOOL itemDetailsRequestNeeded;
@property (nonatomic) BOOL itemDetailsPrivateURLNeeded;
@property (nonatomic) BOOL imageRequestedFromServer;
@property (nonatomic) BOOL isFullScreenFromProfessionals;
@property (nonatomic) BOOL isCurrentVcDisplay;

-(void)init:(DesignBaseClass*)item;

-(void)reloadTable;
-(void)getFullImage;

- (void)refreshDesignInfo;

-(BOOL)getMyItemDetail;
-(void)loadItemDetailFromServer:(loadDesignBaseInfoBlock)completeBlock;

-(BOOL)isOwner;
-(BOOL)isPublicOrPublished;

-(void)setIsCurrent:(BOOL)isCurrent forceUpdate:(BOOL)forceUpdate;

-(void)toggleScreenModeAction:(id)sender;
-(void)readCommentsAction:(id)sender;

- (BOOL)isItemLiked;

- (void)toggleLikeState;
- (void)restoreLikeState;

- (void)scrollToTop;

-(IBAction)gestureSingleTap:(id)sender;
-(IBAction)gestureDoubleTap:(id)sender;

@end

