//
//  ProfileViewController_iPad.m
//  EZHome
//
//  Created by Eric Dong on 27/3/18.
//

#import "ProfileViewController_iPad.h"
#import "ControllersFactory.h"
#import "SettingsViewController.h"

#define COLLECTIONVIEW_CELL_MARGIN      50

@interface ProfileViewController_iPad ()
@property (nonatomic, strong) SettingsViewController* settingsViewController;
@end

@implementation ProfileViewController_iPad


- (void)viewDidLoad {
    self.collectionViewCellMargin = COLLECTIONVIEW_CELL_MARGIN;
    self.backgroundImageAspect = 0.2148; // 220/1024
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -UICollectionView Delegate-

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        static const CGFloat aspect = 0.5625; // 9/16
//        CGFloat width = [UIScreen mainScreen].bounds.size.width;
//        CGFloat height = width * 0.5625 + (self.collectionLayout.itemSize.height - self.collectionLayout.itemSize.width * 0.5625);
//        return CGSizeMake(width, height);
//    }
//
//    CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * COLLECTIONCELL_MARGIN;
//    if (self.currentMode == BigMode) {
//        CGFloat height = 85 + width * 2 / 3;
//        return CGSizeMake(width, height);
//    } else {
//        CGFloat size = (width - self.collectionLayout.minimumInteritemSpacing) / 2;
//        return CGSizeMake(size, size);
//    }
//}

- (IBAction)openSettingsPressed:(id)sender
{
    if(_settingsViewController == nil)
    {
        _settingsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"settingsViewController" inStoryboard:kMainStoryBoard];
        _settingsViewController.vc = self;
    }else{

        if ([_settingsViewController parentViewController] == self) {
            [_settingsViewController.view removeFromSuperview];
            [_settingsViewController removeFromParentViewController];
        }else{
            if([[_settingsViewController view] superview]!=nil)
            {
                [_settingsViewController.view removeFromSuperview];
            }
        }
    }

    [self addChildViewController:_settingsViewController];
    //_settingsViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [self.view addSubview:_settingsViewController.view];

//    [UIView animateWithDuration:0.5
//                          delay:0.0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:0.3
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         _settingsViewController.view.transform = CGAffineTransformIdentity;
//                     } completion:^(BOOL finished) {
//                         [_settingsViewController startBgAnimation];//                     }];
    [_settingsViewController startBgAnimation];
}

@end
