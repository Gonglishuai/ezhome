//
//  ProgressPopupBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/5/13.
//
//

#import "ProgressPopupBaseViewController.h"
#import "ControllersFactory.h"
#import "UIManager.h"

@interface ProgressPopupBaseViewController ()
{
    NSMutableArray * _loadingViews;
}


@end

@implementation ProgressPopupBaseViewController
static ProgressPopupBaseViewController *sharedInstance = nil;

+ (ProgressPopupBaseViewController *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = (ProgressPopupBaseViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"ProgressPopup" inStoryboard:kMainStoryBoard];
    });
    sharedInstance.colorStyle = ProgressDefault;
    return sharedInstance;
}

-(void)dealloc{
    NSLog(@"dealloc - ProgressPopupBaseViewController");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    _loadingViews = [NSMutableArray array];
    
    [self.label2 setHidden:YES];
    nLoadingRequsetCounter = 0;
    
    //Set the default title
    self.lblLoadingCenter.text = (IS_IPAD) ? NSLocalizedString(@"loading_popup_title_iPad", @"Loading") : NSLocalizedString(@"loading_popup_title_iPhone", @"Loading");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)shouldAutorotate{
    if (IS_IPAD) {
        return NO;
    }else{
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(void) reset {
    nLoadingRequsetCounter = 0;
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

- (void) setErrorMode: (NSString*) strLine1;
{
    self.lblLoadingCenter.text = strLine1;
}

- (void) setServerErrorMode {
    self.lblLoadingCenter.text = NSLocalizedString(@"progress_label_err_network",@"Network Error");
    self.label2.text =NSLocalizedString(@"progress_err_try_again", @"Please try again later");
    [self.label2 setHidden:NO];
}

// ToDo Add delgate code to check download state.
- (void) timeoutTimerEvent:(NSTimer *)timer
{
    if ([self.view isHidden] == NO)
    {
        self.lblLoadingCenter.text = NSLocalizedString(@"progress_Loading_timedout1",@"Zzzzz...");
        self.label2.text =NSLocalizedString(@"progress_Loading_timedout2", @"Loading timed out.");
        [self.label2 setHidden:NO];
        
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:0.5];
    }
}

- (void)startLoadingTipsWithOrientation:(UIViewController*)senderView isLandscape:(BOOL)isLandscape {
    self.lblLoadingCenter.hidden = YES;
    [self startLoading:senderView];
}

- (void)startLoadingWithoutText:(UIViewController *)senderView {
    self.lblLoadingCenter.hidden = YES;
    [self startLoading:senderView];
}

-(void)startLoading :(UIViewController*)senderView{
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startLoading:senderView];
        });
        return;
    }
    
    if ([_loadingViews containsObject:senderView]) {
        return;
    }else{
        [_loadingViews addObject:senderView];
    }
    
    if([ConfigManager isAnyNetworkAvailableOrOffline])
    {
//        [self.view setUserInteractionEnabled:NO];
//        
//        [senderView.view setUserInteractionEnabled:NO];
        
        //update view frame
        [self.view setFrame:senderView.view.bounds];
        [self.view setTag:LOADING_VIEW_TAG];

        [senderView addChildViewController:self];
        [senderView.view addSubview:self.view];
        
        self.label2.text  = @"";
        
        if( !_timeoutTimer)
        {
            NSTimeInterval loadingTimeout = [[ConfigManager sharedInstance] loadingTimeout];
            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:loadingTimeout
                                                             target:self
                                                           selector:@selector(timeoutTimerEvent:)
                                                           userInfo:nil
                                                            repeats:NO];
            
            
            [self.view setHidden:NO];
        }
        
        nLoadingRequsetCounter++;
    }
}

-(void)stopLoading {

    self.lblLoadingCenter.hidden = NO;

    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self stopLoading];
                       });
        return;
    }
    
    [_loadingViews removeAllObjects];
    
//    [self.parentViewController.view setUserInteractionEnabled:YES];

    nLoadingRequsetCounter--;
    if( nLoadingRequsetCounter <= 0)
    {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        nLoadingRequsetCounter = 0;
    }
    
    //Setting the title to the default text to avoid permanent change
    self.lblLoadingCenter.text = (IS_IPAD) ? NSLocalizedString(@"loading_popup_title_iPad", @"Loading") : NSLocalizedString(@"loading_popup_title_iPhone", @"Loading");
}

-(void)setColorStyle:(ProgressPopupBackgroundColor)colorStyle {
    switch (colorStyle) {
        case ProgressDefault:
            self.mainView.backgroundColor = [UIColor colorWithRed:0.0f/255.f green:0.0f/255.f blue:0.0f/255.f alpha:0.65f];
            break;
        case ProgressClear:
            self.mainView.backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
}

@end
