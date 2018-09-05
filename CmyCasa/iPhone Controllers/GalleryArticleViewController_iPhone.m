//
//  ProgressPopupBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/22/13.
//
//

#import "GalleryArticleViewController_iPhone.h"
#import "CommentsViewController_iPhone.h"
#import "HSAnimatingView.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"
#import "UILabel+NUI.h"
#import "ProgressPopupBaseViewController.h"


@interface GalleryArticleViewController_iPhone () <UIGestureRecognizerDelegate>
{
    BOOL isLikeRequestPending;
}

@end

@implementation GalleryArticleViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
	
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSLog(@"dealloc - GalleryArticleViewController_iPhone");
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"]) {
        return;
    };
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"]) {
        return;
    }
    
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}


#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

-(IBAction)readCommentsAction:(id)sender
{
    CommentsViewController_iPhone * comm = [ControllersFactory instantiateViewControllerWithIdentifier:@"CommentsViewController_iPhone" inStoryboard:kGalleryStoryboard];
    comm.itemDetail=self.itemDetail;
    [self.navigationController pushViewController:comm animated:NO];
}

-(BOOL)isCommentsOpen{
    return  self.isCommentsPresented;
}

- (IBAction)likeAction:(id)sender
{
    if ([self isLoggedIn])
    {
        [self likePressed];
    }
    else
    {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_LIKE_ARTICLE, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
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
    
    [[DesignsManager sharedInstance] likeDesign:self.itemDetail : ![self isItemLiked] :self.parentViewController :NO withCompletionBlock:^(id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([(BaseResponse*)serverResponse errorCode] == -1);
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
    animView.image = [UIImage imageNamed:@"like_active"];
    
    [self.likeButton.superview addSubview:animView];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [animView animate];
                   });
}

-(void)loadUI{
    
    if (self.itemDetail) {
        
        self.likesCount.text=[NSString stringWithFormat:@"%d",[self.itemDetail getLikesCountForDesign]];
        
        self.commentsCount.text=[NSString stringWithFormat:@"%d", [[self.itemDetail getTotalCommentsCount] intValue]];
        
        NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
        LikeDesignDO*  likeDO = [likeDict  objectForKey:self.itemDetail._id];
        
        [self setButtonLiked:[likeDO isUserLiked]];
    }
    
    [super loadUI];
    
}

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
    return [self.itemDetail getLikesCountForDesign];
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
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self.itemDetail._id];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:self.itemDetail._id])
    {
        [self refreshLikeButton];
    }
}

@end
