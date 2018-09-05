//
//  UIView+ReloadUI.m
//  Homestyler
//
//  Created by Avihay Assouline on 10/21/14.
//
//

#import "UIView+ReloadUI.h"
#import "UIView+NUI.h"

@implementation UIView (ReloadUI)

- (void)reloadUI
{
    [self reloadUIRecursive:self];
}

- (void)reloadUIRecursive:(UIView*)view
{
    // Read current status so all buttons will be set to the same value
    // as the network can switch state during the loop
    BOOL currentStatus = [ConfigManager isAnyNetworkAvailable];
    for (UIView *subview in [view subviews])
    {
        if ([[subview subviews] count] > 0)
            [self reloadUIRecursive:subview];
        
        subview.isCurrentlyDisplayed = currentStatus;
        [subview applyNUI];
    }
    
    [view setNeedsDisplay];
}

@end
