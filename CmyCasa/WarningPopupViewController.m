//
//  WarningPopupViewController.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "WarningPopupViewController.h"

@interface WarningPopupViewController ()

@end

@implementation WarningPopupViewController

-(void)dealloc{
    NSLog(@"dealloc - WarningPopupViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityLabel = @"Save Design?";
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)stayPressed:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    self.delegate = nil;
}

- (IBAction)leavePressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(leavePressed)]) {
        [[DesignsManager sharedInstance] disregardCurrentAutoSaveObject];
        [self.delegate leavePressed];
    }
}

- (IBAction)saveDesignOnExit:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(saveDesignOnExit)]) {
        [self.delegate saveDesignOnExit];
    }
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    self.delegate = nil;
}

@end
