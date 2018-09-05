//
//  iphoneProfileViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "iphoneProfileViewController.h"
#import "iphoneUserLoginViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Exif.h"
#import "UserManager.h"

@interface iphoneProfileViewController ()


@property(nonatomic)UINavigationController * _userLoginNavigation;
@property(nonatomic)iphoneUserLoginViewController * _userLoginViewController;
@end

@implementation iphoneProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)closeProfileUI:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)changePassword:(id)sender {
   
    
}
- (IBAction)changeProfileImage:(id)sender {
    [super changeProfileImage:sender];
       //TODO: SERGEY
    /*[self startMediaBrowserFromViewController: self usingDelegate: self];
    [self startMediaBrowserFromViewController:self usingDelegate:self forView:self.view ];
    */
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [[[UIMenuManager sharedInstance] iphonePanelController]setIsLandscakeOK:PANEL_ROTATION_FLAG_NO];
    
    [[[UIMenuManager sharedInstance] iphonePanelController]setIsMenuOpenAllowed:NO];

    if (![[UserManager sharedInstance] isLoggedIn]) {
      //  [self.view setHidden:YES];
        
        
    }else{
        
     //   [self.view setHidden:NO];
        
        
        self.userFirstName.text=[[[UserManager sharedInstance] currentUser]firstName];
        self.userLastName.text=[[[UserManager sharedInstance] currentUser]lastName];
        
        [self loadProfileImage:[[[UserManager sharedInstance] currentUser]userProfileImage]];
        
    }
   /* if (!CGAffineTransformIsIdentity(self.parentViewController.view.transform)) {
        CGPoint p = self.parentViewController.view.center;
        self.view.center = CGPointMake(p.y, p.x);
    } else {
        self.view.center = self.parentViewController.view.center;
    }
    */
    
    if ([[UserManager sharedInstance] isLoggedIn] && [FBSession.activeSession isOpen]) {
        //disable editing
        [self.changeImageButton setEnabled:NO];
        [self.changePasswordButtn setEnabled:NO];
        [self.changeProfileNameButton setEnabled:NO];
        
        [self.changeImageButton setHidden:YES];
        [self.changePasswordButtn setHidden:YES];
        [self.changeProfileNameButton setHidden:YES];
        
        
    }else if([[UserManager sharedInstance] isLoggedIn]){
        
        [self.changeImageButton setEnabled:YES];
        [self.changePasswordButtn setEnabled:YES];
        [self.changeProfileNameButton setEnabled:YES];
        
        
        [self.changeImageButton setHidden:NO];
        [self.changePasswordButtn setHidden:NO];
        [self.changeProfileNameButton setHidden:NO];
    }
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
     [[[UIMenuManager sharedInstance] iphonePanelController]unsetIsLandscapeOK:PANEL_ROTATION_FLAG_NO];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChangeProfileNameButton:nil];
    [super viewDidUnload];
}

- (IBAction)saveChangesAction:(id)sender {

    
    
}


- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate:
(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate forView:(UIView*)mview{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.height;
    CGFloat screenHeight = screenRect.size.width;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.allowsEditing = NO;
    mediaUI.modalPresentationStyle = UIModalPresentationFullScreen;
    mediaUI.delegate = delegate;
  
    [controller presentModalViewController:mediaUI animated:YES];
    return YES;
}






- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Handle a still image picked from a photo album
    UIImage *Galleryimage;
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        Galleryimage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
        NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
        if (!metadata) {
            metadata = [UIImage imageMetadataWithAssetURL:[info objectForKey:UIImagePickerControllerReferenceURL]];
        }
	    
    
    
    
    
        [picker dismissModalViewControllerAnimated: YES];


if(Galleryimage==nil){
    
    return;
}
#ifdef USE_FLURRY
    if([(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"SendFlurryInfo"] boolValue]){
        
            [HSFlurry logEvent: FLURRY_CHANGE_PROFILE_IMAGE];
        
    }
#endif

[self.profileImage setImage:Galleryimage];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        NSString * profileImage=[[[UserManager sharedInstance] currentUser]userProfileImage];
        //clear local file before update
        if (profileImage) {
            NSString * filename=[profileImage lastPathComponent];
            NSString* imagePath =[NSString stringWithFormat:@"%@/profileView%@",[[ConfigManager sharedInstance] getStreamsPath]
                                  ,filename];
            
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            imagePath =[NSString stringWithFormat:@"%@/menuView%@",[[ConfigManager sharedInstance] getStreamsPath]
                        ,filename];
            
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            
            imagePath =[NSString stringWithFormat:@"%@/comment_%@",[[ConfigManager sharedInstance] getStreamsPath]
                        ,filename];
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            
            
            imagePath =[NSString stringWithFormat:@"%@/commentrep_%@",[[ConfigManager sharedInstance] getStreamsPath]
                        ,filename];
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            
            
            //comment_%@",[thumburl lastPathComponent]
            // NSString* imagePath = [[ConfigManager sharedInstance]getStreamFilePath:[NSString stringWithFormat:@"commentrep_%s"
            // ,_comment.getCommentID().c_str()]];
            
            
        }
        NSString * error=nil;
        if(![[LoginHandler sharedInstance] uploadNewPhoto:self.profileImage.image]){
            
            error=NSLocalizedString(@"err_msg_upload_profile_image",@"Failed to upload profile image");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (error!=nil)
            {
                UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"" message:error
                                                              delegate:nil
                                     
                                                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
                
             
                [alert show];
            }else{
                 [self loadProfileImage:[[[UserManager sharedInstance] currentUser]userProfileImage]];
                UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"update_profile_image_success", @"Profile photo updated successfully")
                                                              delegate:nil
                                     
                                                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
                
                [alert show];
            }
                
                      
        });
    });
    
    
    

}

}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIInterfaceOrientationIsPortrait(orientation) || (orientation == UIDeviceOrientationUnknown);
}
- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
