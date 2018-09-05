//
//  ConcealViewController.h
//  ClearSceneDemo
//
//  Created by Berenson Sergei on 3/2/14.
//  Copyright (c) 2014 SB Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UndoHandler.h"
#import "HSNUIIconLabelButton.h"

@protocol ConcealVCDelegate <NSObject>
- (void)concealDoneWithNewImage:(UIImage *)image;
@end

@class PatchesView;
@class RenderProperties;

@interface ConcealViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<ConcealVCDelegate> delegate;
@property (nonatomic, strong) UndoHandler * undoHandler;
@property (weak, nonatomic) IBOutlet UISlider *patchSizeScroller;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

#pragma mark - Undo/Redo
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;

#pragma mark- UI views
@property (weak, nonatomic) IBOutlet UIView *topViewControls;
@property (weak, nonatomic) IBOutlet UIView *bottomViewControls;
@property (weak, nonatomic) IBOutlet UIView *advancedView;
@property (weak, nonatomic) IBOutlet UIView *sizeView;
@property (weak, nonatomic) IBOutlet UIButton *controlsBackButton;
@property (weak, nonatomic) IBOutlet UIButton *controlsHideButton;

#pragma mark - Copy/Blend/Mix patch Modes
@property (weak, nonatomic) IBOutlet UIButton *concealModeCopyBtn;
@property (weak, nonatomic) IBOutlet UIButton *concealModeTextureBtn;
@property (weak, nonatomic) IBOutlet UIButton *concealModeBlendBtn;

#pragma mark - 2D/3D
- (IBAction)change2d3d:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *renderMode2dBtn;
@property (weak, nonatomic) IBOutlet UIButton *renderMode3dBtn;
@property (weak, nonatomic) IBOutlet UIView *mode2d3dView;

#pragma mark - Auto Apply
@property (weak, nonatomic) IBOutlet UISwitch *autoApplyToggle;
@property(nonatomic, strong) UIView *currentSelectionView;
@property(nonatomic, strong) PatchesView *patchViewSource;
@property(nonatomic, strong) PatchesView *patchViewTarget;
@property(nonatomic, strong) PatchesView *patchLineConnector;
@property(nonatomic, strong) RenderProperties *lineProps;
@property(nonatomic, strong) RenderProperties *sourceProps;
@property(nonatomic, strong) RenderProperties *targetProps;
@property(nonatomic, strong) UIImage * sourceImage;
@property(nonatomic, strong) NSData * sourceJSON;

#pragma mark - Localization IBOutlets
@property (weak, nonatomic) IBOutlet UIButton *advancedButton;
@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *lblBlendMode;
@property (weak, nonatomic) IBOutlet UILabel *lblAutoapply;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *lblStepper;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIView * separatorView;

- (void)configureConcealWith:(UIImage*)image andData:(NSData*)jsonData;
- (IBAction)undoAction:(id)sender;
- (IBAction)redoAction:(id)sender;
- (void)refreshPatches;
- (IBAction)resetImageChanges:(id)sender;
- (IBAction)hideControls:(id)sender;
- (IBAction)returnControlsBack:(id)sender;
- (IBAction)openSizeView:(id)sender;
- (IBAction)openAdvancedView:(id)sender;
- (IBAction)changeConcealMode:(id)sender;
- (IBAction)nadgeUp:(id)sender;
- (IBAction)nadgeRight:(id)sender;
- (IBAction)nadgeBottom:(id)sender;
- (IBAction)nadgeLeft:(id)sender;
- (IBAction)autoApplyToggle:(id)sender;
- (IBAction)changePatchSizeAction:(id)sender;
- (IBAction)applyPatchAction:(id)sender;
- (NSData*)getLastActionForRedo;
- (BOOL)initializeConcealer;
- (IBAction)cancelConcealAction:(id)sender;
- (IBAction)completeConcealAction:(id)sender;
- (IBAction)openHelpVideoLayer:(id)sender;
@end
