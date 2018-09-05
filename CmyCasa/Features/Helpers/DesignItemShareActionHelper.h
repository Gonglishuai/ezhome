//
//  DesignItemShareActionHelper.h
//  Homestyler
//
//  Created by Dong Shuyu on 04/10/18.
//
//

#import "HSSharingViewController.h"

@interface DesignItemShareActionHelper : NSObject

- (void)shareDesign:(nonnull DesignBaseClass *)design withDesignImage:(nonnull UIImage *)designImage fromViewController:(nonnull UIViewController *)hostViewController withDelegate:(id <HSSharingViewControllerDelegate>)sharingDelegate loadOrigin:(NSString *)loadOrigin;

@end
