//
//  ProgressPopupViewController.m
//  CmyCasa
//
//
//

#import "ProgressPopupViewController.h"
#import "ProtocolsDef.h"
#import "AppDelegate.h"

@interface ProgressPopupViewController ()

@end

@implementation ProgressPopupViewController


- (void) didRotate:(NSNotification *)notification
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIDeviceOrientation orientation = [appDelegate getSavedDesignOrientation];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        {
            [UIView animateWithDuration:0.2 animations:^{
                 self.mainView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
            }];
            break;
        }
            
        case UIDeviceOrientationLandscapeRight:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.mainView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
            }];
            break;
        }
            
        case UIDeviceOrientationPortrait:
        {
            [UIView animateWithDuration:0.2 animations:^{
                 self.mainView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
            }];
            break;
        }
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
            [UIView animateWithDuration:0.2 animations:^{
                 self.mainView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            }];
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}


@end
