//
//  GridOptionsViewController.m
//  Homestyler
//
//  Created by Dan Baharir on 11/19/14.
//
//

#import "GridOptionsViewController.h"
#import "UserSettingsPreferences.h"

#define CELL_SEPARATOR_HEIGHT 1

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface GridOptionsViewController ()

@end

///////////////////////////////////////////////////////
//                  Implementation                   //
///////////////////////////////////////////////////////

@implementation GridOptionsViewController



////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateNormal];
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateHighlighted];
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateSelected];
    [self.snapToGridButton setTitle:NSLocalizedString(@"snapToGrid_button", @"") forState:UIControlStateNormal];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

////////////////////////////////////////////////////////

-(void)setGridOptionSelected
{
    // check if snap to grid option is on
    if ([UserSettingsPreferences isParamEnabledWithKey:kUserPreferenceGridOptionsSnapToGrid] == NO)
        [self.snapToGridSwitch setOn:NO];
    else
        [self.snapToGridSwitch setOn:YES];
}

////////////////////////////////////////////////////////

- (IBAction)realScalePressed:(id)sender
{
    [self.delegate chooseGridOption:GRID_OPTION_REAL_SCALE];
}

////////////////////////////////////////////////////////

- (IBAction)returnPressed:(id)sender
{
    [self.delegate chooseGridOption:GRID_OPTION_NONE];
}

////////////////////////////////////////////////////////

- (IBAction)snapToGridSwitchPressed:(id)sender
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([self.snapToGridSwitch isOn])
    {
        [UserSettingsPreferences setEnabledToParamWithKey:YES andKey:kUserPreferenceGridOptionsSnapToGrid];
    }
    else
    {
        [UserSettingsPreferences setEnabledToParamWithKey:NO andKey:kUserPreferenceGridOptionsSnapToGrid];
    }
    
    [standardUserDefaults synchronize];
    
    [self.delegate chooseGridOption:GRID_OPTION_SNAP_TO_GRID];
}

////////////////////////////////////////////////////////

/*
 set the active grid options views according to user options
 */
-(void)setSnapToGridActive:(BOOL)snapToGridActive
{
    [self.optionsContainerView setUserInteractionEnabled:snapToGridActive];
    
    [self setGridOptionSelected];
    [self.view bringSubviewToFront:self.optionsContainerView];
}

////////////////////////////////////////////////////////


@end
