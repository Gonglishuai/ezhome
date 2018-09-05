//
//  iphoneGalleryArticleViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/22/13.
//
//

#import "iphoneGalleryArticleViewController.h"
#import "CommentsViewController_iPhone.h"
#import "HSAnimatingView.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"
#import "UILabel+NUI.h"

@interface iphoneGalleryArticleViewController () <UIGestureRecognizerDelegate>
{
    BOOL isLikeRequestPending;
}


@end

@implementation iphoneGalleryArticleViewController


-(void)moveToFullScreenMode{
}

-(void)moveToNormalScreenMode{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChanged:) name:kNotificationLikeDesignDOLikeStatusChanged object:nil];

    isLikeRequestPending = NO;
    
    if (self.hideBottomBarView) {
        [self.bottomBarView setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startLoading{
    [[ProgressPopupBaseViewController sharedInstance] startLoadingWithOrientation:self isLandscape:UIInterfaceOrientationIsLandscape(self.interfaceOrientation)];
}

-(void)stopLoading{
      [[ProgressPopupBaseViewController sharedInstance] stopLoadingWithOrientationReset];
}

-(IBAction)readCommentsAction:(id)sender
{
    CommentsViewController_iPhone * comm=[ControllersFactory instantiateViewControllerWithIdentifier:@"iphoneCommentsViewController" inStoryboard:kGalleryStoryboard];
    
    comm._itemDetail=self._itemDetail;
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if ([[UIGalleryManager sharedInstance] pushDelegate]) {
                           [[[UIGalleryManager sharedInstance] pushDelegate].navigationController pushViewController:comm animated:NO];
                       }
                   });
}

-(BOOL)isCommentsOpen{
    return  self.isCommentsPresented;
}

-(void)closeCommentsView{
    
}

- (void)getItemDataFinishedNotification:(NSNotification *)notification
{
    if ([[[notification object] objectForKey:@"itemid"]isEqualToString:_itemDetail._id]) {
        [self stopLoading];
        [self loadUI:NO];
    }
}

-(void)reloadTable{
    
}

- (IBAction)likeAction:(id)sender
{
    if ([self isLoggedIn])
    {
        [self likePressed];
    }
    else
    {
        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_LIKE_ARTICLE, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
        [[UIMenuManager sharedInstance] loginRequestedIphone:self.parentViewController withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self likePressed];
            }
        }                                         loadOrigin:EVENT_PARAM_LOAD_ORIGIN_LIKE ];
    }
}

- (void)likePressed
{
    if (isLikeRequestPending)
    {
        return;
    }
    
    isLikeRequestPending = YES;
    
    if (![self isItemLiked] && ![self isButtonLiked]) //we were in unliked state
    {
        [self setButtonLiked:YES];
        [self setLikesCountNumber:[self getLikesCountNumber]+1];
        
        [self performLikeAnimation];
    }
    else if ([self isItemLiked] && [self isButtonLiked]) //we were in liked state
    {
        [self setButtonLiked:NO];
        [self setLikesCountNumber:[self getLikesCountNumber]-1];
    }
    else //ERROR: button and like item are not in sync - sync them
    {
        [self refreshLikeButton];
        isLikeRequestPending = NO;
        return;
    }
    
    if (([self isItemLiked] && [self isButtonLiked]) || (![self isItemLiked] && ![self isButtonLiked])) //dont do anything if the like state is already as requested
    {
        isLikeRequestPending = NO;
        return;
    }
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];

        isLikeRequestPending = NO;
        return;
    }
    
    [[UIGalleryManager sharedInstance] likesPressed:self._itemDetail : ![self isItemLiked] :self.parentViewController :NO withCompletionBlock:^(id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([serverResponse errorCode] == -1);
             if (isSuccess)
             {
                 
             }
             else
             {
                 //fail
             }
         }
         else
         {
             //fail
         }
         
         [self refreshLikeButton];
         isLikeRequestPending = NO;
     }];
}

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    HSAnimatingView *animView = [[HSAnimatingView alloc] initWithFrame:self.likeButton.frame andAnimationHeight:100];
    animView.image = [self.likeButton imageForState:UIControlStateNormal];
    
    [self.likeButton.superview addSubview:animView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

-(void)loadUI : (BOOL)bIsPresented{
    
    if (self._itemDetail) {
        
        self.likesCount.text=[NSString stringWithFormat:@"%d",[self._itemDetail getLikesCountForDesign]];
        
        self.commentsCount.text=[NSString stringWithFormat:@"%d", [[self._itemDetail getTotalCommentsCount] intValue]];
        
        NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
        LikeDesignDO*  likeDO = [likeDict  objectForKey:_itemDetail._id];

        [self setButtonLiked:[likeDO isUserLiked]];
    }
    
    [super loadUI:bIsPresented];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"]) {
        return;
    }
    [self startLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"]) {
        return;
    }
    [self stopLoading];
}

-(void)changeCommentLikeVisibility:(BOOL)isVisible{
    
}

#pragma mark - Gesture recognition

- (IBAction)gestureDoubleTap:(id)sender
{
    if ([self isLoggedIn])
    {
        if (![self isButtonLiked])
        {
            [self likePressed];
        }
    }
    else
    {
        //do nothing
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

- (void)setButtonLiked:(BOOL)liked
{    
    self.likeButtonLiked.hidden = !liked;
    self.likeButton.hidden = liked;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    self.likesCount.text = [NSString stringWithFormat:@"%d", likesCountNum];
}

- (int)getLikesCountNumber
{
    return [self._itemDetail getLikesCountForDesign];
}

- (void)refreshLikeButton
{
    [self setButtonLiked:[self isItemLiked]];
    [self setLikesCountNumber:[self getLikesCountNumber]];
}

- (BOOL)isButtonLiked
{
    return (self.likeButtonLiked.isHidden == NO);
}

- (BOOL)isItemLiked
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:_itemDetail._id];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:self._itemDetail._id])
    {
        [self refreshLikeButton];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
