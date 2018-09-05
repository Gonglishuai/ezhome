//
//  GridOptionsDialogView.m
//  Homestyler
//
//  Created by Dan Baharir on 11/20/14.
//
//

#import "GridOptionsDialogView.h"

#define CELL_SEPARATOR_HEIGHT 1

typedef enum {
    GRID_OPTION_NONE = 0,
    GRID_OPTION_REAL_SCALE,
    GRID_OPTION_SHOW_GRID,
    GRID_OPTION_SNAP_TO_GRID
} GridOptions;

////////////////////////////////////////////////////////////

@implementation GridOptionsDialogView
{
    BOOL isShowGridOptionActive;
    BOOL isSnapToGridOptionActive;
}

////////////////////////////////////////////////////////////

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateNormal];
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateHighlighted];
    [self.realScaleButton setTitle:NSLocalizedString(@"realScale_button", @"") forState:UIControlStateSelected];
    [self.snapToGridButton setTitle:NSLocalizedString(@"snapToGrid_button", @"") forState:UIControlStateNormal];
}

////////////////////////////////////////////////////////////

- (IBAction)realScalePressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(realScaleClicked)])
        [self.delegate performSelector:@selector(realScaleClicked)];
}

////////////////////////////////////////////////////////////

- (IBAction)returnPressed:(id)sender
{
    if([self.delegate respondsToSelector:@selector(closeGridOptionsDialogView)])
        [self.delegate performSelector:@selector(closeGridOptionsDialogView)];
}

////////////////////////////////////////////////////////////

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
  hide/show available grid options in menu
 */
-(void)setSnapToGridActive:(BOOL)snapToGridActive
{
    [self.snapToGridCellView setUserInteractionEnabled:snapToGridActive];
    
    [self setGridOptionSelected];
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



@end