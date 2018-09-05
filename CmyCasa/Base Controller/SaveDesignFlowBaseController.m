//
//  SaveDesignFlowBaseController.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/13/13.
//
//

#import "SaveDesignFlowBaseController.h"
#import "HSSharingLogic.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"
#import "ServerUtils.h"


@interface SaveDesignFlowBaseController ()

@end

@implementation SaveDesignFlowBaseController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /*
     * Warning: The code below adds the view controller and removes it just to call the viewDidLoad.
     * TODO (Avihay): Refactor so the work will not be done on viewDidLoad
     */
    
    // Do any additional setup after loading the view.
    self.imageEffectsDialog=(ImageEffectsBaseViewController*)[[UIManager sharedInstance] createImageEffectsViewController];
    self.imageEffectsDialog.delegate=self;
    
    [self.view addSubview:self.imageEffectsDialog.view];
    [self addChildViewController:self.imageEffectsDialog];
    [self.imageEffectsDialog removeFromParentViewController];
    [self.imageEffectsDialog.view removeFromSuperview];
    
    self.saveDesignDialog= [ControllersFactory instantiateViewControllerWithIdentifier:@"iPadSavedDesignPopup" inStoryboard:kRedesignStoryboard];
    self.saveDesignDialog.designDelegate=self;
    
    [self.view addSubview:self.saveDesignDialog.view];
    [self addChildViewController:self.saveDesignDialog];
    [self.saveDesignDialog removeFromParentViewController];
    [self.saveDesignDialog.view removeFromSuperview];
    
    
    self.shareDialog = [ControllersFactory instantiateViewControllerWithIdentifier:@"ImageEffectShareViewController" inStoryboard:kRedesignStoryboard];
    self.shareDialog.saveDesignFlowDelegate = self;
    self.shareDialog.delegate = self;
    
    [self.view addSubview:self.shareDialog.view];
    [self addChildViewController:self.shareDialog];
    [self.shareDialog removeFromParentViewController];
    [self.shareDialog.view removeFromSuperview];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!IS_IPAD) {        
        CGFloat screenW = ([UIScreen currentScreenBoundsDependOnOrientation].size.width > [UIScreen currentScreenBoundsDependOnOrientation].size.height) ? [UIScreen currentScreenBoundsDependOnOrientation].size.width : [UIScreen currentScreenBoundsDependOnOrientation].size.height;
        CGFloat screenH = ([UIScreen currentScreenBoundsDependOnOrientation].size.width < [UIScreen currentScreenBoundsDependOnOrientation].size.height) ?[UIScreen currentScreenBoundsDependOnOrientation].size.width : [UIScreen currentScreenBoundsDependOnOrientation].size.height;
        
        self.view.frame = CGRectMake(0, 0, screenW, screenH);
        
        self.imageEffectsDialog.view.frame = self.view.frame;
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)moveToDialogAtIndex:(NSInteger)dialogIndex{
    
    switch (dialogIndex) {
        case SaveDesignSaveKey:
        {//save design dialog
            [self.imageEffectsDialog removeFromParentViewController];
            [self.imageEffectsDialog.view removeFromSuperview];
            [self.shareDialog removeFromParentViewController];
            [self.shareDialog.view removeFromSuperview];
            [self.view addSubview:self.saveDesignDialog.view];
            [self addChildViewController:self.saveDesignDialog];
        }
            break;
        case SaveDesignImageEffectsKey:
        {//save design dialog
            [self.saveDesignDialog removeFromParentViewController];
            [self.saveDesignDialog.view removeFromSuperview];
            [self.shareDialog removeFromParentViewController];
            [self.shareDialog.view removeFromSuperview];
            [self.view addSubview:self.imageEffectsDialog.view];
            [self addChildViewController:self.imageEffectsDialog];
        }
            break;
            
        case SaveDesignShareKey:
        {//save design dialog
            [self.saveDesignDialog removeFromParentViewController];
            [self.saveDesignDialog.view removeFromSuperview];
            [self.imageEffectsDialog removeFromParentViewController];
            [self.imageEffectsDialog.view removeFromSuperview];
            [self.view addSubview:self.shareDialog.view];
            [self addChildViewController:self.shareDialog];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openSaveDialog{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self moveToDialogAtIndex:SaveDesignSaveKey];
    });
}

-(void)openShareDialog:(ShareScreenMode)mode
{
    if ([[DesignsManager sharedInstance] workingDesign].dirty == NO) {
        SavedDesign * saveddesign = [[DesignsManager sharedInstance] workingDesign];
        UIImage* img = ([saveddesign ImageWithFurnitures]!=nil)?[saveddesign ImageWithFurnitures]:[saveddesign originalImage];
        
        NSString* designOwner=@"";
        if (self.designDelegate && [self.designDelegate conformsToProtocol:@protocol(SaveDesignPopupDelegate)]) {
            designOwner=[self.designDelegate getDesignOwner];
        }
        
        if (img) {
            self.imageEffectsDialog.designerName = designOwner;
            self.imageEffectsDialog.originalImage = img;
            self.imageEffectsDialog.designBaseImage = saveddesign.originalImage;
            [self.imageEffectsDialog refreshPresentingImagesWithMode:mode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveToDialogAtIndex:SaveDesignImageEffectsKey];
            });
        }
    }
}

-(void)closeSaveFlow:(BOOL)animated{
    if (IS_IPAD) {
        [self.view setHidden:YES];
    }else{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    
    SavedDesign * saveddesign = [[DesignsManager sharedInstance] workingDesign];
    if (saveddesign) {
        saveddesign.ImageWithFurnitures=nil;
    }
}

#pragma mark- SaveDesignFlowBaseControllerDelegate
-(void)nextStepRequested:(UIImage*)finalImage{
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    NSString * fullurl = [self.designDelegate generateShareUrl];
    
    NSArray * htags = [[ConfigManager sharedInstance] shareHashTags];
    NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"share_after_save_design_copy", @""), [ConfigManager getAppName]];
    msg = [msg stringByReplacingOccurrencesOfString:@"{{D_NAME}}" withString:[self.designDelegate getDesignName]];
    
    msg=[msg stringByReplacingOccurrencesOfString:@"{{LINK}}" withString:fullurl];
    
    [[ServerUtils sharedInstance] uploadImage:finalImage andParmaters:nil andComplitionBlock:^(id serverResponse, id error) {
        
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        
        if (!error) {
            NSURL * url = [NSURL URLWithString:(NSString*)serverResponse];
            
            HSShareObject * shareObj = [HSSharingLogic generateShareObject:finalImage
                                                              andDesignUrl:fullurl
                                                                andMessage:[self.designDelegate getDesignName]
                                                              withHashTags:htags];
            
            shareObj.pictureURL = url;
            shareObj._description = @"";
            
            if ([ConfigManager isWhiteLabel]) {
                [self shareByEmail:shareObj];
            }else{
                [self.shareDialog initWithShareData:shareObj];
                [self.shareDialog selectPreferedButtons];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self moveToDialogAtIndex:SaveDesignShareKey];
                });
            }
        }
    }];
}

-(void)skipStepRequested{
    
    if (self.designDelegate) {
        
        if (IS_IPAD) {
            [self closeSaveFlow:YES];
            if ([self.designDelegate saveRequestedBeforeLeave]) {
                [self.designDelegate saveDesignPopupClosed];
            }
        }else{
            if ([self.designDelegate saveRequestedBeforeLeave]) {
                [self closeSaveFlow:NO];
                [self.designDelegate backPressedOnIphoneAfterSave];
            }else{
                [self closeSaveFlow:YES];
            }
        }
    }
}

-(void)prevStepRequested:(SaveDesignDialog)currentState{
    
    switch (currentState) {
        case SaveDesignShareKey:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveToDialogAtIndex:SaveDesignImageEffectsKey];
            });
        }
            break;
            
        default:
            break;
    }
}

#pragma mark- SaveDesignPopupDelegate

- (void)saveDesign:(NSString*)name{
    if (self.designDelegate) {
        [self.designDelegate saveDesign:name];
    }
}

- (void) homePressed{
    if (self.designDelegate) {
        [self.designDelegate homePressed];
    }
}

- (void)saveDesignPopupClosed
{
    if (self.designDelegate) {
        if ([self.designDelegate saveRequestedBeforeLeave] == NO) {
            [self.designDelegate saveDesignPopupClosed];
        }else{
            [[DesignsManager sharedInstance] workingDesign].dirty = NO;
        }
    }
    
    if ([[ReachabilityManager sharedInstance] isConnentionAvailable]) {
        [self openShareDialog:ShareScreenModeOpenFromOtherController];
    }else{
        // know issue design manger not support overide of save in the meantime we go out after save
            [self closeSaveFlow:YES];
    }
}

- (void)saveDesignPopupClosedOnCancel{
    if (self.designDelegate) {
        [self.designDelegate saveDesignPopupClosedOnCancel];
    }
    
    [self closeSaveFlow:YES];
}

- (UIImage*)getScreenShot{
    if (self.designDelegate) {
        return  [self.designDelegate getScreenShot];
    }
    
    return nil;
}

-(void)updateDesignTitle:(NSString *)title andDescription:(NSString *)desc andURL:(NSString *)url{
    
    if (self.designDelegate && [self.designDelegate conformsToProtocol:@protocol(SaveDesignPopupDelegate)]) {
        [self.designDelegate updateDesignTitle:title andDescription:desc andURL:url];
    }
}

#pragma mark - ShareDelegate
- (void)didCancelSharingViewController{
    [self performSelectorOnMainThread:@selector(closeSaveFlow:) withObject:@YES waitUntilDone:NO];
}

- (void)didFinishSharingViewController{
    [self performSelectorOnMainThread:@selector(closeSaveFlow:) withObject:@YES waitUntilDone:NO];
}

- (void)shareByEmail:(HSShareObject*)shareObj
{
    HSSharingLogic *logic = [[HSSharingLogic alloc] initWithText:shareObj];
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setSubject:[NSString stringWithFormat:NSLocalizedString(kHSSharingViewControllerMailSubject, nil), [ConfigManager getAppName]]];
        [composeViewController setMessageBody:[NSString stringWithFormat:@"%@", [logic getSharingTextForEmail]] isHTML:NO];
        [composeViewController addAttachmentData:UIImagePNGRepresentation(shareObj.picture) mimeType:@"image/png" fileName:[shareObj.pictureURL absoluteString]];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
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
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         if (isSharing)
         {
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Mail has been sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
         else
         {
             UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to send mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];
}

@end
