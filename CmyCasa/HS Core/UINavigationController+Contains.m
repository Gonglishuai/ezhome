//
//  UINavigationController+Contains.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/31/13.
//
//

#import "UINavigationController+Contains.h"

@implementation UINavigationController (Contains)



-(BOOL)containsController:(Class)controllerClass
{
    NSArray * presentedControllers = [self viewControllers];

    for (id object in presentedControllers) {
        if ([object isKindOfClass:controllerClass]) {
            return YES;
        }
    }
    return NO;
}
@end
