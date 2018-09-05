//
//  MeasureViewController.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "GeneralCubeViewController.h"

#import "SavedDesign.h"
#import "ProtocolsDef.h"

#define TAPE_VERTS (12)
#define CUBE_VERTS (8)
#define COORDS (3)
#define TEX_COORDS (2)
#define X (0)
#define Y (1)
#define Z (2)

@interface MeasureViewController : GeneralCubeViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate> {
	GLKVector3 tapeP1, tapeP2; // Points defining the edges of the tape
	GLKVector3 tapeNorm; // the norm to the tape plane
	GLfloat tapeVerts[TAPE_VERTS * COORDS];
	GLfloat tapeTexCoord[TAPE_VERTS * TEX_COORDS];
	GLKTextureInfo* tapeTex;
	BOOL editValueMode;
	float currentScale;
	WallSide currentWall;
}

@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UIView *iPadBottomBar;
@property (weak, nonatomic) IBOutlet UIButton* buttonTapeLeft;
@property (weak, nonatomic) IBOutlet UIButton* buttonTapeRight;
@property (weak, nonatomic) IBOutlet UIButton* buttonTapeCenter;
@property (weak, nonatomic) IBOutlet UIButton* buttonTapeValue;
@property (weak, nonatomic) IBOutlet UIPickerView* pickerView;
@property (weak, nonatomic) IBOutlet UIButton *iPadValueButton;
@property (weak, nonatomic) IBOutlet UIButton *fettButton;
@property (weak, nonatomic) IBOutlet UIButton *cmButton;
@property (weak, nonatomic) id <DoneNavigationDelegate> delegate;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)iPadValuePressed:(id)sender;
- (IBAction)changeMeasureType:(id)sender;
- (void)iPadUnitsChanged:(id)sender;
- (void)dragTapePoint:(UIPanGestureRecognizer*)gesture;
- (void)dragTape:(UIPanGestureRecognizer*)gesture;
- (void)updateTapeLabel;
- (void)setMeasuringTapeValue:(float)value animated:(BOOL)animated;







@end
