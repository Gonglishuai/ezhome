//
//  TakePicutreOverlay.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "TakePictureOverlay.h"
#import "UIImage+fixOrientation.h"
#import "ProtocolsDef.h"
#import "UIImage+Scale.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>

@implementation TakePictureOverlay

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_CAMERA_SCREEN;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceOrientationDidChangeNotification:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    self.warningLabel.text = NSLocalizedString(@"photo_not_in_landscape", @"");

    //take a picture button
    self.takePictureBtn.layer.cornerRadius = MIN(self.takePictureBtn.frame.size.width, self.takePictureBtn.frame.size.height) / 2;
    self.takePictureBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    self.takePictureBtn.layer.borderWidth = 0.0;
    self.takePictureBtn.clipsToBounds = YES;
   
    [self openCamera];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - TakePictureOverlay");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(void)openCamera{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if(UIInterfaceOrientationIsPortrait((UIInterfaceOrientation)orientation)){
        [self.takePictureBtn setTransform:CGAffineTransformIdentity];
        [self.warningView setHidden:NO];
        [self.warningLabel setHidden:NO];
        [self.takePictureBtn setEnabled:NO];
    }else{
        if (!IS_IPAD) {
            [self.takePictureBtn setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
        }
        [self.warningView setHidden:YES];
        [self.warningLabel setHidden:YES];
        [self.takePictureBtn setEnabled:YES];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.showsCameraControls = NO;
    imagePickerController.delegate = self;
    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePickerController.cameraOverlayView = self.view;
    
    if (!IS_IPAD) {
        CGSize screenBounds = [UIScreen mainScreen].bounds.size;
        CGFloat cameraAspectRatio = 4.0f/3.0f;
        CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
        CGFloat scale = screenBounds.height / camViewHeight;
        imagePickerController.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
        imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, scale, scale);
    }
    
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:self.imagePickerController animated:NO completion:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////
//                          mark UI                                                    //
/////////////////////////////////////////////////////////////////////////////////////////

#pragma mark UI
- (IBAction)cancel:(id)sender {
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (IBAction)takePhoto:(id)sender {
    [self.closeOverlayButton setEnabled:NO];
	[self.imagePickerController takePicture];
}

/////////////////////////////////////////////////////////////////////////////////////////
//                          UIImagePicker Delegate                                     //
/////////////////////////////////////////////////////////////////////////////////////////


#pragma mark UIImagePicker Delegate
// this get called when an image has been chosen from the library or taken from the camera
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
  
    UIImageOrientation o = image.imageOrientation;
    UIImage *fixedImage = nil;

    if (IS_IPAD) {
        fixedImage = [image scaleImageTo1024];
    }else{
        fixedImage = [image scaleToFitLargestSide2:IMAGE_MAX_SIZE];
    }
    
    if (image.imageOrientation == UIImageOrientationDown) {
        fixedImage = [fixedImage normalizedImage];
    }
    
    o = UIImageOrientationUp;

    if (fixedImage.size.width > fixedImage.size.height) //in case this is a landscape image
    {
        fixedImage = [UIImage imageWithCGImage:fixedImage.CGImage scale:1.0f orientation:UIImageOrientationUp];
    }
    
    [self.closeOverlayButton setEnabled:YES];

    [self dismissViewControllerAnimated:YES completion:^{

        [self.navigationController popViewControllerAnimated:NO];
        
        if (fixedImage !=nil && o != UIImageOrientationUp &&
            o != UIImageOrientationDown &&
            ![ConfigManager isPortraitModeActive])
        {
            UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                           message:NSLocalizedString(@"photo_not_in_landscape", @"")
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles: nil];
            [alert show];
            return;
        }
        
        SavedDesign * ndesign = [SavedDesign initWithImage:fixedImage imageMetadata:metadata devicePosition:nil originalOrientation:o];
        ndesign.originalSourceType = UIImagePickerControllerSourceTypeCamera;
        ndesign.isPortrait = (fixedImage.size.height > fixedImage.size.width) ? YES : NO;
        
        [[DesignsManager sharedInstance] setWorkingDesign:ndesign];
        
        [[UIManager sharedInstance] showRetakePhotoScreen];
    }];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification*)note
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case  UIDeviceOrientationUnknown:
            [self.warningView setHidden:NO];
            [self.warningLabel setHidden:NO];
            [self.takePictureBtn setTransform:CGAffineTransformIdentity];
            [self.takePictureBtn setEnabled:NO];
            break;
            
        case UIDeviceOrientationPortrait:
            [self.warningView setHidden:NO];
            [self.warningLabel setHidden:NO];
            [self.takePictureBtn setTransform:CGAffineTransformIdentity];
            [self.takePictureBtn setEnabled:NO];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            [self.warningView setHidden:NO];
            [self.warningLabel setHidden:NO];
            [self.takePictureBtn setTransform:CGAffineTransformIdentity];
            [self.takePictureBtn setEnabled:NO];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [self.warningView setHidden:YES];
            [self.warningLabel setHidden:YES];
            if (!IS_IPAD) {
                [self.takePictureBtn setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
            }
            [self.takePictureBtn setEnabled:YES];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self.warningView setHidden:YES];
            [self.warningLabel setHidden:YES];
            if (!IS_IPAD) {
                [self.takePictureBtn setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
            }
            [self.takePictureBtn setEnabled:YES];
            break;
            
        case UIDeviceOrientationFaceUp:
            [self.warningView setHidden:NO];
            [self.warningLabel setHidden:NO];
            [self.takePictureBtn setTransform:CGAffineTransformIdentity];
            [self.takePictureBtn setEnabled:NO];
            break;
            
        case UIDeviceOrientationFaceDown:
            [self.warningView setHidden:NO];
            [self.warningLabel setHidden:NO];
            [self.takePictureBtn setTransform:CGAffineTransformIdentity];

            break;
            
        default:
            break;
    }
}

@end
