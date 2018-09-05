//
//  ProfileViewController_iPhone.m
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import "ProfileViewController_iPhone.h"
#import "ProgressPopupViewController.h"
#import "ControllersFactory.h"
#import "SettingsViewController_iPhone.h"

#define COLLECTIONVIEW_CELL_MARGIN      16

@interface ProfileViewController_iPhone ()
@end

@implementation ProfileViewController_iPhone


- (void)viewDidLoad {
    self.collectionViewCellMargin = COLLECTIONVIEW_CELL_MARGIN;
    self.backgroundImageAspect = 0.5333; // 8/15
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)openSettingsPressed:(id)sender{
    
    SettingsViewController_iPhone *settings = [ControllersFactory instantiateViewControllerWithIdentifier:@"SettingsViewController_iPhone" inStoryboard:kMainStoryBoard];
    
    [self.navigationController pushViewController:settings animated:YES];
}

@end
