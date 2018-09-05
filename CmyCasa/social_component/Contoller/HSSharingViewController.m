//
//  HSSharingViewController.m
//  ADSharingComponent
//
//  Created by Ma'ayan on 10/9/13.
//  Copyright (c) 2013 Ma'ayan. All rights reserved.
//

#import "HSSharingViewController.h"
#import "HSSharingConstants.h"
#import "HSSharingLogic.h"
#import "HSSocialManager.h"
#import "HSShareObject.h"
#import <MessageUI/MessageUI.h>
#import "Reachability.h"
#import "ProgressPopupBaseViewController.h"
#import "Reachability.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "UIImage+Scale.h"
#import "QRCodeSharingViewController.h"

@interface HSSharingViewController () <SocialManagerSharingDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate>
{
    BOOL isSoloTwitterSharePending; //solo twitter request is when the user shares more than 140 chars and he gets notified that twitter failed due to this
    BOOL moved;
}

@property (nonatomic) BOOL isEmailShareCancelled;
@property (nonatomic, strong) NSMutableArray * errorsList;
@property (nonatomic, strong) NSMutableArray * successList;
@property (weak, nonatomic) IBOutlet UILabel *twitterLimitExceedNotifce;

@property (nonatomic, weak) IBOutlet UITextView *tvShareTextView;
@property (nonatomic, weak) IBOutlet UIImageView *ivShareImage;
@property (nonatomic, weak) IBOutlet UIView *ivShareImageView;
@property (nonatomic, weak) IBOutlet UIButton *btnFacebook;
@property (nonatomic, weak) IBOutlet UIButton *btnTwitter;
@property (nonatomic, weak) IBOutlet UIButton *btnEmail;
@property (nonatomic, weak) IBOutlet UIButton *btnFriend;
@property (nonatomic, weak) IBOutlet UIButton *btnMoment;
@property (nonatomic, weak) IBOutlet UIButton *btnQRCode;
@property (nonatomic, weak) IBOutlet UIButton *btnShare;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) HSSharingLogic *logic;
@property (nonatomic, strong) UIImage *imgShareImage;
@property (nonatomic, strong) NSURL *urlShareImage;
@property (nonatomic, strong) NSString *designShareLink;
@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) NSString *shareDescription;

//Temp
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *tempActivityIndicator;

- (IBAction)buttonClickedDone:(id)sender;
- (IBAction)buttonClickedCancel:(id)sender;
- (IBAction)buttonTouchDown:(id)sender;

@end

@implementation HSSharingViewController

-(void)initWithShareData:(HSShareObject*)shareObj{

    self.logic = [[HSSharingLogic alloc] initWithText:shareObj];
    self.imgShareImage = shareObj.picture;
    
    self.urlShareImage = shareObj.pictureURL;
    
    self.designShareLink = shareObj.designShareLink;
    self.shareMessage = [NSString stringWithFormat:@"%@ | %@", shareObj.message, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    self.shareDescription = NSLocalizedString(@"share_description", @"");
}

- (id)initWithShareText:(HSShareObject*)shareObj
{
    NSString *xibName = IS_IPAD ? kHSSharingViewControllerXibNameiPad : kHSSharingViewControllerXibNameiPhone;
    
    self = [self initWithNibName:xibName bundle:[NSBundle mainBundle]];
      
    if (self)
    {
        [self initWithShareData:shareObj];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.errorsList = [NSMutableArray arrayWithCapacity:0];
    self.successList = [NSMutableArray arrayWithCapacity:0];
    self.isEmailShareCancelled = NO;

    if (IS_IPHONE_5)
    {
        [self fitForiPhone5];
    }
    
    [self setUI];
    
    [self setDebugView];
    
    [self setUIStrings];
    
    [self refreshUIData];
    
    [[HSSocialManager sharedSocialManager] setViewController:self];
    [[HSSocialManager sharedSocialManager] setupFacebookDelegate:self];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;  // this prevents the gesture recognizers to 'block' touches
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self selectPreferedButtons];
    
    [self updateShareButton];
    [self showActivityIndicator:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if ([ConfigManager isWhiteLabel]) {
        [self.shareContainer setHidden:NO];
    }
    
    [super viewWillDisappear:animated];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([ConfigManager isWeChatActive]){
        CGRect rect = [[UIScreen mainScreen] bounds];
        self.ivShareImageView.center = CGPointMake(rect.size.width / 2, self.ivShareImageView.center.y);
        self.ivShareImageView.bounds = CGRectMake(0, 0, self.ivShareImage.bounds.size.width, self.ivShareImageView.bounds.size.height);
    }
}

-(void)dealloc{
    [[HSSocialManager sharedSocialManager] setupFacebookDelegate:nil];
    NSLog(@"dealloc - HSSharingViewController");
}

#pragma mark - Class Function

-(void)updateShareButton{
    if (self.logic.isNoSelection || self.imgShareImage == nil) {
        [self.btnShare setEnabled:NO];
    }else{
        [self.btnShare setEnabled:YES];
    }
}

-(void)refreshUIData
{
    if (self.logic)
    {
        [self.logic setSharingText:[self.logic getSharingTextWithHashtags]];
        
        self.tvShareTextView.text = [self.logic getSharingText];
    }
    
    self.tvShareTextView.delegate = self;
    self.ivShareImage.image = self.imgShareImage;
    
    isSoloTwitterSharePending = NO;
}

- (void)fitForiPhone5
{
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.tvShareTextView.frame = CGRectMake(self.tvShareTextView.frame.origin.x, self.tvShareTextView.frame.origin.y, self.tvShareTextView.frame.size.width, 160);
}

- (void)setUI
{
    if ([ConfigManager isWeChatActive])
    {
        self.btnFacebook.hidden = self.btnTwitter.hidden = self.btnEmail.hidden = YES;
        self.tvShareTextView.hidden = YES;
        self.btnFriend.hidden = self.btnMoment.hidden = self.btnQRCode.hidden = NO;
        self.btnShare.hidden = YES;
    } else {
        self.btnFacebook.hidden = self.btnTwitter.hidden = self.btnEmail.hidden = NO;
        self.tvShareTextView.hidden = NO;
        self.btnFriend.hidden = self.btnMoment.hidden = self.btnQRCode.hidden = YES;
        self.btnShare.hidden = NO;
    }
    if (IS_IPAD) {
        self.shareContainer.transform = CGAffineTransformMakeTranslation(0, -50);
    }
    self.view.frame = [[UIScreen mainScreen] bounds];
}

- (void)setUIStrings
{
    //all UI strings that do not change during app runing
    if (IS_IPAD) {
        [self.btnCancel setTitle:NSLocalizedString(kHSSharingViewControllerTitleButtonCancel, nil) forState:UIControlStateNormal];
    }
    [self.lblTitle setText:NSLocalizedString(kHSSharingViewControllerTitleLabelTitle, nil)];
    [self.btnShare setTitle:NSLocalizedString(kHSSharingViewControllerTitleButtonShare, nil) forState:UIControlStateNormal];
    [self.btnBack setTitle:NSLocalizedString(@"save_design_override_action_back", @"") forState:UIControlStateNormal];
    [self.btnSkip setTitle:NSLocalizedString(@"share_your_design_skip_button_title", @"") forState:UIControlStateNormal];
}

- (void)setDebugView
{
    self.tempActivityIndicator.hidden = YES;
    self.tempActivityIndicator.userInteractionEnabled = NO;
    [self.tempActivityIndicator stopAnimating];
}

- (void)showActivityIndicator:(BOOL)show
{
    if (show) {
        self.btnShare.enabled = NO;
        if (self.btnDone != nil) {
            self.btnDone.enabled = NO;
        }
        if (self.activityIndicator != nil) {
            [self.activityIndicator setHidden:NO];
            [self.activityIndicator startAnimating];
        } else {
            [[ProgressPopupBaseViewController sharedInstance] startLoadingWithoutText:self];
        }
    } else {
        self.btnShare.enabled = YES;
        if (self.btnDone != nil) {
            self.btnDone.enabled = YES;
        }
        if (self.activityIndicator != nil) {
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
        } else {
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        }
    }
}

- (void)selectPreferedButtons
{
    //select the last state the user had used or the default state
    [self deselectButton:self.btnFacebook];
    [self deselectButton:self.btnTwitter];
    [self deselectButton:self.btnEmail];
    
    [self.logic clearGeneralSharingIntentQueue];
    [self.logic clearSharingIntentQueue];
    
    NSDictionary *dicPrefs = [self.logic getUserSharingPreferences];
    
    if (dicPrefs.count == 0) //first use
    {
        [self selectButton:self.btnFacebook];
        [self.logic addGeneralSharingIntentType:HSSharingIntentTypeFacebook];
    }
    else
    {
        for (NSNumber *num in [dicPrefs allKeys])
        {
            switch (num.intValue)
            {
                case HSSharingIntentTypeFacebook:
                    [self selectButton:self.btnFacebook];
                    [self.logic addGeneralSharingIntentType:HSSharingIntentTypeFacebook];
                    break;
                case HSSharingIntentTypeTwitter:
                    [self selectButton:self.btnTwitter];
                    [self.logic addGeneralSharingIntentType:HSSharingIntentTypeTwitter];
                    break;
                case HSSharingIntentTypeEmail:
                    [self selectButton:self.btnEmail];
                    [self.logic addGeneralSharingIntentType:HSSharingIntentTypeEmail];
                    break;
            }
        }
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    if (IS_IPAD)
    {
        return YES;
    }
    
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Button Clicks
- (IBAction)buttonClickedDone:(id)sender
{
    if (self.logic && self.tvShareTextView)
    {
        [self.logic setSharingText: self.tvShareTextView.text];
    }

    [self startSharingProccess];
}

- (IBAction)buttonClickedCancel:(id)sender
{
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_CANCEL];
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(didCancelSharingViewController)]))
    {
        [self.delegate didCancelSharingViewController];
    }
    
    if (IS_IPAD) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)buttonTouchDown:(id)sender
{
    [self toggleImageForButton:sender];
    
    HSSocialManager *socialMgr = [HSSocialManager sharedSocialManager];

    if (sender == self.btnFacebook)
    {
        if ([[self.btnFacebook titleColorForState:UIControlStateNormal] isEqual:[self.btnFacebook titleColorForState:UIControlStateSelected]])
        {
            if ([socialMgr canShareType:HSSocialNetworkTypeFacebook])
            {
                [self.logic addGeneralSharingIntentType:HSSharingIntentTypeFacebook];
            }
            else
            {
                [socialMgr tryLoginToType:HSSocialNetworkTypeFacebook withCompletion:^(id serverResponse, id error) {
                    if (error)
                    {
                        [self toggleImageForButton:sender];
                    }
                    else
                    {
                        [self.logic addGeneralSharingIntentType:HSSharingIntentTypeFacebook];
                    }
                }];
            }
        }
        else
        {
            [self.logic removeGeneralSharingIntentType:HSSharingIntentTypeFacebook];
        }
    }
    else if (sender == self.btnTwitter)
    {
        if ([[self.btnTwitter titleColorForState:UIControlStateNormal] isEqual:[self.btnTwitter titleColorForState:UIControlStateSelected]])
        {
            [self.btnTwitter setUserInteractionEnabled:NO];
            [socialMgr canShareWithTwitter:^(BOOL valid){
                if (valid)
                {
                    [self.logic addGeneralSharingIntentType:HSSharingIntentTypeTwitter];
                }
                else
                {
                    [socialMgr tryLoginToType:HSSocialNetworkTypeTwitter withCompletion:^(id serverResponse, id error) {
                        if (error)
                        {
                            [self toggleImageForButton:sender];
                        }
                        else
                        {
                            [self.logic addGeneralSharingIntentType:HSSharingIntentTypeTwitter];
                        }
                        [self.btnTwitter setUserInteractionEnabled:YES];
                        [self updateShareButton];
                    }];
                }
                [self.btnTwitter setUserInteractionEnabled:YES];
                [self updateShareButton];
            }];
        }
        else
        {
            [self.logic removeGeneralSharingIntentType:HSSharingIntentTypeTwitter];
        }
    }
    else if (sender == self.btnEmail)
    {
        if ([[self.btnEmail titleColorForState:UIControlStateNormal] isEqual:[self.btnEmail titleColorForState:UIControlStateSelected]])
        {
            if ([MFMailComposeViewController canSendMail])
            {
                [self.logic addGeneralSharingIntentType:HSSharingIntentTypeEmail];
            }
            else
            {
                [self toggleImageForButton:sender];
                [self showAlertMessage:NSLocalizedString(kHSSharingViewControllerAlertConfigureEmail, nil)];
            }
        }
        else
        {
            [self.logic removeGeneralSharingIntentType:HSSharingIntentTypeEmail];
        }
    }
    else if (sender == self.btnFriend)
    {
        if (![WXApi isWXAppInstalled]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:NSLocalizedString(@"erh_wechat_not_installed_error_msg", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                   otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
        sendReq.bText = NO;//不使用文本信息
        sendReq.scene = 0; //0 = 好友列表 1 = 朋友圈 2 = 收藏
        
        //创建分享内容对象
        WXMediaMessage *urlMessage = [WXMediaMessage message];
        urlMessage.title = self.shareMessage;
        urlMessage.description = self.shareDescription;
        [urlMessage setThumbImage:[self.imgShareImage scaleImageTo800]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = self.designShareLink;//分享链接
        
        //完成发送对象实例
        urlMessage.mediaObject = webObj;
        sendReq.message = urlMessage;
        
        //发送分享信息
        [WXApi sendReq:sendReq];
    }
    else if (sender == self.btnMoment)
    {
        if (![WXApi isWXAppInstalled]) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:NSLocalizedString(@"erh_wechat_not_installed_error_msg", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                   otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
        sendReq.bText = NO;//不使用文本信息
        sendReq.scene = 1; //0 = 好友列表 1 = 朋友圈 2 = 收藏
        
        //创建分享内容对象
        WXMediaMessage *urlMessage = [WXMediaMessage message];
        urlMessage.title = self.shareMessage;
        urlMessage.description = self.shareDescription;
        [urlMessage setThumbImage:[self.imgShareImage scaleImageTo800]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = self.designShareLink;//分享链接
        
        //完成发送对象实例
        urlMessage.mediaObject = webObj;
        sendReq.message = urlMessage;
        
        //发送分享信息
        [WXApi sendReq:sendReq];
    }
    else if (sender == self.btnQRCode)
    {
        QRCodeSharingViewController *qrVC = [[QRCodeSharingViewController alloc] initWithString:self.designShareLink];
            
        [qrVC.view setFrame:self.view.bounds];
        [self.view addSubview:qrVC.view];
        [self addChildViewController:qrVC];
        
    }
    
    [self updateShareButton];
}

#pragma mark - UI Supporting Functions

//this is just a comfort method that is using the Selected state to hold whatever image should be the next "Normal" image, and the Disabled state for the "Highlighted" image
- (void)toggleImageForButton:(UIButton *)button
{    
    if ([[button titleColorForState:UIControlStateNormal] isEqual:[button titleColorForState:UIControlStateSelected]]) //the button was selected
    {
        [self deselectButton:button];
    }
    else //the button was unselected
    {
        [self selectButton:button];
    }
}

- (void)selectButton:(UIButton *)button
{
    [button setTitleColor:[button titleColorForState:UIControlStateSelected] forState:UIControlStateNormal];
    [button setTitleColor:[button titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [button setTitleColor:[button titleColorForState:UIControlStateSelected] forState:UIControlStateHighlighted];
}

- (void)deselectButton:(UIButton *)button
{
    [button setTitleColor:[button titleColorForState:UIControlStateDisabled] forState:UIControlStateNormal];
    [button setTitleColor:[button titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    [button setTitleColor:[button titleColorForState:UIControlStateDisabled] forState:UIControlStateHighlighted];
}

#pragma mark - UI Logic
- (void)showAlertMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       UIAlertView *avError = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", nil) otherButtonTitles:nil];
                       [avError show];
                   });
}

- (BOOL)canShareToIntentType:(HSSharingIntentType)type
{
    if (![[ReachabilityManager sharedInstance] isConnentionAvailable])
    {
        [self showAlertMessage:NSLocalizedString(kHSSharingViewControllerAlertNoData, nil)];
        return NO;
    }
    else if ((self.imgShareImage == nil) || (self.urlShareImage == nil))
    {
        [self showAlertMessage:NSLocalizedString(kHSSharingViewControllerAlertNoPhoto, nil)];
        return NO;
    }
    
    if (type == HSSharingIntentTypeFacebook)
    {
        
    }
    else if (type == HSSharingIntentTypeTwitter)
    {
        if (self.tvShareTextView.text.length > 140)
        {
            isSoloTwitterSharePending = YES;
        }
    }
    else if (type == HSSharingIntentTypeEmail)
    {
        
    }
    
    return YES;
}

#pragma mark - UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.logic setSharingText:[self.tvShareTextView.text stringByReplacingCharactersInRange:range withString:text]];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    if (!moved) {
        [self animateViewToPosition:self.shareInfoView directionUP:YES];
        moved = YES;
    }
}

- (void)hideKeyboard
{
    [self.tvShareTextView resignFirstResponder];
    if (moved) {
        [self animateViewToPosition:self.shareInfoView directionUP:NO];
    }
    moved = NO;
}

- (void)animateViewToPosition:(UIView *)viewToMove directionUP:(BOOL)up {
    
    const int movementDistance = -120;
    const float movementDuration = 0.3f;
    
    int movement = (up ? movementDistance : -movementDistance);
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    viewToMove.frame = CGRectOffset(viewToMove.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - SN Sharing
- (void)startSharingProccess
{
    [self showActivityIndicator:YES];
    
    self.isEmailShareCancelled=NO;
    [self.successList removeAllObjects];
    [self.errorsList removeAllObjects];
    
    [self.tvShareTextView resignFirstResponder];
    isSoloTwitterSharePending = NO;
    
    [self.logic saveUserSharingPreferences];
    
    [self.logic initCurrentSharingQueue];

    if ([self.logic hasSharingIntentsPending] && [self.logic getNextSharingIntentType] != HSSharingIntentTypeFacebook){
        [self shareToIntentType:[self.logic getNextSharingIntentType]];
    }
    else // user tried to share with no SN selected
    {
        [self shareToIntentType:HSSharingIntentTypeFacebook]; //hard coded by product request
    }
}

- (void)sharingProccessDidFinish
{
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(didFinishSharingViewController)])){
        [self.delegate didFinishSharingViewController];
    }
    
    [self showActivityIndicator:NO];
    [self generateFinishAlert];
}

- (void)shareToIntentType:(HSSharingIntentType)type
{
    if ([self canShareToIntentType:type]){
        switch (type) {
            case HSSharingIntentTypeFacebook:{
                HSShareObject * obj=[self.logic getCurrentShareObject];
                obj.type=HSSocialNetworkTypeFacebook;
                [[HSSocialManager sharedSocialManager] shareText:obj fromViewController:self withDelegate:self];
            }
                break;
            case HSSharingIntentTypeTwitter:
                if (!isSoloTwitterSharePending){
                    HSShareObject * obj=[self.logic getCurrentShareObject];
                    obj.type=HSSocialNetworkTypeTwitter;
                    [[HSSocialManager sharedSocialManager] shareText:obj fromViewController:self withDelegate:self];
                }else{
                    [self didFinishShareToSocialNetworkType:HSSocialNetworkTypeTwitter];
                }
                break;
            case HSSharingIntentTypeEmail:
                [self shareByEmail];
                break;
            case HSSharingIntentTypeNone:
                break;
        }
    } else {
        [self showActivityIndicator:NO];
    }
}

- (void)didFinishShareToIntentType:(HSSharingIntentType)type
{
    if (![self isErrorExistsForSharingNetwork:type] && ![self isSuccessExistsForSharingNetwork:type]) {
        [self.successList addObject:[NSNumber numberWithInt:type]];
    }

    [self.logic removeSharingIntentTypeFromQueue:type];
    
    if ([self.logic hasSharingIntentsPending])
    {
        [self shareToIntentType:[self.logic getNextSharingIntentType]];
    }
    else if (isSoloTwitterSharePending == YES)
    {
        [self showActivityIndicator:NO];
        [self setTwitterSoloShare];
    }
    else
    {
        [self sharingProccessDidFinish];
    }
}

#pragma mark - SocialManagerSharingDelegate
- (void)didFinishLoginWithAccessTokenNetworkType:(HSSocialNetworkType)type{

    if (![[self.btnFacebook titleColorForState:UIControlStateNormal] isEqual:[self.btnFacebook titleColorForState:UIControlStateSelected]])
    {
         [self buttonTouchDown:self.btnFacebook];
    }
}
- (void)didFinishShareToSocialNetworkType:(HSSocialNetworkType)type
{
    HSSharingIntentType sharingType = [self.logic getSharingIntentTypeFromSocialNetworkType:type];
    [self didFinishShareToIntentType:sharingType];
}

- (void)shareToSocialNetworkType:(HSSocialNetworkType)type didFailWithError:(NSString *)errorString
{
    //rememeber that network type error appeared
    
    if (![self isErrorExistsForSharingNetwork:[self.logic getSharingIntentTypeFromSocialNetworkType:type]]) {
        [self.errorsList addObject:[NSNumber numberWithInt:[self.logic getSharingIntentTypeFromSocialNetworkType:type]]];
        
    }
   
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                        dispatch_async(dispatch_get_main_queue(), ^
                                      {//only if no other sharing intents, stop loading
                                          if (![self.logic hasSharingIntentsPending])
                                          {
                                              [self showActivityIndicator:NO];
                                          }
                                      });
                       //if any other sharing exists, continue
                      
                       HSSharingIntentType sharingType = [self.logic getSharingIntentTypeFromSocialNetworkType:type];
                       [self didFinishShareToIntentType:sharingType];
                   });
}

#pragma mark - MFMailComposer

- (void)shareByEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        if ([ConfigManager getAppName] && [self.logic getSharingTextForEmail] && self.imgShareImage) {
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setSubject:[ConfigManager getAppName]];
            [composeViewController setMessageBody:[NSString stringWithFormat:@"%@", [self.logic getSharingTextForEmail]] isHTML:NO];
            [composeViewController addAttachmentData:UIImagePNGRepresentation(self.imgShareImage) mimeType:@"image/png" fileName:[self.urlShareImage absoluteString]];
   
            [self presentViewController:composeViewController animated:YES completion:nil];
        }else{
            [self didFailToShareByEmail:HSSharingFailNoEmailAccount];
        }
    }
    else
    {
        [self didFailToShareByEmail:HSSharingFailNoEmailAccount];
    }
}

- (void)didFailToShareByEmail:(HSSharingErrorType)result
{
    if (result!=HSSharingFailEmailCancelled && ![self isErrorExistsForSharingNetwork:HSSharingIntentTypeEmail]) {
        [self.errorsList addObject:[NSNumber numberWithInt:HSSharingIntentTypeEmail]];
    }else{
        self.isEmailShareCancelled=YES;
    }
    
    if (![self.logic hasSharingIntentsPending])
    {
        [self showActivityIndicator:NO];
    }
    
    //continue sharing anyway
    [self didFinishShareToIntentType:HSSharingIntentTypeEmail];
}

- (void)didSucceedToShareByEmail
{
    [self didFinishShareToIntentType:HSSharingIntentTypeEmail];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    BOOL isSharing = NO;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            isSharing = YES;
            break;
        case MFMailComposeResultFailed:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
         if (isSharing)
         {
             [self didSucceedToShareByEmail];
         }
         else
         {
             HSSharingErrorType errorType;
             if (result == MFMailComposeResultCancelled || result == MFMailComposeResultSaved)
             {
                 errorType = HSSharingFailEmailCancelled;
             }
             else
             {
                 errorType = HSSharingFail;
             }
             [self didFailToShareByEmail:errorType];
         }
     }];
}

#pragma mark - Twitter Alert Message

- (void)displayTwitterLoginExplanation
{
    [self showAlertMessage:NSLocalizedString(kHSSharingViewControllerAlertTwitterLogin, nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTwitterSoloShare
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self deselectButton:self.btnFacebook];
                       [self deselectButton:self.btnTwitter];
                       [self deselectButton:self.btnEmail];
                       
                       [self selectButton:self.btnTwitter];
                       
                       [self.logic clearSharingIntentQueue];
                       [self.logic clearGeneralSharingIntentQueue];
                       
                       [self.logic addGeneralSharingIntentType:HSSharingIntentTypeTwitter];
                       [self showAlertMessage:NSLocalizedString(kHSSharingViewControllerAlertTooMuchCharacters, nil)];
                   });
}


#pragma mark error handling

-(BOOL)isErrorExistsForSharingNetwork:(HSSharingIntentType)type{
    for (int i=0; i<[self.errorsList count]; i++) {
        if ([[self.errorsList objectAtIndex:i] intValue]==type) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isSuccessExistsForSharingNetwork:(HSSharingIntentType)type{
    for (int i=0; i<[self.successList count]; i++) {
        if ([[self.successList objectAtIndex:i] intValue]==type) {
            return YES;
        }
    }
    
    return NO;
}

-(void)generateFinishAlert{
    
    NSString * networks=@"";
    for (int i=0; i<[self.errorsList count]; i++) {
        switch ([[self.errorsList objectAtIndex:i] intValue]) {
            case HSSharingIntentTypeFacebook:
                networks=[NSString stringWithFormat:@"%@, %@",networks,NSLocalizedString(@"multi_share_fail_msg_part_2_fb", nil)];
                break;
            case HSSharingIntentTypeTwitter:
                networks=[NSString stringWithFormat:@"%@, %@",networks,NSLocalizedString(@"multi_share_fail_msg_part_2_twitter", nil)];
                break;
            case HSSharingIntentTypeEmail:
                networks=[NSString stringWithFormat:@"%@, %@",networks,NSLocalizedString(@"share_option_email", nil)];
                break;
                
            default:
                break;
        }
    }
    
    if([networks length]>0)networks=[networks stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
    
    
    NSString * successNetworks=@"";
    for (int i=0; i<[self.successList count]; i++) {
        switch ([[self.successList objectAtIndex:i] intValue]) {
            case HSSharingIntentTypeFacebook:
                successNetworks=[NSString stringWithFormat:@"%@\n%@",successNetworks,NSLocalizedString(@"multi_share_fail_msg_part_2_fb", nil)];
                
                break;
            case HSSharingIntentTypeTwitter:
                successNetworks=[NSString stringWithFormat:@"%@\n%@",successNetworks,NSLocalizedString(@"multi_share_fail_msg_part_2_twitter", nil)];
                
                break;
            case HSSharingIntentTypeEmail:
                successNetworks=[NSString stringWithFormat:@"%@\n%@",successNetworks,NSLocalizedString(@"share_option_email", nil)];
                
                break;
                
            default:
                break;
        }
    }
    if([successNetworks length]>0)successNetworks=[successNetworks stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    
    //full success
    if ([self.errorsList count]==0) {
        
        if (self.isEmailShareCancelled==YES
            && [self.successList count]==1
            && [[self.successList objectAtIndex:0] intValue]==HSSharingIntentTypeEmail)  {
            //for email only case were email canceled
            return;
        }
        [self showAlertMessage:[NSString stringWithFormat:@"%@", NSLocalizedString(@"multi_share_all_success", nil)]];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_OPEN withParameters:
//         @{EVENT_PARAM_SHARE_DESTINATION:(successNetworks!=nil)?successNetworks:@"unknown"}];
        
        return;
    }
    
 
    
    //partial success
    if ([self.errorsList count]>0 && [self.successList count]>0) {
     
        NSString *success=NSLocalizedString(@"multi_share_part_success", nil);;
   
        NSString *failed= NSLocalizedString(@"multi_share_part_success_part2", nil);
        
        
        NSString * fail_msg=[NSString stringWithFormat:failed,networks];
        
        NSString * success_msg=[NSString stringWithFormat:success,successNetworks];

        [self showAlertMessage:[NSString stringWithFormat:@"%@\n%@",success_msg,fail_msg]];
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_OPEN withParameters:
//         @{EVENT_PARAM_SHARE_DESTINATION:(successNetworks!=nil)?successNetworks:@"unknown"}];
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_ACTION_FAILURE withParameters:
//         @{EVENT_PARAM_SHARE_DESTINATION:(networks!=nil)?networks:@"unknown"}];
        
    }
    
    //no success
    if ([self.errorsList count]>0 && [self.successList count]==0) {
        NSString *failed=NSLocalizedString(@"multi_share_part_no_success", nil);;
        NSString * fail_msg=[NSString stringWithFormat:failed,networks];
        [self showAlertMessage:[NSString stringWithFormat:@"%@",fail_msg]];
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_ACTION_FAILURE withParameters:
//         @{EVENT_PARAM_SHARE_DESTINATION:(networks!=nil)?networks:@"unknown"}];

    }
}

         
@end
