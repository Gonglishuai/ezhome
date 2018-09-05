//
//  GalleryStreamViewController.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import "GalleryStreamViewController.h"
#import "GalleryStreamHeaderView_iPad.h"
#import "GalleryStreamEmptyRoomHeaderView.h"
#import "LayoutCell.h"
#import "MessagesViewController.h"
#import "FullScreenViewController_iPad.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"
#import "BannerCell.h"
#import "PopOverViewController.h"

#import "NSString+Contains.h"

static NSString *const galleryStreamHeaderCellID_iPad = @"GalleryStreamHeaderViewCellID";
static NSString *const MessagesStoryboardID_iPad = @"MessagesStoryBardID";

static const CGFloat galleryStreamBannerImgAspect_iPad = 300.0/2048;
static const CGFloat galleryStreamEmptyRoomDesignImgAspect_iPad = 3.0/4;

@interface GalleryStreamViewController ()<UIPopoverPresentationControllerDelegate>

@end

@implementation GalleryStreamViewController

/////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emptyRoomDesignImgAspect = galleryStreamEmptyRoomDesignImgAspect_iPad;
    self.bannerImgAspect = galleryStreamBannerImgAspect_iPad;
    [self.collectionView registerNib:[UINib nibWithNibName:@"GalleryStreamHeaderView_iPad" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:galleryStreamHeaderCellID_iPad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc{
    [self.streamTemplates removeAllObjects];
    self.streamTemplates = nil;

    NSLog(@"dealloc - GalleryStreamViewController");
}

#pragma mark -
/////////////////////////////////////////////////////////////////////////

-(void)refreshDataStream
{
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    [super refreshDataStream];
}

/////////////////////////////////////////////////////////////////////////

- (void)onGetGalleryItemsCompletion :(BOOL) bShowAlert withState:(BOOL) status
{
    [super onGetGalleryItemsCompletionWithState:status];

    if (!self.streamTemplates)
        self.streamTemplates = [NSMutableArray array];
}

/////////////////////////////////////////////////////////////////////////

-(void)virtualClearObservers{
    for (int i=0; i < [self.streamTemplates count]; i++)
    {
        StreamTemplateView * item = [self.streamTemplates objectAtIndex:i];
        [item clearObservers];
    }
}

/////////////////////////////////////////////////////////////////////////

-(void)virtualAddObservers{
    for (int i=0; i < [self.streamTemplates count]; i++)
    {
        StreamTemplateView * item = [self.streamTemplates objectAtIndex:i];
        [item addObservers];
    }
}

/////////////////////////////////////////////////////////////////////////

-(StreamTemplateView*)dequeueStreamTemplateForLayout:(GalleryLayoutDO*)layout
{
    StreamTemplateView *temp = nil;

    for (int i=0; i<[self.streamTemplates count]; i++) {
        StreamTemplateView * item = [self.streamTemplates objectAtIndex:i];
        if ([item isFitForLayout:layout]==YES) {
            return  item;
        }
    }
    
    //incase we did not find the specific layout
    temp = [self getStreamTemplateViewWithLayout:layout];
    [self.streamTemplates addObject:temp];

    return temp;
}

/////////////////////////////////////////////////////////////////////////

- (StreamTemplateView*)getStreamTemplateViewWithLayout:(GalleryLayoutDO*)layout {
     StreamTemplateView *temp = [[[NSBundle mainBundle] loadNibNamed:@"StreamTemplateView" owner:nil options:nil] lastObject];
    [temp initializeWithTemplate:layout];
    
    return temp;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - HSCollectionViewWaterfallLayoutDelegate
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0 && ![[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        return UIEdgeInsetsMake(20, 50, 20, 50);
    }

    return UIEdgeInsetsMake(20, 50, 20, 50);
}

#pragma mark - DesignItemDelegate
- (void)designPressed:(GalleryItemDO *)design
{
    NSMutableArray * allitems = [GalleryStreamManager sharedInstance].getActiveGalleryFilterDO.loadedItems;
    if (design==nil || [allitems count]==0) {
        return;
    }
    int pos = (int)[allitems indexOfObject:design];

    //created local instance instead of global
    NSString * origin = [self getEventOriginForItemType:design];

    FullScreenBaseViewController* fsbVc = [[UIManager sharedInstance] createFullScreenGallery:allitems withSelectedIndex:pos eventOrigin:origin];

    if([fsbVc isKindOfClass:[FullScreenViewController_iPad class]]){

        FullScreenViewController_iPad* sel = (FullScreenViewController_iPad*)fsbVc;
        if (self.isStreamOfEmptyRooms) {
            sel.dataSourceType=eFScreenEmptyRooms;
        }else{
            sel.dataSourceType=eFScreenGalleryStream;
        }
    }

    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:fsbVc animated:YES];
}

/////////////////////////////////////////////////////////////////////////
- (void)sortTypeSelectedKey:(NSString *)key value:(NSString *)value
{
    [[UIMenuManager sharedInstance] setIsUserChangedFilter:YES];
    [self.headerView setFilterType:value];
    [super sortTypeSelectedKey:key value:value];
}

-(void)roomTypeSelectedKey:(NSString*)key value:(NSString*)value
{
    if ([[[AppCore sharedInstance] getGalleryManager].getActiveGalleryFilterDO.filterType isEqualToString:DesignStreamTypeEmptyRooms])
    {
        [((GalleryStreamEmptyRoomHeaderView *)self.headerView) updateEmptyRoomPosition:key];
    }
    else
    {
        GalleryStreamHeaderView_iPad *iPadHeaderView = (GalleryStreamHeaderView_iPad *)self.headerView;
        [iPadHeaderView updateRoomTypePosition:key];
    }

    [super roomTypeSelectedKey:key value:value];
}

- (void)imageUploadStarted
{
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
}

- (void)imageUploadFinished
{
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}


- (IBAction)checkMessagesDetail:(UIButton *)sender {
    
//    if (![[UserManager sharedInstance] isLoggedIn])
//    {
//        [self signIn];
//        return;
//    }
//
//    CGFloat sourceViewWidth = 24;
//    CGFloat sourceViewHeight = 64;
//    UIView *sourceView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - sourceViewWidth) / 2,
//                                                                  (self.view.bounds.size.height - sourceViewHeight) / 2,
//                                                                  sourceViewWidth, sourceViewHeight)];
//    [self.view addSubview:sourceView];
//    MessagesViewController *messageController = [[MessagesViewController alloc] initWithSourceView:sourceView];
//    [messageController showMessageListInIPad];
//    messageController.popoverPresentationController.delegate = self;
//    [self presentViewController:messageController animated:YES completion:nil];
}

@end
