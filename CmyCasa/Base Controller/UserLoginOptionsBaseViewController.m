//
//  UserLoginOptionsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "UserLoginOptionsBaseViewController.h"
#import "HCFacebookManager.h"
#import "UIView+Alignment.h"
#import "ConfigManager.h"

//#define BTN_WIDTH 190
//#define BTN_HIEGHT 43
#define GAP_HEIGHT 30
#define GAP_HEIGHT_IPHONE 10
#define BTN_CONTAINER_X_VAL_IPAD    600
#define BTN_CONTAINER_Y_VAL_IPAD    162
#define BTN_CONTAINER_Y_VAL_IPHONE  210

@interface UserLoginOptionsBaseViewController ()

@end

@implementation UserLoginOptionsBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FacebookLoginFailedNotification)
                                                 name:@"FacebookLoginFailedNotification" object:nil];
    
    [self generateLoginButtonsContainer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)generateLoginButtonsContainer{
    
    UIView * buttonsContainer = [[UIView alloc] init];
    CGRect frame = CGRectZero;
    CGFloat BTN_WIDTH = self.emailView.frame.size.width;
    CGFloat BTN_HIEGHT = self.emailView.frame.size.height;
    CGFloat BTN_CONTAINER_Y_VAL = IS_IPAD? BTN_CONTAINER_Y_VAL_IPAD : BTN_CONTAINER_Y_VAL_IPHONE;
    CGFloat BTN_CONTAINER_GAP_VAL = IS_IPAD? GAP_HEIGHT : GAP_HEIGHT_IPHONE;

    NSMutableArray * placeHolderArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"YES", @"YES", nil]];
    
    if ([ConfigManager isFaceBookLoginActive]) {
        _isFaceBookActive = YES;
    }
    
    if ([ConfigManager isEmailLoginActive]) {
        _isEmailActive = YES;
    }
    
    if (_isFaceBookActive && _isEmailActive) {
        frame = CGRectMake(BTN_CONTAINER_X_VAL_IPAD, BTN_CONTAINER_Y_VAL, BTN_WIDTH,  2 * BTN_HIEGHT + 2 * BTN_CONTAINER_GAP_VAL) ;
    }else {
        frame = CGRectMake(BTN_CONTAINER_X_VAL_IPAD, BTN_CONTAINER_Y_VAL, BTN_WIDTH, BTN_HIEGHT);
        [placeHolderArray removeLastObject];
    }
    
    [buttonsContainer setFrame:frame];
    
    if (_isFaceBookActive) {
        [buttonsContainer addSubview:self.facebookView];
        [placeHolderArray replaceObjectAtIndex:0 withObject:@"NO"];
    }
    
    if (_isEmailActive) {
        for (int i = 0; i < [placeHolderArray count]; i++) {
            BOOL isVacant = [[placeHolderArray objectAtIndex:i] boolValue];
            if (isVacant) {
                [buttonsContainer addSubview:self.emailView];
                [self.emailView setFrame:CGRectMake(0, i * BTN_HIEGHT + i * BTN_CONTAINER_GAP_VAL, BTN_WIDTH, BTN_HIEGHT)];
                [placeHolderArray replaceObjectAtIndex:i withObject:@"NO"];
            }
        }
    }
    
    [self.view addSubview:buttonsContainer];
    
    if (!IS_IPAD) {
        [buttonsContainer alignWithView:self.view type:eAlignmentHorizontalCenter];
    }
}

-(void)facebookPressed:(id)sender {
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_SIGNUP_OPTION_CLICK
//                withParameters:@{EVENT_PARAM_NAME_CLICK_OPTION:EVENT_PARAM_VAL_FACEBOOK_OPTION}];
//    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_FACEBOOK_SIGNUP
//                withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:self.eventLoadOrigin}];
//    
//    __block BOOL isLogedIn = NO;
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//    [login logOut];
//    [login
//     logInWithReadPermissions: @[@"public_profile", @"email"]
//     fromViewController:self
//     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//         if (error) {
//             NSLog(@"Process error");
//         } else if (result.isCancelled) {
//             NSLog(@"Cancelled");
//         } else {
//             NSLog(@"Logged in");
//             isLogedIn = YES;
//             [[HCFacebookManager sharedInstance] populateUserDetails];
//         }
//     }];
//    
//    if (isLogedIn) {
//        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error"
//                                                      message:NSLocalizedString(@"facebook_login_general_error",  "Sign in failed, please check your Facebook account details and try again.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"OK") otherButtonTitles: nil];
//        [alert show];
//    }
}

- (IBAction)signupPressed:(id)sender {
        
//    [HSFlurry logAnalyticEvent:EVENT_NAME_SIGNUP_OPTION_CLICK withParameters:@{EVENT_PARAM_NAME_CLICK_OPTION:EVENT_PARAM_VAL_EMAIL_OPTION}];
//    [HSFlurry logAnalyticEvent:EVENT_NAME_EMAIL_SIGNUP withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:self.eventLoadOrigin}];
}

-(void)FacebookLoginFailedNotification{
    [self.facebookIndicator stopAnimating];
    
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                   message:NSLocalizedString(@"facebook_login_general_error", @"")
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                         otherButtonTitles: nil];
    [alert show];
    
}

#pragma mark - TTTAttributedLabelDelegate

- (void)initTextOfStatement:(TTTAttributedLabel*)label
{

    label.delegate=self;
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName ,nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:(88/255.0) green:(165/255.0) blue:(204/255.0) alpha:1],[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    label.linkAttributes = linkAttributes;
    label.numberOfLines = 0;
    if ([label.text isEqualToString:@"tips"]) {
        
        NSString * formated = [NSString stringWithFormat:NSLocalizedString (@"autodesk_privacy_statement","")];
        
        NSString *labelText = [NSString stringWithFormat:@"%@.", formated];
        
        label.text = labelText ;
        
        NSRange rangeTermsOfService=[labelText rangeOfString:NSLocalizedString (@"User agreement","")];
        
        [label addLinkToURL:[NSURL URLWithString:[[ConfigManager sharedInstance] privacyLink]] withRange:rangeTermsOfService];
        
    }else{
        
        NSString * formated = [NSString stringWithFormat:NSLocalizedString (@"autodesk_privacy_statement_and_terms_of_service",""),NSLocalizedString(@"terms_of_service", "")];
        
        NSString *labelText = [NSString stringWithFormat:@"%@.", formated];
        
        label.text = labelText ;
        
        NSRange rangeTermsOfService=[labelText rangeOfString:NSLocalizedString(@"terms_of_service", "")];
        
        [label addLinkToURL:[NSURL URLWithString:[[ConfigManager sharedInstance] aboutLink]] withRange:rangeTermsOfService];
        
    }
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    GenericWebViewBaseViewController * iWeb=[[UIManager sharedInstance] createGenericWebBrowser:url.absoluteString];
    [self presentViewController:iWeb animated:YES completion:nil];
}
@end
