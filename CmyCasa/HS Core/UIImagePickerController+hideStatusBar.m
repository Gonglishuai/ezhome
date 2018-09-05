//
//  UIImagePickerController+UIImagePickerController_hideStatusBar.m
//  Homestyler
//
//  Created by Berenson Sergei on 1/14/14.
//
//

#import "UIImagePickerController+hideStatusBar.h"

@implementation UIImagePickerController (hideStatusBar)

-(BOOL) prefersStatusBarHidden {
    return YES;
}

-(UIViewController *) childViewControllerForStatusBarHidden {
    return nil;
}
@end

