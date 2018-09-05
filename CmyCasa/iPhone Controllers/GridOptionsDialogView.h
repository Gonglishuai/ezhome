//
//  GridOptionsDialogView.h
//  Homestyler
//
//  Created by Dan Baharir on 11/20/14.
//
//

#import <UIKit/UIKit.h>


///////////////////////////////////////////////////////
//                  PROTOCOL                        //
///////////////////////////////////////////////////////
@protocol GridOptionsDialogViewDelegate <NSObject>
- (void)closeGridOptionsDialogView;
- (void)realScaleClicked;
- (void)chooseGridOption:(int)gridOptionPicked;
@end

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface GridOptionsDialogView : UIView


///////////////////// Properties //////////////////////

@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *realScaleButton;
@property (weak, nonatomic) IBOutlet UIButton *snapToGridButton;
@property (weak, nonatomic) IBOutlet UIView *optionsContainerView;
@property (weak, nonatomic) IBOutlet UISwitch *snapToGridSwitch;
@property (nonatomic, weak) id<GridOptionsDialogViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *realScaleCellView;
@property (weak, nonatomic) IBOutlet UIView *snapToGridCellView;


///////////////////// IBActions /////////////////////////
- (IBAction)realScalePressed:(id)sender;
- (IBAction)returnPressed:(id)sender;
- (IBAction)snapToGridSwitchPressed:(id)sender;


////////////////////// Methods /////////////////////////

/*
 will set what active grid options will be available to the user (according to userDefaultStandard values)
 and sets the values for the user defaults
 */
-(void)setSnapToGridActive:(BOOL)snapToGridActive;


@end
