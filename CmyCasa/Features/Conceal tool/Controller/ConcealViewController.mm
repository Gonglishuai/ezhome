//
//  ConcealViewController.m
//  ClearSceneDemo
//
//  Created by Berenson Sergei on 3/2/14.
//  Copyright (c) 2014 SB Tech. All rights reserved.
//

#import "ConcealViewController.h"

#import "ConcealSessionWrapper.h"
#import "GraphicRender.h"
#import "PatchesView.h"
#import "RenderProperties.h"
#import "CommandConcealItem.h"
#import "VideoPlayerViewController.h"
#import "ConfigManager.h"

#define MAX_NUDGE_SIZE 100
#define MIN_NUDGE_SIZE 1

#define UNDO_MAX_ITEMS 10

#ifdef DEBUG
#define CONCEAL_DEBUG

#endif


@interface ConcealViewController ()

@property (nonatomic) BOOL autoApplyMode;
@property (nonatomic, strong) ConcealSessionWrapper * concealTool;
@property (nonatomic) size_t patchSize;
@property(nonatomic, strong) NSTimer *patchTimer;
@property (nonatomic) NSInteger nudgeStep;
@property (nonatomic, strong) NSMutableArray * undoList;
@property (nonatomic, strong) NSMutableArray * redoList;
@property (nonatomic,assign) CGRect currentbottomFrame;
@end

@implementation ConcealViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.undoHandler = [[UndoHandler alloc] initWithStepsLimit:UNDO_MAX_ITEMS];
    self.patchSize = (IS_IPAD)?70:35;
    self.nudgeStep = 1.0f;
    self.autoApplyMode = NO;
    self.undoList = [NSMutableArray new];
    self.redoList = [NSMutableArray new];
    
//    if (IS_IPHONE) {
//        self.lblAutoapply.frame = CGRectMake(self.autoApplyToggle.frame.origin.x + self.autoApplyToggle.frame.size.width + 15, self.lblAutoapply.frame.origin.y, self.lblAutoapply.frame.size.width, self.lblAutoapply.frame.size.height);
//    }
    
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoomView:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    [self.backgroundImage setImage:self.sourceImage];
    
    if (!self.sourceJSON)
    {
        self.mode2d3dView.hidden = YES;
        
    }
    
    self.sizeView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
    
#ifdef CONCEAL_DEBUG
    
    if( self.sourceJSON)
    {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        
        NSString * filename = [NSString stringWithFormat:@"conceal_result%f",[NSDate timeIntervalSinceReferenceDate]];
        
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",filename]];
        
        NSString* aStr;
        aStr = [[NSString alloc] initWithData:self.sourceJSON encoding:NSUTF8StringEncoding];
        
        
       [aStr writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
#endif
    
    if (![ConfigManager isShowConcealerHelpActive]) {
        [self.helpButton setHidden:YES];
        [self.separatorView setHidden:YES];
    }
    
    [self localizeUI];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc
{
    if (self.concealTool)
        [self.concealTool stopConcealWork];
    
    NSLog(@"dealloc - ConcealViewController");
}

#pragma mark -
- (void)configureConcealWith:(UIImage*)image andData:(NSData*)jsonData
{
    if(image){
        self.sourceImage = [image copy];
        self.sourceJSON = [jsonData copy];
    }
}

- (void)localizeUI
{    
    [self.advancedButton setTitle:NSLocalizedString(@"clean_tool_advanced", @"") forState:UIControlStateNormal];
    [self.sizeButton  setTitle:NSLocalizedString(@"clean_tool_size", @"") forState:UIControlStateNormal];
    [self.applyButton  setTitle:NSLocalizedString(@"clean_tool_apply", @"") forState:UIControlStateNormal];
    [self.resetButton setTitle:NSLocalizedString(@"clean_tool_reset", @"") forState:UIControlStateNormal];
    self.lblAutoapply.text = NSLocalizedString(@"clean_tool_autoapply", @"");
    [self.cancelButton  setTitle:NSLocalizedString(@"redesign_sign_in_cancel_button", @"") forState:UIControlStateNormal];
    [self.doneButton  setTitle:NSLocalizedString(@"Done_edit_profile_button_title", @"") forState:UIControlStateNormal];
    [self.helpButton  setTitle:NSLocalizedString(@"activity_welcome_help_key", @"") forState:UIControlStateNormal];
    [self.concealModeBlendBtn  setTitle:NSLocalizedString(@"clean_tool_blend", @"") forState:UIControlStateNormal];
    [self.concealModeCopyBtn  setTitle:NSLocalizedString(@"clean_tool_copy", @"") forState:UIControlStateNormal];
    [self.concealModeTextureBtn  setTitle:NSLocalizedString(@"clean_tool_texture", @"") forState:UIControlStateNormal];
    self.lblBlendMode.text = NSLocalizedString(@"clean_tool_blend_mode", @"");
    self.lblStepper.text = NSLocalizedString(@"clean_tool_stepper", @"");
    [self.renderMode2dBtn setTitle:NSLocalizedString(@"clean_tool_2d", @"") forState:UIControlStateNormal];
    [self.renderMode3dBtn setTitle:NSLocalizedString(@"clean_tool_3d", @"") forState:UIControlStateNormal];
}

- (BOOL)initializeConcealer
{
    self.concealTool = [[ConcealSessionWrapper alloc] initWithInitialImage:self.sourceImage patchSideSize:self.patchSize json3dCube:self.sourceJSON ];
    
    if (!self.concealTool) {
        return NO;
    }
    
    self.mode2d3dView.hidden = !self.concealTool.mode3dEnabled;
    [self initalizePatchesDrawingViews];
    [self refreshPatches];
    [self controlsUpdate];
    
    return YES;
}

- (void)pinchZoomView:(UIPinchGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateFailed &&
        recognizer.state != UIGestureRecognizerStateCancelled) {
        
        CGPoint point = [recognizer locationInView:self.view];
        
        [self.concealTool selectPatch:point];
        
        self.patchSize = self.patchSizeScroller.value*recognizer.scale;
        
        
        if (self.patchSize>self.patchSizeScroller.maximumValue)
            self.patchSize = self.patchSizeScroller.maximumValue;
        
        if (self.patchSize<self.patchSizeScroller.minimumValue) {
            self.patchSize = self.patchSizeScroller.minimumValue;
        }
        
        [self.concealTool setPatchSizeSize:self.patchSize];
        [self refreshPatches];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.patchSizeScroller.value = self.patchSize;
        [self redrawAction:nil];
    }
}

- (void)initalizePatchesDrawingViews {
    self.patchViewSource = [[PatchesView alloc] initWithFrame:self.view.frame];
    
    self.patchViewTarget = [[PatchesView alloc] initWithFrame:self.view.frame];
    
    self.patchLineConnector = [[PatchesView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.patchViewSource];
    [self.view addSubview:self.patchViewTarget];
    [self.view addSubview:self.patchLineConnector];
    
    self.sourceProps = [RenderProperties new];
    self.targetProps = [RenderProperties new];
    self.lineProps = [RenderProperties new];
    self.lineProps.rtype = kRenderLineBetweenPoints;
    self.lineProps.lineType = kRenderSquareSource;
    self.sourceProps.lineWidth = 1.5;
    self.sourceProps.rtype = kRenderSquareSource;
    self.sourceProps.fillColor = [UIColor blackColor];
    self.targetProps.lineWidth = 1.5;
    self.targetProps.rtype = kRenderSquareTarget;
    self.targetProps.fillColor = [UIColor colorWithRed:0.0f/255.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0];
}

- (void)refreshPatches
{
    [self.patchViewSource drawPatch:self.view.frame WithPoints:[self.concealTool getPatchCorners:SOURCE_PATCH withShrinkSize:0]
                        innerPoints:nil  properties:self.sourceProps ];
    [self.patchViewTarget drawPatch:self.view.frame WithPoints:[self.concealTool getPatchCorners:TARGET_PATCH  withShrinkSize:0]
                        innerPoints:[self.concealTool getPatchCorners:TARGET_PATCH  withShrinkSize:3]
                         properties:self.targetProps ];
    
    self.lineProps.sourcePoints = [self.concealTool getPatchCorners:SOURCE_PATCH  withShrinkSize:0];
    self.lineProps.targetPoints = [self.concealTool getPatchCorners:TARGET_PATCH  withShrinkSize:0];
    
    self.lineProps.lineType = self.sourceProps.rtype;
    [self.patchLineConnector drawPatch:self.view.frame WithPoints:nil innerPoints:nil properties:self.lineProps ];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    if (self.sizeView.hidden == NO) {
        CGPoint locationPoint = [[touches anyObject] locationInView:self.sizeView];
        UIView* viewYouWishToObtain = [self.sizeView hitTest:locationPoint withEvent:event];
        if (!viewYouWishToObtain) {
            self.sizeView.hidden = YES;
        }
    }
    
    if (self.advancedView.hidden == NO) {
        CGPoint locationPoint = [[touches anyObject] locationInView:self.advancedView];
        UIView* viewYouWishToObtain = [self.advancedView hitTest:locationPoint withEvent:event];
        if (!viewYouWishToObtain) {
            self.advancedView.hidden = YES;
        }
    }
    
    [self.concealTool selectPatch:[aTouch locationInView:self.view]];
    
    WhichPatch patch  = [self.concealTool getCurrentPatch];
    
    if (patch == SOURCE_PATCH)
    {
        self.autoApplyMode = NO;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.view];
    
    BOOL isMoved = [self.concealTool moveSelectedPatchTo:location];
    if (!isMoved) {
        NSLog(@"Not moved");
    }
    
    [self refreshPatches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self redrawAction:nil];
        
        UITouch *aTouch = [touches anyObject];
        [aTouch locationInView:self.view];
        
        WhichPatch patch  = [self.concealTool getCurrentPatch];
        
        if (patch == TARGET_PATCH && self.autoApplyMode)
        {
            [self applyPatchAction:nil];
        }
    });
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (IBAction)change2d3d:(id)sender {
    
    [self closeAllExtraViews];
    
    if ([sender isEqual:self.renderMode2dBtn]) {
        if ([self.concealTool setPatchMode:PATCH_2D])
        {
            self.renderMode3dBtn.selected = NO;
            self.renderMode2dBtn.selected = YES;
        }
    }
    
    if ([sender isEqual:self.renderMode3dBtn]) {
        
        if([self.concealTool setPatchMode:PATCH_3D])
        {
            self.renderMode3dBtn.selected = YES;
            self.renderMode2dBtn.selected = NO;
        }
    }
    
    [self redrawAction:nil];
    [self refreshPatches];
}

- (IBAction)changePatchSizeAction:(id)sender {
    self.patchSize = self.patchSizeScroller.value;
    
    [self.concealTool setPatchSizeSize:self.patchSize];
    [self redrawAction:nil];
    [self refreshPatches];
}

#pragma mark - Conceal Actions
-(void)setAutoApplyMode:(BOOL)mode
{
    _autoApplyMode = mode;
    
    self.autoApplyToggle.on = mode;
    if (mode)
    {
        [self applyPatchAction:nil];
    }
}

- (IBAction)redrawAction:(id)sender
{
        UIImage * resultImage = [self.concealTool redraw];
        [self.backgroundImage setImage:resultImage];
}

- (IBAction)applyPatchAction:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeAllExtraViews];
    
        UIImage * beforeChange =[self.concealTool getSourceImage];
        UIImage * resultImage =  [self.concealTool applyChangeToSrcImage];
        
        [self addImageDataToUndoList:UIImagePNGRepresentation([beforeChange copy])];
        [self.backgroundImage setImage:resultImage];
    });
}


- (NSData *)getLastActionForUndo
{
    if (!self.undoList || self.undoList.count==0) return nil;
    
    NSData * data = [self.undoList lastObject];
    [self.undoList removeObject:data];
    
    return data;
}

- (void)addToRedoList:(NSData *)data
{
    
    if (!data)return;
    
    if (self.redoList.count-1 == UNDO_MAX_ITEMS)
    {
        [self.redoList removeObjectAtIndex:0];
    }
    
    [self.redoList addObject:data];
}
- (NSData *)getLastActionForRedo
{
    if (!self.redoList || self.redoList.count==0) return nil;
    
    NSData * data = [self.redoList lastObject];
    [self.redoList removeObject:data];
    
    return data;
}

- (IBAction)autoApplyToggle:(id)sender
{
    [self closeAllExtraViews];
    
    self.autoApplyMode = !self.autoApplyMode;
}

- (IBAction)undoAction:(id)sender
{
    
    [self applyUndoStep];
}
- (void)refreshUnodButtons
{
    
    self.undoButton.enabled = [self.undoHandler canPerformCommand:kCommandUndo];
    self.redoButton.enabled = [self.undoHandler canPerformCommand:kCommandRedo];
}

- (IBAction)redoAction:(id)sender
{
    [self applyRedoStep];
}

- (IBAction)changeConcealMode:(id)sender
{
    [self closeAllExtraViews];
    
    PatchTransferMode  mode;
    self.concealModeCopyBtn.selected = NO;
    self.concealModeTextureBtn.selected = NO;
    self.concealModeBlendBtn.selected = NO;
    if ([sender isEqual:self.concealModeCopyBtn]) {
        mode = PATCH_COPY;
        self.concealModeCopyBtn.selected = YES;
    }
    
    if ([sender isEqual:self.concealModeTextureBtn]) {
        mode = SEAMLESS_CLONE;
        self.concealModeTextureBtn.selected = YES;
    }
    
    if ([sender isEqual:self.concealModeBlendBtn]) {
        mode = MIXTURE_MODE;
        self.concealModeBlendBtn.selected = YES;
    }
    
    
    
    [self.concealTool setPatchTransferMode:mode];
    
    [self redrawAction:nil];
    [self refreshPatches];
}

- (IBAction)resetImageChanges:(id)sender
{
    [self closeAllExtraViews];
    [self resetConcealToolWithCurrentImage];
}

- (IBAction)nadgeUp:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //choose patch if not selected
        [self.concealTool selectSpecificPatch:TARGET_PATCH];
        
        [self.concealTool nudgeWithPoint:CGPointMake(0, -self.nudgeStep)];
        
        [self redrawAction:nil];
        [self refreshPatches];
    });
}

- (IBAction)nadgeRight:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //choose patch if not selected
        [self.concealTool selectSpecificPatch:TARGET_PATCH];
        
        [self.concealTool nudgeWithPoint:CGPointMake(self.nudgeStep, 0)];
        [self redrawAction:nil];
        [self refreshPatches];
    });
}

- (IBAction)nadgeBottom:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.concealTool selectSpecificPatch:TARGET_PATCH];
        
        
        [self.concealTool nudgeWithPoint:CGPointMake(0, self.nudgeStep)];
        [self redrawAction:nil];
        [self refreshPatches];
    });
}

- (IBAction)nadgeLeft:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.concealTool selectSpecificPatch:TARGET_PATCH];
        
        
        [self.concealTool nudgeWithPoint:CGPointMake(-self.nudgeStep, 0)];
        [self redrawAction:nil];
        [self refreshPatches];
    });
}

-(void)resetConcealToolWithCurrentImage
{
    self.autoApplyMode = NO;
    self.patchSize = 70;
    self.nudgeStep = 5.0f;
    self.lineProps.rtype = kRenderLineBetweenPoints;
    self.lineProps.lineType = kRenderSquareSource;
    self.sourceProps.lineWidth = 1.5;
    self.sourceProps.rtype = kRenderSquareSource;
    self.sourceProps.fillColor = [UIColor blackColor];
    self.targetProps.lineWidth = 1.5;
    self.targetProps.rtype = kRenderSquareTarget;
    self.targetProps.fillColor = [UIColor colorWithRed:0.0f/255.0f green:143.0f/255.0f blue:213.0f/255.0f alpha:1.0];
    [self.backgroundImage setImage:self.sourceImage];
    [self.concealTool setupConcealWrapper:self.sourceImage patchSize:self.patchSize jsonStr:self.sourceJSON];
    
    [self controlsUpdate];
}

- (void)controlsUpdate {
    if (self.concealTool)
    {
        [self.concealTool startConcealWork];
        [self.concealTool draw];
        
        self.concealModeBlendBtn.selected = [self.concealTool getCurrentPatchTransferMode]==MIXTURE_MODE;
        self.concealModeCopyBtn.selected = [self.concealTool getCurrentPatchTransferMode]==PATCH_COPY;
        self.concealModeTextureBtn.selected = [self.concealTool getCurrentPatchTransferMode]==SEAMLESS_CLONE;
        self.renderMode2dBtn.selected = [self.concealTool getCurrentPatchMode]==PATCH_2D;
        self.renderMode3dBtn.selected = [self.concealTool getCurrentPatchMode]==PATCH_3D;
        self.patchSizeScroller.value = self.patchSize;
        [self refreshPatches];
        
    }
}

- (IBAction)cancelConcealAction:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)completeConcealAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(concealDoneWithNewImage:)]) {
        UIImage * image = [self.concealTool getSourceImage];
        [self.delegate concealDoneWithNewImage:image];
    }
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)openHelpVideoLayer:(id)sender
{
    
    if ([[ConfigManager sharedInstance] concealHelpVideoLink])
    {
        VideoPlayerViewController * videoVC = [VideoPlayerViewController newPlayer];
        videoVC.videoPathURL = [NSURL URLWithString:[[ConfigManager sharedInstance] concealHelpVideoLink]];
        
        [self.view addSubview:videoVC.view];
        [self addChildViewController:videoVC];
    }
}

- (IBAction)hideControls:(id)sender
{
    [self closeAllExtraViews];
    CGRect topFrame =  self.topViewControls.frame;
    CGRect bottomFrame = self.bottomViewControls.frame;
    self.currentbottomFrame = self.bottomViewControls.frame;
    
    topFrame.origin.y = -topFrame.size.height;
    bottomFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.topViewControls.frame = topFrame;
        self.bottomViewControls.frame = bottomFrame;
        
        self.controlsBackButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)returnControlsBack:(id)sender
{
    [self closeAllExtraViews];
    CGRect topFrame =  self.topViewControls.frame;
    CGRect bottomFrame = self.currentbottomFrame;
    
    topFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.topViewControls.frame = topFrame;
        self.bottomViewControls.frame = bottomFrame;
        
        self.controlsBackButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)openSizeView:(id)sender
{
    self.advancedView.hidden = YES;
    self.sizeView.hidden = !self.sizeView.hidden;
}

- (IBAction)openAdvancedView:(id)sender
{
    self.sizeView.hidden = YES;
    self.advancedView.hidden = !self.advancedView.hidden;
}

- (void)closeAllExtraViews
{
    self.sizeView.hidden = YES;
}

- (void)addImageDataToUndoList:(NSData*)imageData
{
    [self.undoHandler clearCommandByType:kCommandRedo];
    CommandConcealItem * state = [[CommandConcealItem alloc] initWithStepData:imageData andItemID:@""];
    [self.undoHandler addUndoCommand:state];
    [self refreshUnodButtons];
}

- (void)discardLastUndoStep
{
    [self.undoHandler getUndoCommand];
}

- (BOOL)canUndo
{
    return [self.undoHandler canPerformCommand:kCommandUndo];
}

- (BOOL)canRedo
{
    return [self.undoHandler canPerformCommand:kCommandRedo];
}

- (void)applyUndoStep
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CommandConcealItem * step = [self.undoHandler getUndoCommand];
        
        
        UIImage * beforeChange =[self.concealTool getSourceImage];
        
        CommandConcealItem * currentState = [[CommandConcealItem alloc] initWithStepData:UIImagePNGRepresentation([beforeChange copy]) andItemID:@""];
        
        
        [self.undoHandler addRedoCommand:currentState];
        
        UIImage * img = [UIImage imageWithData:step.data];
        if (img)
        {
            self.backgroundImage.image = img;
            
            [self.concealTool updateSourceImageForConcealer:img];
            [self redrawAction:nil];
        }
        
        [self refreshUnodButtons];
    });
}

- (void)applyRedoStep
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CommandConcealItem * step = [self.undoHandler getRedoCommand];
        
        
        UIImage * beforeChange =[self.concealTool getSourceImage];
        
        
        CommandConcealItem * currentState = [[CommandConcealItem alloc] initWithStepData:UIImagePNGRepresentation([beforeChange copy]) andItemID:@""];
        [self.undoHandler addUndoCommand:currentState];
        
        UIImage * img = [UIImage imageWithData:step.data];
        if (img)
        {
            self.backgroundImage.image = img;
            
            [self.concealTool updateSourceImageForConcealer:img];
            [self redrawAction:nil];
        }
        
        [self refreshUnodButtons];
    });
}

@end




