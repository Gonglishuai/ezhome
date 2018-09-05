//
//  ProfPageViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import "ProfPageViewController.h"
#import "ProfProjGalleryViewController.h"
#import "UILabel+Size.h"
#import "AppCore.h"
#import "FullScreenViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfessionalsResponse.h"
#import "ControllersFactory.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "ProgressPopupViewController.h"

#define VERTICAL_MARGIN_BETWEEN_PROJECTS (10)

@interface ProfPageViewController ()

@end

@implementation ProfPageViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    self.screenName=GA_PROFESSIONAL_SCREEN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //QA Compatibility Labels:
    self.view.accessibilityLabel = @"Professional's Page";

    [self.loadingView setHidden:YES];
    _projectViews = [[NSMutableArray alloc] init];
    
    [self updateData];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc - ProfPageViewController");
}

#pragma mark -

- (IBAction)phoneNumberPressed:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton * btn = (UIButton*)sender;
        NSString * phone = [NSString stringWithFormat:@"tel://%@", btn.titleLabel.text];
        phone = [phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *phoneUrl = [NSURL URLWithString:phone];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        }else {
            UIAlertView * calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [calert show];
        }
    }
}

- (void) updateProjects: (NSArray*) projects {
    
    for (UIViewController *vc in _projectViews) {
        [vc.view removeFromSuperview];
    }
    
    [_projectViews removeAllObjects];
    
    int i = 0;
    
    for(ProfProjects* project in projects) {
        
        ProfProjGalleryViewController* projView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfProjGallery" inStoryboard:kProfessionalsStoryboard];
        
        [self.scrollView addSubview:projView.view];
        [projView setProject:project];
        projView.delegate = self;
        [_projectViews addObject:projView];
        projView.view.frame = CGRectMake(13 , self.dynamicProjectsTitleView.frame.origin.y + 20 + VERTICAL_MARGIN_BETWEEN_PROJECTS + i * (299 + VERTICAL_MARGIN_BETWEEN_PROJECTS), 1000, 299);
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.dynamicProjectsTitleView.frame.origin.y + VERTICAL_MARGIN_BETWEEN_PROJECTS + i * (299 + VERTICAL_MARGIN_BETWEEN_PROJECTS));
}

-(void)updateProfDataInternal:(ProfessionalDO*)profData{
    
    NSArray* profs = profData.professions;
    NSString* professions = @"";
    for(NSString* profession in profs) {
        professions = [professions stringByAppendingString:profession];
        professions = [professions stringByAppendingString:@", "];
    }
    
    if ([professions length] > 2) {
        professions = [professions substringToIndex:[professions length]-2];
    }
    
    //load design image
    CGSize designSize = self.smallImageView.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (profData.userPhoto)?profData.userPhoto:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.smallImageView};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.smallImageView];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          
                                          self.smallImageView.image = image;
                                          
                                      });
                   }
               }];
    
    
    
    
    designSize = self.bigImageView.frame.size;
    valSize = [NSValue valueWithCGSize:designSize];
    dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (profData.posterImage)?profData.posterImage:@"",
            IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
            IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
            IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.bigImageView};
    
    lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.bigImageView];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          
                                          self.bigImageView.image = image;
                                          
                                      });
                   }
               }];
    
    [self performSelector:@selector(highlightLikeButton:) withObject:self.likeBtn afterDelay:0.0];
    
    NSString* name = [NSString stringWithFormat:@"%@ %@", [profData firstName], [profData lastName]];
    self.nameLabel.text = name;
    self.professionLabel.text = professions;
    self.likesLabel.text = [NSString stringWithFormat:@"%d", [[profData likesCount] intValue]];
    _webSiteUrl = [profData web];
    
    
    if ([_webSiteUrl hasPrefix:@"http://"]==false && [_webSiteUrl hasPrefix:@"https://"]==false) {
        _webSiteUrl=[NSString stringWithFormat:@"http://%@",_webSiteUrl];
    }
    
    [self.phone1Label setTitle:[profData phone1] forState:UIControlStateNormal];
    [self.phone2Label setTitle:[profData phone2] forState:UIControlStateNormal];

    _email = [profData email];
    self.addressLabel.text =profData.address;
    self.addressLabel.numberOfLines=3;
    CGSize nsize=   [self.addressLabel getActualTextHeightForLabel:80];
    
    self.addressLabel.frame=CGRectMake(self.addressLabel.frame.origin.x,
                                       self.addressLabel.frame.origin.y,
                                       self.addressLabel.frame.size.width, nsize.height);
    
    self.descriptionLabel.text = profData._description;
    
    //resize description area
    CGSize descsize=[self.descriptionLabel getActualTextHeightForLabel:999000];
    
    
    CGRect t=self.dynamicPromoView.frame;
    
    if (descsize.height>72) {
        t.size.height=373+descsize.height+20;//467+newdelta+20;
    }else{
        t.size.height=467;
    }
    
    self.dynamicPromoView.frame=t;
    
    if(t.size.height!=467)
    {
        CGRect r=self.dynamicProjectsTitleView.frame;
        int newdelta = descsize.height-72;
        r.origin.y = 610 + newdelta + 40;
        self.dynamicProjectsTitleView.frame=r;
    }
    else
    {
        CGRect r=self.dynamicProjectsTitleView.frame;
        r.origin.y = 610 + 40;
        self.dynamicProjectsTitleView.frame=r;
        
    }
    
    [self updateProjects:[profData projects]];
}

- (void) updateData {
    //NEW CORE TEST
    [self.loadingView setHidden:NO];
    
    [[[AppCore sharedInstance] getProfsManager]getProffesionalByID:_profId completionBlock:^(id serverResponse, id error) {
        
        if (error)
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"proffesional_load_failed_msg", @"There was a problem loading this protfolio.\nPlease try again") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            ProfessionalsResponse * profData=(ProfessionalsResponse*)serverResponse;
            [self updateProfDataInternal:profData.currentProfessional];
        }
        
        [self.loadingView setHidden:YES];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        
    } queue:dispatch_get_main_queue()];
}

- (void) setProfId:(NSString*) profId {
    _profId = profId;
}

- (void) designSelected:(NSMutableArray*)designIds :(int)selectedDesignIdx {
    
    FullScreenViewController_iPad* imageViewController=(FullScreenViewController_iPad*) [[UIManager sharedInstance] createFullScreenGallery:designIds withSelectedIndex:selectedDesignIdx eventOrigin:nil ];
    
    imageViewController.dataSourceType=eFScreenGalleryStream;
    
    [self.navigationController pushViewController:imageViewController animated:YES];
}

- (void)changeLikeBtnStateToLiked:(BOOL)isLiked {
    self.likeBtn.hidden = isLiked;
    self.likeBtnLiked.hidden = !isLiked;
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)highlightLikeButton:(UIButton *)b {
    
    BOOL isCurrentlyFollowed = [[[AppCore sharedInstance]getProfsManager] isProfessionalFollowed:_profId];
    [self changeLikeBtnStateToLiked:isCurrentlyFollowed];
}

- (IBAction)likeBtnPressed:(id)sender {
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_FOLLOW_PROFESSIONAL, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_LIKE}];
        
        if ([ConfigManager isSignInWebViewActive]) {
            [ExternalLoginViewController showExternalLogin:self];
        }else{
            if (!_userLoginViewController) {
                _userLoginViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
                _userLoginViewController.userLogInDelegate = self;
                _userLoginViewController.eventLoadOrigin = EVENT_PARAM_LOAD_ORIGIN_LIKE;
                [self.view addSubview:_userLoginViewController.view];
                _userLoginViewController.openingType = eView;
                _userLoginViewController.view.frame = self.view.frame;
            }
        }
      
        return;
    }
    
    self.likeBtn.enabled = NO;
    
    [[[AppCore sharedInstance] getProfsManager]getProffesionalByID:_profId completionBlock:^(id serverResponse, id error) {
        
        if (error) {
            
        }else{
            ProfessionalsResponse * profData=(ProfessionalsResponse*)serverResponse;
            
            
            Boolean isCurrentlyFollowed = [[[AppCore sharedInstance]getProfsManager] isProfessionalFollowed:_profId];
            
            //if currently unfollow mark as follow
            [self changeLikeBtnStateToLiked:!isCurrentlyFollowed];

            
#ifdef USE_FLURRY
            if(ANALYTICS_ENABLED){
                
                NSArray * objs=[NSArray arrayWithObjects:_profId,[NSNumber numberWithBool:!isCurrentlyFollowed], nil];
                NSArray * keys=[NSArray arrayWithObjects:@"prof_id",@"follow_status", nil];
                
//                [HSFlurry logEvent:FLURRY_PROFESIONAL_FOLLOW withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
            }
#endif
            
            [[[AppCore sharedInstance] getProfsManager]followProfessional:_profId followStatus:!isCurrentlyFollowed completionBlock:^(id serverResponse, id error) {
                
                self.likeBtn.enabled = YES;
                if (error==nil) {
                    //on success do nothing because we already updated the counters
                    self.likesLabel.text = [NSString stringWithFormat:@"%d", [[profData.currentProfessional likesCount] intValue]];
                    
                    //if currently unfollow mark as follow
                    [self changeLikeBtnStateToLiked:!isCurrentlyFollowed];
                    
                }else{
                    //on response failure we do reverse action of what we did before and assign backup Count
                    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                                   message:NSLocalizedString(@"prof_follow_error", @"")
                                                                  delegate:nil
                                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles: nil];
                    [alert show];
                }
            } queue:dispatch_get_main_queue()];
        }
    } queue:dispatch_get_main_queue()];
}

- (IBAction)webSitePressed:(id)sender {
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:_profId,_webSiteUrl, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"prof_id",@"url", nil];
//        [HSFlurry logEvent:FLURRY_PROFESIONAL_SITE_VISIT withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
    
    NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:_webSiteUrl];
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:urlWithReferer];
    [self presentViewController:web animated:YES completion:nil];
}

- (IBAction)emailPressed:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
        return;
    }
    if ([self.emailLabel.text length] < 5 || ![MFMailComposeViewController canSendMail])
        return;
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    [mailer setSubject:NSLocalizedString(@"prof_email_subject", @"Homestyler Professional Enquiry")];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:_email, nil];
    [mailer setToRecipients:toRecipients];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:mailer animated:YES completion:nil];
    });
    
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        NSArray * objs=[NSArray arrayWithObjects:_profId, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"prof_id", nil];
        if (_profId) {
//            [HSFlurry logEvent:FLURRY_PROFESIONAL_EMAIL_WRITE withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
    }
#endif
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            HSMDebugLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            HSMDebugLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            HSMDebugLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            HSMDebugLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            HSMDebugLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void) loginRequestEndedwithState:(BOOL) state
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (BOOL)shouldAutorotate{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation) || (orientation == UIDeviceOrientationUnknown);
}

@end
