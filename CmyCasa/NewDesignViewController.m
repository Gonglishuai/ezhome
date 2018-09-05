//
//  NewDesignViewController.m
//  CmyCasa
//
//  Created by Gil Hadas on 24/01/13.
//
//

#import "NewDesignViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface NewDesignViewController ()

@property (weak, nonatomic) IBOutlet UIView *buttonsPanel;
@property (weak, nonatomic) IBOutlet UIButton *ARButton;
@property (weak, nonatomic) IBOutlet UILabel *ARLabel;

@end

@implementation NewDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self isARAvailable]) {
        self.ARButton.hidden = YES;
        self.ARLabel.hidden = YES;
        
        [UIView setAnimationsEnabled:NO];
        self.buttonsPanel.center  =  [self.view center];
        [UIView setAnimationsEnabled:YES];
    }
}

- (IBAction)cameraPressed:(id)sender
{
      [super cameraPressed:sender];
}

- (void)helpViewClosedNotification:(NSNotification*)notification {
    
    if ([notification object]!=nil && [[notification object] isKindOfClass:[NSString class]]) {
        NSString * passKey=(NSString*)[notification object];
        
        if ([passKey isEqualToString:@"help_camera"]) {
            [[UIManager sharedInstance] cameraPressed];
        }
    }
}

- (IBAction)devicePressed:(id)sender {
    [super devicePressed:sender];
    [[UIManager sharedInstance] deviceGalleryPressed:self.parentViewController];
    [[UIMenuManager sharedInstance] removeNewDesignViewController];
}

- (IBAction)closeOverlay:(id)sender {
    [[UIMenuManager sharedInstance] removeNewDesignViewController];
}

- (IBAction)openNewDesignHelp:(id)sender {
    [[HelpManager sharedInstance] presentHelpViewController:@"new_design_help" withController:self isForceToShow:YES];
}

- (IBAction)openEmptyRoomsArticles:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        [super openEmptyRoomsArticles:sender];

        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamTypeEmptyRooms andRoomType:@"" andSortBy:@"1"];
        [[UIMenuManager sharedInstance] removeNewDesignViewController];
    }
}

- (IBAction)openSampleRoomsArticles:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        [super openSampleRoomsArticles:sender];
        
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D andRoomType:@"" andSortBy:DesignSortTypeFor3D];
        [[UIMenuManager sharedInstance] removeNewDesignViewController];
    }
}

- (IBAction)dismiss:(id)sender
{
    [[UIMenuManager sharedInstance] removeNewDesignViewController];
}
@end
