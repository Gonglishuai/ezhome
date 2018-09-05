//
//  IphoneNewDesignMainViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "NewDesignMainViewController_iPhone.h"
#import "UIViewController+Helpers.h"

@interface NewDesignMainViewController_iPhone ()

@property (weak, nonatomic) IBOutlet UIView *buttonsPanel;
@property (weak, nonatomic) IBOutlet UIView *buttonsPanelForAR;

@property (weak, nonatomic) IBOutlet UIButton *ARButton;
@property (weak, nonatomic) IBOutlet UILabel *ARLabel;

@end

@implementation NewDesignMainViewController_iPhone

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self isARAvailable]) {
        self.ARButton.hidden = YES;
        self.ARLabel.hidden = YES;
        
        [UIView setAnimationsEnabled:NO];
        self.buttonsPanel.center  =  [self.view center];
        [UIView setAnimationsEnabled:YES];
    }
    
    BOOL hide = ARConfiguration.isSupported;
    self.buttonsPanelForAR.hidden = !hide;
    self.buttonsPanel.hidden = hide;
}

- (IBAction)cameraPressed:(id)sender{
    [super cameraPressed:sender];
}

- (void)helpViewClosedNotification:(NSNotification*)notification {
    
    HSMDebugLog(@"%@",[notification userInfo]);
    if ([notification object]!=nil && [[notification object] isKindOfClass:[NSString class]]) {
        NSString * passKey=(NSString*)[notification object];
        
        if ([passKey isEqualToString:@"help_camera"]) {
            [[UIManager sharedInstance] cameraPressed];
        }
    }
}

- (IBAction)devicePressed:(id)sender {
    
    if (![self isConnectionAvailable]) {
        return;
    }

    [super devicePressed:sender];
    [[UIManager sharedInstance] deviceGalleryPressed:self];
}

- (IBAction)openEmptyRoomsArticles:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        if (![self isConnectionAvailable]) {
            return;
        }
        
        [super openEmptyRoomsArticles:sender];
        
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamTypeEmptyRooms andRoomType:@"" andSortBy:@"1"];
        [[UIMenuManager sharedInstance] removeNewDesignViewControllerIPhone];
    }
}

- (IBAction)openSampleRoomsArticles:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        if (![self isConnectionAvailable]) {
            return;
        }
        
        [super openSampleRoomsArticles:sender];
        
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D andRoomType:@"" andSortBy:DesignSortTypeFor3D];
        [[UIMenuManager sharedInstance] removeNewDesignViewControllerIPhone]; 
    }
}


- (IBAction)navBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


@end
