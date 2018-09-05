//
//  CubeViewController.h
//  CmyCasa
//


#import <UIKit/UIKit.h>
#import "GeneralCubeViewController.h"
#import "SavedDesign.h"
#import "ProtocolsDef.h"
#import "ServerUtils.h"
#import "ProgressPopupViewController.h"
#import "MeasureViewController.h"

#define CUBE_DEPTH (80)
#define INITIAL_WIDTH (2)
#define INITIAL_HEIGHT (2)
#define INITIAL_FAR_Z (-7)
#define INITIAL_FLOOR (0)
#define kCubeWireframeRealWorldSize (0.5) // in meters
@interface CubeViewController : GeneralCubeViewController <DoneNavigationDelegate, UIGestureRecognizerDelegate>
{
    @private
	MeasureViewController* _measureViewController;
	BOOL measureViewOpen;
}
@property (strong, nonatomic) ProgressPopupViewController* errorPopup;
@property (strong, nonatomic) IBOutlet UIImageView* imageView;
// Done/Cancel
@property (weak, nonatomic) IBOutlet UIButton* cancelButton;
@property (weak, nonatomic) IBOutlet UIView *iPadBottomBar;
@property (weak, nonatomic) IBOutlet UIButton *rotateRightButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowBottomButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowUpButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowRightButton;
@property (weak, nonatomic) IBOutlet UIButton *arrowLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *dragRightWallButton;
@property (weak, nonatomic) IBOutlet UIButton *dragFrontWallButton;
@property (weak, nonatomic) IBOutlet UIButton *dragLeftWallButton;
@property (weak, nonatomic) IBOutlet UIButton *dragCeilingButton;
@property (weak, nonatomic) IBOutlet UIButton *dragFloorButton;
@property (weak, nonatomic) id <DoneNavigationDelegate> delegate;

- (void)donePressed:(id)sender;
- (void)setDefaultCube:(id)sender;
- (void)resetCube;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;
- (IBAction)resetCubeToDefault:(id)sender;
@end
