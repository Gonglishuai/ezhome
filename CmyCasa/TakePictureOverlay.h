//
//  TakePicutreOverlay.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CMMotionManager.h>
#import "SavedGyroData.h"
#define IMAGE_MAX_SIZE (1024)

//GAITrackedViewController
@interface TakePictureOverlay : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{

	UIBarButtonItem* cancelButton;
    BOOL bHideTakePictureHelp;
}

@property (weak, nonatomic) IBOutlet UIButton *takePictureBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeOverlayButton;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIView *warningView;

@property (nonatomic) UIImagePickerController *imagePickerController;



// IB methods
- (IBAction)cancel:(id)sender;
- (IBAction)takePhoto:(id)sender;
@end
