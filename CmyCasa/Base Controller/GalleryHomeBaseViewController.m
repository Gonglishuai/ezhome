//
//  GalleryHomeBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/3/13.
//
//

#import "GalleryHomeBaseViewController.h"
#import "ImagesInfo.h"
#import "ProtocolsDef.h"
#import "ServerUtils.h"
#import "UIManager.h"
//#import <Analytics/SEGAnalytics.h>
#import "NotificationNames.h"
#import "GStreamRO.h"
#import "ImageFetcher.h"
#import "ProgressPopupViewController.h"
#import "ProductsCatalogBaseViewController.h"
#import "ControllersFactory.h"
#import "UIView+NUI.h"
#import "PackageManager.h"
#import "UIView+ReloadUI.h"
#import "NSString+Contains.h"
#import "UserManager.h"
#import "MainViewController.h"
#import "ESOrientationManager.h"
//#import "UMMobClick/MobClick.h"

#define WIFI_ALERT              1000
#define THREEG_ALERT            1005
#define NEW_PACKAGE_ALERT       1010
#define AUTOSAVE_CRUSH_ALERT    1015

#ifdef SERVER_RENDERING
#include "ServerRendererManager.h"
#endif

#define kIndicatorLeftSpacingInPixels 30

@interface GalleryHomeBaseViewController ()
{
    CGRect frameProfileNameLable;
}

@property (nonatomic, strong) UIImageView* nextBackImage;
@property (nonatomic)         NSUInteger   currBackIndex;
@property (nonatomic)         CGFloat      changeInterval;
@property (nonatomic)         CGFloat      changeFadeTime;
@property (strong, nonatomic) NSTimer*     changeBackgroundTimer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView    *aiSilentLogin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *animationLayOutForIPhone;
@end

@implementation GalleryHomeBaseViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addObservers];
    
    frameProfileNameLable = self.ivProfileName.frame;
   
    // Do any additional setup after loading the view.
    [[UIManager sharedInstance] setPushDelegate:self];
    
    //now Menu can push/ pop App sections
    [self.navigationController setNavigationBarHidden:YES];
    
#ifdef SERVER_RENDERING
#else
    [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
        
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (error==nil && response!=nil && response.errorCode==-1) {
            AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate updateReviewLogins];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserDidFailLogin object:nil];
        }
    } queue:dispatch_get_main_queue()];
    
    
    //check if external url was activating the app
    [[UIManager sharedInstance] OpenURLFromExternalLinkNotification:[NSNotification notificationWithName:@"" object:nil]];
    
#endif
    self.contestView.hidden=YES;
    if ([[ConfigManager sharedInstance] contestArticleID]!=nil &&
        [[[ConfigManager sharedInstance] contestArticleID] length]>0 &&
        [[ConfigManager sharedInstance]contestArticleImg]!=nil &&
        [[[ConfigManager sharedInstance] contestArticleImg] length]>0 ) {
        
        NSString* url = [[ConfigManager sharedInstance]contestArticleImg];
//        float scale = (IS_IPAD) ? 1.0f : [UIScreen mainScreen].scale;
        
        CGSize designSize = CGSizeMake( [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (url)?url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.contestImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.contestImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image) {
                                                  self.contestImage.image = image;
                                                  self.contestView.hidden = NO;
                                              }else{
                                                  self.contestView.hidden = YES;
                                              }
                                              
                                          });
                       }
                   }];
        
    }

    // TODO: move to AppDelegate?
    NSString * userID = [[[UserManager sharedInstance] currentUser] userID];
//    [HSFlurry logAnalyticEvent:EVENT_NAME_APP_LAUNCH withParameters:@{EVENT_PARAM_USER_ID:(userID)?userID:@"none"}];

    if ([[DesignsManager sharedInstance] isThereDesignCreatedDueToCrash]){
        [self showCrashAlert];
    }
    
    [self supportOffLineMode];
    [self reloadUI];
    self.logoImage.hidden = [[ConfigManager getTenantIdName] isEqualToString:@"ezhome"] ? YES : NO;
    
    [self checkVersion];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateProfileDetails];
    [self setOfflineIndicatorAccordingToNetworkStatus];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.changeBackgroundTimer invalidate];
    self.changeBackgroundTimer = nil;
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    [self removeObservers];
    NSLog(@"dealloc - GalleryHomeBaseViewController");
}

#pragma mark -

-(void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI) name:@"NetworkStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"configLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginUpdated) name:kNotificationUserDidLoginSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginFailed) name:kNotificationUserDidFailLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateSilentSignIn) name:kNotificationSilentLoginWillBegin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalLogin:) name:@"external_login" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBackgroundImages:) name:@"APP_BACKGROUNDS_FINISH" object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NetworkStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"configLoaded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUserDidLoginSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUserDidFailLogin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSilentLoginWillBegin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"external_login" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"APP_BACKGROUNDS_FINISH" object:nil];
}

-(void)supportOffLineMode{
    //case we have network and offline mode is on
    if ([ConfigManager isAnyNetworkAvailable] && [ConfigManager isOfflineModeActive]) {
        
        //check if package exist if yes load it otherwise exit
        if ([[PackageManager sharedInstance] isOffLinePackageExist]) {
            
            //check if we have newer offline package in the server
            if([[PackageManager sharedInstance] isNewFileExist]){
                [self showNewPackageExistAlert];
            }else{
                //no newer file exist
                [self loadPackageFromDeviceStorage];
            }
        }else{
            // check connectivity
            switch ([[ReachabilityManager sharedInstance] connectionType]) {
                case ReachableViaWiFi:
                    [self showWiFiAlert];
                    break;
                case ReachableViaWWAN:
                    [self show3GAlert];
                    break;
                case NotReachable:
                    //cant be we have network
                    break;
                    
                default:
                    break;
            }
            
            return;
        }
    }
}

-(void)showCrashAlert{
    NSString * displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"redesign_after_crash_alert", @""), displayName];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"resume_alert_button", @"Resume") otherButtonTitles:NSLocalizedString(@"alert_view_dont_remind", @"No, Thanks"), nil];
    [alert setAccessibilityLabel:@"alert_title_redesign_after_crash"];
    alert.tag = AUTOSAVE_CRUSH_ALERT;
    [alert show];
}

-(void)showNewPackageExistAlert{
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@""
                                                    message:NSLocalizedString(@"It's appear that there is newer Offline Package, would you like to download the newer version", @"")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"No", @"")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    alert.tag = NEW_PACKAGE_ALERT;
    [alert show];
}

-(void)showWiFiAlert{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@""
                                                    message:NSLocalizedString(@"Would you like to download the product collection to design offline?", @"Would you like to download the product collection to design offline?.")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Later", @"Later")
                                          otherButtonTitles:NSLocalizedString(@"Yes", @"Yes"), nil];
    alert.tag = WIFI_ALERT;
    [alert show];
}

-(void)show3GAlert{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@""
                                                    message:NSLocalizedString(@"Your WiFi is off We recommend downloading the offline product collection via WiFi", @"Your WiFi is off We recommend downloading the offline product collection via WiFi.")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Later", @"Later")
                                          otherButtonTitles:NSLocalizedString(@"Now", @"Now"), nil];
    alert.tag = THREEG_ALERT;
    [alert show];
}

- (void)enterRedesignAfterCrash
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        SavedDesign * saveDesign = [[DesignsManager sharedInstance] workingDesign];
        
        if (!saveDesign) return;
        
        //extract nsdata of the images into uiimage holders
        [saveDesign loadDataIntoUIImagesForAutosaves];
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           MyDesignDO * mdesign = [[DesignsManager sharedInstance] generateDesignDOFromSavedDesign:saveDesign];
                           GalleryItemDO * gido = (GalleryItemDO*)mdesign;
                           [[UIManager sharedInstance] galleryDesignSelected:saveDesign withOriginalDesign:gido withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_AFTERCRASH];
                           [[UIManager sharedInstance] galleryDesignBGImageRecieved:saveDesign.image andOrigImage:saveDesign.originalImage andMaskImage:saveDesign.maskImage];
                       });
    });
}




- (void)reloadUI
{
    [self setOfflineIndicatorAccordingToNetworkStatus];
    [self.view reloadUI];
}

- (void)reloadData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void){
        [[AppCore sharedInstance] Initialize];
    });
}

- (void)startChangingBackground
{
    // Make sure we aren't running two timers
    [self.changeBackgroundTimer invalidate];
    self.changeBackgroundTimer = [NSTimer scheduledTimerWithTimeInterval:self.changeInterval target:self selector:@selector(changeBackground) userInfo:nil repeats:YES];
    
    [self.changeBackgroundTimer fire];
}

- (void)changeBackground
{
    if (self.nextBackImage.image==nil) {
        // Load next image
        [self loadNextImage];
        return;
    }
    [UIView animateWithDuration:self.changeFadeTime animations:^{
        self.backgroundImage.alpha = 0;
        self.nextBackImage.alpha = 1;
    } completion:^(BOOL finished) {
        // Swap images
        UIImageView* temp = self.backgroundImage;
        self.backgroundImage = self.nextBackImage;
        self.nextBackImage = temp;
        
        // Load next image
        [self loadNextImage];
    }];
}

- (void)loadNextImage
{
    // Load next image
    NSString* url = ((ImageInfo*)[AppCore sharedInstance].appBackgrounds[self.currBackIndex]).url;
    
    ImageInfo* imgInf=((ImageInfo*)[AppCore sharedInstance].appBackgrounds[self.currBackIndex]);
    imgInf.needClearCache=NO;
    
    self.currBackIndex++;
    if (self.currBackIndex == [AppCore sharedInstance].appBackgrounds.count)
    {
        self.currBackIndex = 0;
    }
 
    CGSize designSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (IS_IPHONE)
    {
        // portrait
        designSize.height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        designSize.width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (url)?url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.nextBackImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.nextBackImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (image) {
                                              self.nextBackImage.image = image;
                                              self.nextBackImage.contentMode = UIViewContentModeScaleAspectFill;
                                          }
                                          
                                      });
                   }
               }];
}



#pragma mark - UI
- (void)userLoginUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.aiSilentLogin stopAnimating];
                       self.ivProfileName.frame = frameProfileNameLable;
                   });
    
    [self updateProfileDetails];
}

-(void)updateProfileDetails
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (!self.aiSilentLogin.isAnimating) //meaning that we are waiting for an answer from login, don't change the label..
                       {
                           if ([[UserManager sharedInstance] isLoggedIn])
                           {
                               NSString * fullname = [[[UserManager sharedInstance] currentUser] getUserFullName];
                               
                               [self.ivProfileName setText:fullname];
                           }
                           else
                           {
                               [self.ivProfileName setText:NSLocalizedString(@"sign_in", @"Sign In") ];
                           }
                       }
                   });
}

- (void)userLoginFailed
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.aiSilentLogin stopAnimating];
                       [self.ivProfileName setText:NSLocalizedString(@"sign_in", @"Sign In") ];
                       self.ivProfileName.frame = frameProfileNameLable;
                       [self updateProfileDetails];
                   });
}

- (void)animateSilentSignIn
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.ivProfileName setText:NSLocalizedString(@"signing_in", @"Signing In")];
                       
                       //Guy: Allowing width so be set by the size to fit method, but making sure the height doesn't change.
                       CGRect nameFrame = self.ivProfileName.frame;
                       [self.ivProfileName sizeToFit];
                       
                       self.ivProfileName.frame = CGRectMake(nameFrame.origin.x, nameFrame.origin.y, self.ivProfileName.frame.size.width, nameFrame.size.height);
                       
                       [self configureIndicatorPosition];
                       
                       [self.aiSilentLogin startAnimating];
                   });
}

- (void)configureIndicatorPosition {
    
    if (IS_IPHONE) {
        int indicatorEndXPos = self.ivProfileName.frame.origin.x + self.ivProfileName.frame.size.width + kIndicatorLeftSpacingInPixels + self.aiSilentLogin.frame.size.width;
        
        //If the indicator X pos is in the contestView frame, we make the label smaller
        if (indicatorEndXPos >= self.contestView.frame.origin.x) {
            
            self.ivProfileName.frame = CGRectMake(self.ivProfileName.frame.origin.x,
                                                  self.ivProfileName.frame.origin.y,
                                                  (self.contestView.frame.origin.x - kIndicatorLeftSpacingInPixels - self.aiSilentLogin.frame.size.width) - self.ivProfileName.frame.origin.x,
                                                  self.ivProfileName.frame.size.height);
        }
    }
    
    //the activity indicator will always be positioned "kIndicatorLeftSpacingInPixels" after the end of the "sign in" label
    //self.aiSilentLogin.frame = CGRectMake(self.ivProfileName.frame.origin.x + self.ivProfileName.frame.size.width + kIndicatorLeftSpacingInPixels,
    //                                     self.aiSilentLogin.frame.origin.y,
    //                                      self.aiSilentLogin.frame.size.width,
    //                                      self.aiSilentLogin.frame.size.height);
}

- (IBAction)openProfileAction:(id)sender
{
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable])
        return;
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        //[HSFlurry logAnalyticEvent:PARAM_NAME_SIGN_IN_MAIN_MENU];
#ifdef USE_FLURRY
//        [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_USER_PROFILE}];
#endif
    }
}

- (IBAction)contestClickAction:(id)sender
{
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED)
    {
//        [HSFlurry logEvent:FLURRY_BRIT_CO_CONTEST ];
    }
#endif
    if ([[ConfigManager sharedInstance] contestArticleID ]==nil) {
        return;
    }
    
    BOOL foundInCustomList=YES;
    GalleryItemDO * item=nil;
    
    item=[[[AppCore sharedInstance] getGalleryManager]findCustomItem:[[ConfigManager sharedInstance] contestArticleID]];
    if (item==nil) {
        foundInCustomList=NO;
        item= [[GalleryItemDO alloc] init];
        [item createCustomArticle];
        item._id=[[ConfigManager sharedInstance] contestArticleID ];
        //  item.adaID=item._id;
        
        
        [[[AppCore sharedInstance] getGalleryManager]addCustomItem:item];
    }
    
    FullScreenBaseViewController* selgal=(FullScreenBaseViewController*) [[UIManager sharedInstance] createUniversalFullScreen:[NSArray arrayWithObjects:item, nil] withSelectedIndex:0 eventOrigin:nil ];
    
    selgal.dataSourceType=eFScreenGalleryStream;
    selgal.itemDetailsRequestNeeded=!foundInCustomList;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIViewController * cntr=[[UIManager sharedInstance] pushDelegate];
                       [cntr.navigationController pushViewController:selgal animated:YES];
                   });
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NEW_PACKAGE_ALERT) {
        switch (buttonIndex) {
            case 0:
            {
                //LATER do nothing
            }
                break;
            case 1:
            {
                //YES
                //
                [self loadNewPackageFromServer];
            }
                break;
            default:
                break;
        }
    }
    
    if (alertView.tag == WIFI_ALERT) {
        switch (buttonIndex) {
            case 0:
            {
                //LATER do nothing
            }
                break;
            case 1:
            {
                //YES
                [self startLoadingAnimation];
            }
                break;
            default:
                break;
        }
    }
    
    if (alertView.tag == THREEG_ALERT) {
        switch (buttonIndex) {
            case 0:
            {
                //LATER do nothing
            }
                break;
            case 1:
            {
                //now
                [self startLoadingAnimation];
            }
                break;
            default:
                break;
        }
    }
    
    if (alertView.tag == AUTOSAVE_CRUSH_ALERT) {
        switch (buttonIndex) {
            case 0:
                [self enterRedesignAfterCrash];
                break;
            case 1:
                [[[DesignsManager sharedInstance] workingDesign] setDirty:NO];
                //remove local save design
                [[DesignsManager sharedInstance] disregardCurrentAutoSaveObject];
                break;
                
                
            default:
                break;
        }
    }
}


-(void)loadPackageFromDeviceStorage{
    //no newer file exist
    if([[PackageManager sharedInstance] loadPackageFromDeliveryPackage]){
        //sucsess to load
        NSLog(@"%@", @"sucsess to load");
    }else{
        //failed to load offline
        NSLog(@"%@", @"failed to load offline");
    }
}

-(void)loadNewPackageFromServer{
    [[PackageManager sharedInstance] removeOfflinePackage:^{
        [self startLoadingAnimation];
    }];
}

-(void)startLoadingAnimation
{
    // Define the animation completion block after the view
    // with the progress resumed to its position in the top bar
    void (^animationCompletionBlock)(BOOL) = ^void(BOOL finished)
    {
        [self.downloadingView setBackgroundColor:[UIColor clearColor]];
        [self.lblPrecentage setHidden:NO];
        [self.lblDownLoadPackage setHidden:NO];
        
        NSString * urlPath = [[[PackageManager sharedInstance] packageDetails] objectForKey:@"url"];
        [[PackageManager sharedInstance] loadPackageFromURLExt:urlPath
                                                 progressBlock:^(float precentage) {
                                                     [self.lblPrecentage setText:[NSString stringWithFormat:@"%.f%%", precentage]];
                                                 }
                                               complitionBlock:^{
                                                   [self.lblPrecentage setHidden:YES];
                                                   [self.lblDownLoadPackage setHidden:YES];
                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                       [[PackageManager sharedInstance] loadPackageFromDeliveryPackage];
                                                   });
                                               }];
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloadingView setHidden:NO];
        [UIView animateWithDuration:1.0
                              delay:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.downloadingView setTransform: CGAffineTransformMakeScale(0.55,0.55)];
                             if (IS_IPHONE) {
                                 [self.downloadingView setFrame:CGRectMake(150, 3, self.downloadingView.frame.size.width, self.downloadingView.frame.size.height)];
                             }else{
                                 [self.downloadingView setFrame:CGRectMake(822, 2, self.downloadingView.frame.size.width, self.downloadingView.frame.size.height)];
                             }
                         } completion:animationCompletionBlock];
    });
}

#ifdef  SERVER_RENDERING

- (void) galleryDesignSelected:(SavedDesign*)design withOriginalDesign:(GalleryItemDO*)originalDesign  withOriginEvent:(NSString*)origin
{
    [[UIManager sharedInstance] galleryDesignSelected:design withOriginalDesign:originalDesign  withOriginEvent:@""];
}

#endif

#pragma mark - ProductsCatalogDelegate
- (void)productSelected:(NSString *)productId andVariateId:(NSString *)variateId andVersion:(NSString *)timeStamp
{
    GalleryItemDO *item = [[GalleryItemDO alloc] createEmptyDesignWithType:e3DItem];
    item._id = [[ConfigManager sharedInstance] catalogShowRoomID]; //@"71cd9dad-331b-44b4-80e7-429e503b3907";
    
    if (item._id == nil)
    {
        return;
    }
    
    [item loadGalleryItemExtraInfo:^(BOOL success)
     {
         if ([item isUpdateRequeredForRedesign]) {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [[[UIAlertView alloc]initWithTitle:@""
                                                           message:NSLocalizedString(@"redesign_json_newer_alert", @"")
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"alert_view_dont_remind", @"") otherButtonTitles: NSLocalizedString(@"Update Now", @"Update"),nil] show];
                            });
             
             return;
         }
         
         if ((item.content == nil) || ([item.content length] == 0))
         {
             return;
         }
         
         SavedDesign *design = [SavedDesign designWithJSONString:item.content];
         [design updateLockingStateAccordingToDesignType:eFScreenEmptyRooms];
         
         //store details till main vc loaded
         [[UIManager sharedInstance] setProductId:productId];
         [[UIManager sharedInstance] setVariationId:variateId];
         [[UIManager sharedInstance] setTimeStamp:timeStamp];
         
         [[UIManager sharedInstance] galleryDesignSelected:design
                                        withOriginalDesign:item
                                           withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_CATALOG];
         
         [self getFullImagesForItem:item withCompletionBlock:nil];
     }];
}

//Used for new ImageFetcher
-(void)getFullImagesForItem:(GalleryItemDO *)item withCompletionBlock:(void(^)(BOOL success))completion
{
    NSString * bgImgURL = item.backgroundImageURL;
    NSString * origImgURL = item.originalImageURL;
    __block NSString * maskImgURL = item.maskImageURL;
    
    __block UIImage * imgBG = nil;
    __block UIImage * origImg = nil;
    __block UIImage * maskImg = nil;
    
    __block BOOL finishedImage1 = NO;
    __block BOOL finishedImage2 = NO;
    __block BOOL finishedImage3 = NO;
    
    
    void (^ internalCompBlock)(BOOL) = ^ (BOOL maskExist)
    {
        if (finishedImage1 && finishedImage2 && finishedImage3)
        {
            if (imgBG && origImg && maskImg)
            {
                [self validateRedesignImages:origImg background:imgBG mask:maskImg needMask:maskExist];
                
                if (completion) {
                    completion(YES);
                }
            }else{
                if (completion) {
                    completion(NO);
                }
            }
        }
    };
    
    NSValue *valSize = [NSValue valueWithCGSize:CGSizeZero];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (bgImgURL)?bgImgURL:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         finishedImage1 = YES;
         
         BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);
         
         imgBG = image;
         
         internalCompBlock(maskExist);
     }];
    
    
    
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (origImgURL)?origImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         finishedImage2 = YES;
         
         BOOL maskExist = !(maskImgURL!=nil && maskImg==nil);
         
         origImg = image;
         
         internalCompBlock(maskExist);
     }];
    
    
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (maskImgURL)?maskImgURL:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_URL_FORMATING:IMAGE_FETCHER_INFO_KEY_URL_FORMATING_NO_RESIZING};
    
    
    [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
     {
         finishedImage3 = YES;
         
         maskImg = image;
         
         internalCompBlock(YES);
     }];
}

- (void)validateRedesignImages:(UIImage *)original background:(UIImage *)background mask:(UIImage *)mask needMask:(BOOL)needMask {
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[UIManager sharedInstance] galleryDesignBGImageRecieved:background andOrigImage:original andMaskImage:mask];
                   });
    
}

- (BOOL)shouldDisplayLoginScreenOnStart
{
    int runCount = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"AppRunningCount"] intValue];
    
    if(![[ConfigManager sharedInstance] isConfigLoaded] || ![ConfigManager isAnyNetworkAvailable])
        return NO;
    
    BOOL isNumberOfRunsCompletedCycle = ((runCount) % [[ConfigManager sharedInstance] appQuickSignupRunCount] == 0);
    return (isNumberOfRunsCompletedCycle &&
            ![[UserManager sharedInstance] isLoggedIn] &&
            ![[UserManager sharedInstance] isSilenceLoggInProcess]);
}

- (void)openCatalogFromViewController{
    
    if (![ConfigManager isAnyNetworkAvailableOrOffline])
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"failed_action_no_network_found", @"We lost you! Check your network connection.")
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    if (![CatalogMenuLogicManger sharedInstance].catalogView) {
        [CatalogMenuLogicManger sharedInstance].catalogView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProductCatalogView"
                                                                                                             inStoryboard:kRedesignStoryboard];
    }
    [[CatalogMenuLogicManger sharedInstance].catalogView setDelegate:(id <ProductsCatalogDelegate>)self];
    [[CatalogMenuLogicManger sharedInstance].catalogView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
   
    //开启横屏
    [ESOrientationManager setAllowRotation:YES];
    
    [self presentViewController:[CatalogMenuLogicManger sharedInstance].catalogView animated:YES completion:nil];
}

- (IBAction)openMenuAction:(id)sender{
    //implemet in son's
}

- (IBAction)actionStartNewDesign:(id)sender{
    //implemet in son's
}

- (IBAction)action3DStreamSelected:(id)sender{
    //implemet in son's
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_COMMUNITY}];
#endif
}

- (IBAction)actionCatalogSelected:(id)sender{
    //implemet in son's
    
    [CatalogMenuLogicManger sharedInstance].searchHistory = nil;
    [CatalogMenuLogicManger sharedInstance].selectedCategoryId = nil;
#ifdef USE_UMENG
//    [MobClick event:@"catalog"];
#endif
    
#ifdef USE_FLURRY
//    [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_CATALOG}];
#endif
}

- (IBAction)actionHelpSelected:(id)sender{
    //implemet in son's
}

- (void) galleryDesignSelected:(SavedDesign*)design withOriginalDesign:(GalleryItemDO*)originalDesign  withOriginEvent:(NSString*)origin{
    //implemet in son's
}

- (void) galleryDesignBGImageRecieved :(UIImage*)image andOrigImage: (UIImage*)in_OrigImage andMaskImage: (UIImage*)in_maskImage{
    //implemet in son's
}

- (void) commentsPressed:(NSString*)itemID{
    //implemet in son's
}

- (BOOL) likesPressed:(DesignBaseClass*)item :(BOOL) bIsLiked :(UIViewController*) senderViewControler : (BOOL) usePushDelegate withCompletionBlock:(ROCompletionBlock)completion{
    return NO;
}

- (BOOL)likePressedForItemId:(NSString *)itemId andItemType:(ItemType)type withState:(BOOL)isLiked sender:(UIViewController*)senderView  shouldUsePushDelegate:(BOOL)usePushDelegate withCompletionBlock:(ROCompletionBlock)completion{
    return NO;
}

- (void) stopLoadingForFullScreen{
    //implemet in son's
}

- (void)setOfflineIndicatorAccordingToNetworkStatus
{
    [_offlineIcon setHidden:[ConfigManager isAnyNetworkAvailable]];
}

-(void)externalLogin:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSString *identifier = (NSString*)userInfo[ExtenalLoginExternalIdField];
    NSString *email = (NSString*)userInfo[ExtenalLoginEmailField];
    NSString *firstName = (NSString*)userInfo[ExtenalLoginFirstNameField];
    NSString *lastName = (NSString*)userInfo[ExtenalLoginLastNameField];
    NSString *token = (NSString*)userInfo[ExtenalLoginSessionKeyField];
    
    HSCompletionBlock completionBlock = ^(id serverResponse,id error)
    {
        if (!error)
        {
            [self updateProfileDetails];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login_success"
                                                                object:serverResponse
                                                              userInfo:nil];
        }
     
        [self.aiSilentLogin stopAnimating];
    };
    
    [self animateSilentSignIn];
    [[UserManager sharedInstance] HomestylerWebLogin:identifier
                                               fname:firstName
                                               lname:lastName
                                               email:email
                                           profImage:nil
                                               token:token
                                     completionBlock:completionBlock
                                               queue:dispatch_get_main_queue()];
}


-(void)animateGalleryMenuOptions:(UIView *)menuView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        menuView.alpha = 0;
        self.animationLayOutForIPhone.constant = 30;
        [UIView animateWithDuration:1.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveLinear animations:^{
            menuView.alpha = 1;
            [menuView layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    });
}

-(void)checkVersion {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        if(![[ConfigManager sharedInstance] isConfigLoaded] && ![ConfigManager isOfflineModeActive])
        {
            [ConfigManager showMessageIfDisconnected];

            return;
        }
        
        if ([[ConfigManager sharedInstance] updateExists])
        {
            if ([[ConfigManager sharedInstance] updateRequired]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"update_version_required", @"") preferredStyle:UIAlertControllerStyleAlert];
                // 创建操作
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update Now", @"Update") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    NSLog(@"%@",[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]);
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]];
                    
                }];
                
                // 添加操作
                [alert addAction:okAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self presentViewController:alert animated:YES completion:nil];
                });
                
            }
            else if ( [[ConfigManager sharedInstance] canRemindAboutUpdate])
            {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"update_version_available", @"") preferredStyle:UIAlertControllerStyleAlert];
                // 创建操作
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update Now", @"Update") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]];
                    
                }];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_view_dont_remind", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                }];
                
                // 添加操作
                [alert addAction:okAction];
                [alert addAction:cancelAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }
        
    });
    
}

-(void)checkBackgroundImages:(NSNotification *)notification {
    if ([[AppCore sharedInstance] backgroundImagesAvailable]){
        if (!self.nextBackImage)
        {
            self.nextBackImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.nextBackImage.contentMode = UIViewContentModeScaleAspectFill;
            self.nextBackImage.alpha = 0;
            [self.view insertSubview:self.nextBackImage belowSubview:self.backgroundImage];
            self.currBackIndex = 1;
            
            self.changeInterval = [[ConfigManager sharedInstance] appBackgroundInterval];
            self.changeFadeTime = [[ConfigManager sharedInstance] appBackgroundFadeTime];
            
            // Load next image
            [self loadNextImage];
        }
        
        // Start the timer after delay
        [self performSelector:@selector(startChangingBackground) withObject:nil afterDelay:self.changeInterval];
    }
}

@end
