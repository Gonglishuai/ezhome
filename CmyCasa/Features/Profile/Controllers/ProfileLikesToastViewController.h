//
//  ProfileLikesToastViewController.h
//  EZHome
//
//  Created by Eric Dong on 5/10/18.
//

#import <UIKit/UIKit.h>

@interface ProfileLikesToastViewController : UIViewController

@property (strong, nonatomic) UserProfile *userProfile;

- (void)presentByParentViewController:(UIViewController*)parentViewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;

@end
