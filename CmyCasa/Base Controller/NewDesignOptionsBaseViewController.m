//
//  NewDesignOptionsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "NewDesignOptionsBaseViewController.h"
#import "ProtocolsDef.h"
#import <AVFoundation/AVFoundation.h>
#import "DataManager.h"
//#import "UMMobClick/MobClick.h"
#import <ARKit/ARKit.h>

@interface NewDesignOptionsBaseViewController ()

@end

@implementation NewDesignOptionsBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpViewClosedNotification:)
                                                 name:HelpViewClosedNotification object:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)helpViewClosedNotification:(NSNotification*)notification{
    //implement in sons
}

- (IBAction)openEmptyRoomsArticles:(id)sender{
    [self segmentNewDesign:@"empty room"];
    
#ifdef USE_UMENG
//    [MobClick event:@"empty_room"];
 #endif
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObject:@"empty rooms" forKey:@"new_design_type"]];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_EMPTY_ROOM}];
    }
#endif
}

- (IBAction)openSampleRoomsArticles:(id)sender{
    [self segmentNewDesign:@"sample room"];
    
#ifdef USE_UMENG
//    [MobClick event:@"sample_room"];
#endif
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObject:@"sample rooms" forKey:@"new_design_type"]];
    }
#endif
}

- (IBAction)closeOverlay:(id)sender{
    //implement in sons
}

- (IBAction)cameraPressed:(id)sender {
    
    [self segmentNewDesign:@"camera roll"];
    
#ifdef USE_UMENG
//    [MobClick event:@"camera_roll"];
#endif
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED) {
//        [ HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObject:@"camera" forKey:@"new_design_type"]];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_CAMERA}];
    }
#endif
    
    // check if user allowed permissions to camera
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusDenied || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"no_camera_allowed_error", @"")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                             otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear|UIImagePickerControllerCameraDeviceFront]==false)
        return;
    
    [[UIManager sharedInstance] cameraPressed];
}

- (IBAction)devicePressed:(id)sender {
    [self segmentNewDesign:@"new picture"];

#ifdef USE_UMENG
//    [MobClick event:@"new_picture"];
#endif
    
#ifdef USE_FLURRY
    
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObject:@"gallery" forKey:@"new_design_type"]];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_PHOTOS}];
    }
#endif
    
}

- (IBAction)openNewDesignHelp:(id)sender {

}

- (IBAction)ARPressed:(id)sender
{

#ifdef USE_UMENG
//    [MobClick event:@"ar"];
#endif
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED) {
//        [ HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObject:@"ar" forKey:@"new_design_type"]];
//        [HSFlurry logAnalyticEvent:EVENT_NAME_HOME_SCREEN withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_LABEL_AR}];
    }
#endif
    
    // check if user allowed permissions to camera
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusDenied || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"no_camera_allowed_error", @"")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                             otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [[UIManager sharedInstance] arPressed];
}

- (BOOL)isARAvailable {
    return ARConfiguration.isSupported;
}

#pragma mark - SEGEMENT
-(void)segmentNewDesign:(NSString*)type{
    if ([type isEqualToString:@"new picture"]) {
        [[DataManger sharedInstance] setDesignSource:@"new picture"];
//        [HSFlurry segmentTrack:@"new design" withParameters:@{@"design type": @"new picture"}];
    }
    
    if ([type isEqualToString:@"empty room"]) {
        [[DataManger sharedInstance] setDesignSource:@"empty room"];
//        [HSFlurry segmentTrack:@"new design" withParameters:@{@"design type": @"empty room"}];
    }

    if ([type isEqualToString:@"camera roll"]) {
        [[DataManger sharedInstance] setDesignSource:@"camera roll"];
//        [HSFlurry segmentTrack:@"new design" withParameters:@{@"design type": @"camera roll"}];
    }
    
    if ([type isEqualToString:@"sample room"]) {
        [[DataManger sharedInstance] setDesignSource:@"sample room"];
//        [HSFlurry segmentTrack:@"new design" withParameters:@{@"design type": @"sample room"}];
    }
}

@end

