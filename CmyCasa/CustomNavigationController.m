//
//  CustomNavigationController.m
//  CmyCasa
//
//  Created by Gil Hadas on 10/17/12.
//
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}

@end
