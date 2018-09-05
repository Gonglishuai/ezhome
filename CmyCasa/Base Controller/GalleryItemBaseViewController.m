//
//  GalleryItemBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "GalleryItemBaseViewController.h"
#import "ProtocolsDef.h"
#import "DesignBaseClass.h"
#import "ServerUtils.h"
#import "CloudFrontCacheMap.h"
#import "NotificationAdditions.h"
#import "HSWebView.h"
#import "ProgressPopupViewController.h"


@interface GalleryItemBaseViewController () <UIGestureRecognizerDelegate>
{
}

@property (nonatomic, weak) IBOutlet UIGestureRecognizer *grSingleTap;
@property (nonatomic, weak) IBOutlet UIGestureRecognizer *grDoubleTap;

@end

@implementation GalleryItemBaseViewController
@synthesize itemDetailsPrivateURLNeeded;
@synthesize mainDesignImage;
@synthesize itemDetailsRequestNeeded;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureGestureRecognizers];
}

- (void)dealloc
{
    NSLog(@"dealloc - GalleryItemBaseViewController");
}

-(BOOL)isDesignImageLoaded{
    return self.mainDesignImage.image!=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)init:(DesignBaseClass*)item
{
    self.itemDetail = item;

    if (self.itemDetailsRequestNeeded) {

        [self.itemDetail loadGalleryItemExtraInfo :^(BOOL status) {

            dispatch_async(dispatch_get_main_queue(), ^{

                //what to do when data loaded
                if (status)
                {

                    [self loadUI];

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshFullScreenAfterDataDownloadNotification" object:[self getItemID]];

                }else{

                    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                                   message:NSLocalizedString(@"corrupted_load_design", @"Sorry, Your design is unable to load at this time. Please choose another design.")
                                                                  delegate:nil
                                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                         otherButtonTitles: nil];
                    [alert show];

                }

                //If it's an article, the progress popup should remain visible until the article web view is ready and loaded the data
                if ([self.itemDetail isArticle] == NO || status == NO) {
                    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                }
            });
        }];
    }
}

-(void)loadUI{

    if(self.itemDetail && ![self.itemDetail isArticle]){
        if(self.itemDetail.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE){

            MyDesignDO * mdesign = (MyDesignDO*)self.itemDetail;
            SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];
            if (mdesign.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
                [self.mainDesignImage setImage:autoDesign.image];
            }else{
                [self getFullImage];
            }
        }else{
            [self getFullImage];
        }
    }
}

-(void)clearUI{

    if(self.mainDesignImage)
    {
        [self.mainDesignImage setImage:nil];
    }

    self.imageRequestedFromServer=NO;
    self.itemDetail=nil;
}

-(void)setIsCurrent:(BOOL)isCurrent forceUpdate:(BOOL)forceUpdate {
}

#pragma mark- Delegates
-(NSString*)getItemContent{

    if([self.itemDetail isArticle])
    {

        if ([[ConfigManager sharedInstance] articleCloudSupported]) {
            //find
            NSString * _requrl=self.itemDetail.content;
            NSRange  range=[_requrl rangeOfString:[[ConfigManager sharedInstance]articleFindURL] options:NSCaseInsensitiveSearch];

            if (range.location!=NSNotFound) {
                _requrl=[_requrl stringByReplacingCharactersInRange:range withString:[[ConfigManager sharedInstance]articleReplaceURL]];
            }

            return _requrl;
        }

    }
    return self.itemDetail.content;
}

-(NSString*)getOrigImageURL{
    return self.itemDetail.originalImageURL;
}

-(NSString*)getBGImageURL{
    return self.itemDetail.backgroundImageURL;
}

-(NSString*)getMaskImageURL{
    return self.itemDetail.maskImageURL;
}

-(NSString*)getUserImageURL{
    return self.itemDetail.uthumb;
}

-(UIImage*)getCurrentPresentingImage{

    return self.mainDesignImage.image;
}

-(bool)isProfessional{

    if( [self.itemDetail isArticle])
    {
        return  false;
    }

    return  self.itemDetail.isPro;
}

-(bool)canRedesign
{
    return  [self.itemDetail is3DDesign];
}

-(BOOL)isOwner {
    if ([[UserManager sharedInstance] isLoggedIn])
        return self.itemDetail.uid == [UserManager sharedInstance].currentUser.userID;
    return NO;
}

- (BOOL)isPublicOrPublished {
    return [self.itemDetail isPublicOrPublished];
}

-(void)loadItemDetailFromServer:(loadDesignBaseInfoBlock)completeBlock {
    //will load itemDetailFromServer if needed
    if (self.itemDetail.isFullyLoaded == NO )
    {
        [self.itemDetail loadGalleryItemExtraInfo :completeBlock];
    }
}

#pragma mark SelectedGalleryViewDelegate Methods
-(NSString*)getDesignTitle{
    return  self.itemDetail.title;
}

-(NSString*)getDesignDescription{

    return self.itemDetail._description;
}

-(NSString*)getRoomType{
    if (self.itemDetail.roomType) {
        return  [NSString stringWithFormat:@"%d",[self.itemDetail.roomType intValue]];
    }

    return  [NSString stringWithFormat:@"1"];
}

-(NSString*)getDesignAuthor{
    return self.itemDetail.author;
}

-(NSString*)getUserID{
    return  self.itemDetail.uid;
}

-(DesignBaseClass*)getItemItself{
    return self.itemDetail;
}

-(NSString*)getItemID{
    return self.itemDetail._id;
}

-(int)getLikesCount{
    return [self.itemDetail getLikesCountForDesign];
}

-(UIImage*)getYourPresentingImage{
    return  self.mainDesignImage.image;
}

-(int)getCommentsCount{
    return [[self.itemDetail getTotalCommentsCount] intValue];
}

-(int) getProductsCount {
    return [self.itemDetail.productsCount intValue];
}

-(bool)isLikedByUser{

    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self.itemDetail._id];
    return  likeDO.isUserLiked;
}

-(ItemType)getItemType{

    return self.itemDetail.type;
}

-(NSString*)getThumbnailURL{

    return  self.itemDetail.url;
}

-(NSString*)getImageURL{

    return  @"";
}

#pragma mark - Zoom images
/*
 -(void)scrollViewDidEndZooming:(UIScrollView *)scrollview withView:(UIView *)view atScale:(CGFloat)scale{
 if (scrollview.zoomScale==1.0) {
 [self scrollViewDidZooming:scrollview];
 }
 }

 -(void)scrollViewDidZoom:(UIScrollView *)scrollView{
 }

 -(void)returnToNormalZoom{
 [self.scrollView setZoomScale:1.0];
 }

 - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{

 return self.mainDesignImage;
 }

 - (void)scrollViewDidZooming:(UIScrollView *)scrollview{
 }
 */
#pragma mark - Gestures
- (void)configureGestureRecognizers
{
    if ((self.grSingleTap != nil) && (self.grDoubleTap != nil))
    {
        [self.grSingleTap requireGestureRecognizerToFail:self.grDoubleTap];
    }

    if (self.grSingleTap != nil)
    {
        self.grSingleTap.delegate = self;
    }

    if (self.grDoubleTap != nil)
    {
        self.grDoubleTap.delegate = self;
    }
}

- (IBAction)gestureSingleTap:(id)sender
{
    [self toggleScreenModeAction:sender];
}

- (IBAction)gestureDoubleTap:(id)sender
{
    //    [[NSNotificationCenter defaultCenter] postNotificationName:DoubleTapGestureDetectedNotification object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(BOOL)getMyItemDetail{
    return NO;
}

-(void)closeCommentsView{
    //not implement
}

-(void)setCommentCount:(BOOL)incr{
    //not implement
}

-(void)reloadTable {
    [self.tableview reloadData];
}

-(void)getFullImage{
    //not implement
}

-(BOOL)isCommentsOpen{
    return NO;
}

-(void)setCommentsViewForInitialFrame{
    //not implement
}

-(void)toggleScreenModeAction:(id)sender{
    //not implement
}

-(NSString *)getBaseImageURL{
    return nil;
}

-(void)resetItemDetail{
    //not implement
}

-(void)setLikeCount:(BOOL)incr{
    //not implement
}

-(void)readCommentsAction:(id)sender{
    //not implement
}

- (void)scrollToTop {
    [self.tableview setContentOffset:CGPointZero animated:YES];
}

@end

