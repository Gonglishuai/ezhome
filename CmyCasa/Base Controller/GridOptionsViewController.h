//
//  GridOptionsViewController.h
//  Homestyler
//
//  Created by Dan Baharir on 11/19/14.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    GRID_OPTION_NONE = 0,
    GRID_OPTION_REAL_SCALE,
    GRID_OPTION_SNAP_TO_GRID
} GridOptions;

///////////////////////////////////////////////////////
//                  PROTOCOL                         //
///////////////////////////////////////////////////////
/** Define the protocol for returning the user's choice to **/
/** the caller                                             **/
@protocol GridOptionsDelegate <NSObject>
@required
- (void)chooseGridOption:(GridOptions)gridOptionPicked;
@end


///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface GridOptionsViewController : UIViewController

///////////////////// Properties //////////////////////
@property (weak, nonatomic) id delegate;

///////////////////// Outlets /////////////////////////
@property (strong, nonatomic) IBOutlet UIButton *returnButton;
@property (strong, nonatomic) IBOutlet UIButton *realScaleButton;
@property (strong, nonatomic) IBOutlet UIButton *snapToGridButton;
@property (strong, nonatomic) IBOutlet UIView *styleRoomView;
@property (strong, nonatomic) IBOutlet UIView *optionsContainerView;
@property (strong, nonatomic) IBOutlet UISwitch *snapToGridSwitch;
@property (strong, nonatomic) IBOutlet UIView *realScaleCellView;
@property (strong, nonatomic) IBOutlet UIView *snapToGridCellView;


///////////////////// IBActions /////////////////////////
- (IBAction)realScalePressed:(id)sender;
- (IBAction)returnPressed:(id)sender;
- (IBAction)snapToGridSwitchPressed:(id)sender;

///////////////////// Methods /////////////////////////

/*
    will set what active grid options will be available to the user (according to userDefaultStandard values) 
    and sets the values for the user defaults
 */
-(void)setSnapToGridActive:(BOOL)snapToGridActive;


@end
