//
//  BaseSplashScreenViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import <HockeySDK/HockeySDK.h>
//GAITrackedViewController
@interface SplashScreenBaseViewController : UIViewController<HSSplashScreen, BITHockeyManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel * networkLabel;
-(void)start;
@end
