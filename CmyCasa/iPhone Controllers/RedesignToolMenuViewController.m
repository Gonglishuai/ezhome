//
//  RedesignToolMenuViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import "RedesignToolMenuViewController.h"
#import "MainViewController.h"
#import "UIImage+fixOrientation.h"

#define MENU_HIGHT 45

@interface RedesignToolMenuViewController ()
{
    CGFloat toolBarWidth;
}
- (void)saveImageToLocalGallery;

@property(nonatomic)BOOL isOpen;
@property(nonatomic)BOOL inMiddleAnimation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBtnWidth;

@end

@implementation RedesignToolMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMenuButton)
                                                 name:@"ShowMainMenuButtonNotification"
                                               object:nil];
    
    //initially menu closed
    self.inMiddleAnimation = NO;
    self.isOpen = NO;
    self.internalControlsView.alpha = 0;
    self.view.frame = CGRectMake(0, 0, [ConfigManager deviceTypeisIPhoneX] ? 98 : 55, MENU_HIGHT);
    self.toolBtnWidth.constant = [ConfigManager deviceTypeisIPhoneX] ? 98 : 55;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - RedesignToolMenuViewController");
}
#pragma mark- Share

-(void)showMenuButton{
    [self.view setHidden:NO];
}

-(void)hideMenuButton{
    //In order to hide the menu button, the whole view should be hidden or else the view's background color will be displayed
    [self.view setHidden:NO];
}

- (IBAction)imageOptionsPressed:(id)sender {
    if ([self.mainVc respondsToSelector:@selector(imageOptionsDialogViewPressed:)]) {
        [self.mainVc imageOptionsDialogViewPressed:sender];
    }
    [self toggleDesignMenu:nil];
}

#pragma mark- Menu actions delegates
- (void)menuPressed:(id)sender{
    
}

- (IBAction)backPressed:(id)sender{
    if (self.mainVc) {
        [self.mainVc backPressed:sender];
    }
}

- (IBAction)sharePressed:(id)sender{

    if (self.mainVc) {
        [self.mainVc sharePressed:sender];
    }
}

- (IBAction)paintPressed:(id)sender{
    if (self.mainVc) {
        [self.mainVc iphonePaintPressed:sender];
    }
    [self toggleDesignMenu:nil];
}

- (IBAction)deletePressed:(id)sender{
    if (self.mainVc) {
        [self.mainVc deletePressed:sender];
    }
    [self toggleDesignMenu:nil];
}

- (IBAction)savePressed:(id)sender{
    if (self.mainVc) {
        [self.mainVc savePressed:sender];
    }
    [self toggleDesignMenu:nil];
}

- (IBAction)scalePressed:(id)sender{
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_UNLOCK_REAL_SCALE_DIALOG withParameters:@{EVENT_PARAM_UNLOCK_TRIGGER:EVENT_PARAM_VAL_REAL_SCALE_BUTTON}];
    if (self.mainVc) {
        [self.mainVc scalePressed:sender];
    }
    [self toggleDesignMenu:nil];
}

-(void)forceClosingMenu{
    if (self.isOpen) {
        [self closeMenuInternal];
    }
}

- (void)closeMenuInternal
{
    self.inMiddleAnimation=YES;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [UIView animateWithDuration:0.2 animations:^{
            self.internalControlsView.alpha = 0;
            self.mainVc.iphoneMenuVC.view.frame = self.toolMainMenuButtonView.frame;
        } completion:^(BOOL finished) {
            self.inMiddleAnimation = NO;
            self.isOpen = NO;
        }];
    });
}

- (void)openMenuInternal
{
    self.inMiddleAnimation=YES;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [UIView animateWithDuration:0.2 animations:^{
            self.internalControlsView.alpha = 1;
            self.mainVc.iphoneMenuVC.view.frame = CGRectMake(0, 0, self.mainVc.view.frame.size.width, MENU_HIGHT);
        } completion:^(BOOL finished) {
            self.inMiddleAnimation = NO;
            self.isOpen = YES;
        }];
    });
}

- (IBAction)toggleDesignMenu:(id)sender {

    if (self.inMiddleAnimation) {
        return;
    }
    
    if (self.isOpen) {
        [self closeMenuInternal];
        
    }else{//open
        [self openMenuInternal];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    if(result	!=	MFMailComposeResultCancelled)
    {
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
            NSString * share_owner=@"";
            share_owner = @"redesign tool";
            
//            [HSFlurry logEvent:FLURRY_DESIGN_SHARE_EMAIL_SEND withParameters:[NSDictionary dictionaryWithObject:share_owner forKey:@"shared_from"]];
        }
#endif
    }
}

- (void)saveImageToLocalGallery {
    
    UIImage* uploadImage = [[self.mainVc getScreenShot] scaleToFitLargestSide:1280.0];
    uploadImage = [uploadImage normalizedImage];
    
    UIImageWriteToSavedPhotosAlbum(uploadImage,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL);
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    
    if (error) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"save_image_failed_msg", @"Image save failed.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        
        [alert show];
    }else{
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"save_image_success_msg", @"Image successfully saved.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        
        [alert show];
    }
}

@end
