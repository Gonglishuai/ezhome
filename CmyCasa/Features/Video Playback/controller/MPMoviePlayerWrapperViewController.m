//
//  MPMoviePlayerWrapperViewController.m
//  Homestyler
//
//  Created by Maayan Zalevas on 6/8/14.
//
//

#import "MPMoviePlayerWrapperViewController.h"

@implementation MPMoviePlayerWrapperViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
