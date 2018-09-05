//
//  MeasureViewController.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//
//

#import "MeasureViewController.h"
#import "General3DViewController+CubeAccess.h"
#import "AppDelegate.h"
#import "Furniture3DViewController.h"
#import "MathMacros.h"
#import "UIColorMacros.h"

#define LFUNC(x, a, v0) (a * (x - v0.x) + v0.y) //linear line starting at point v0, with slop a and position x.
#define TAPE_WIDTH (0.3)
#define TAPE_INIT_LENGTH (1.4)
#define TAPE_INIT_VALUE (100)
#define BIG_EPSILON (EPSILON * 50)
#define FEET_IN_METERS (0.3048f)
#define INCH_IN_CM (2.54)
#define CM_IN_METER (0.01)
#define METER_IN_CM (100)
#define FEET_IN_INCH (12)
#define MAX_UNITS (500)
#define MAX_LENGTH_IN_CM (1999)
#define MIN_LENGTH_IN_CM (30)
#define MAJOR_UNIT (0)
#define MINOR_UNIT (1)
#define MIN_TAPE_LENGTH (0.4)

static const GLubyte tape[] = {
    0, 1, 2,
    1, 3, 2,
    
    4, 5, 6,
    5, 7, 6,
    
    8, 9, 10,
    9, 11, 10,
};

static const GLfloat initTapeTex[] = {
    0.5, 0,
    0.5, 0.5,
    1, 0,
    1, 0.5,
    
    0, 0.5,
    0, 1,
    1, 0.5,
    1, 1,
    
    0, 0,
    0, 0.5,
    0.5, 0,
    0.5, 0.5,
};

static void buttonPaintsFromTapePoints(GLKVector3 p1, GLKVector3 p2, GLKVector3 *cp1, GLKVector3 *cp2) {
    GLKVector3 mid = GLKVector3DivideScalar(GLKVector3Add(p1, p2), 2);
  
    float width;
    if (fabsf(mid.z) <= 10) {
        width = (fabsf(mid.z) / 10.0f) * TAPE_WIDTH;
    } else {
        width = TAPE_WIDTH * (log10(fabsf(mid.z)));
    }

    GLKVector3 horizontalWidth = GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(p2, p1)), width);
    GLKVector3 p11 = GLKVector3Add(p1, horizontalWidth);
    GLKVector3 p22 = GLKVector3Subtract(p2, horizontalWidth);
    *cp1 = GLKVector3DivideScalar(GLKVector3Add(p1, p11), 2);
    *cp2 = GLKVector3DivideScalar(GLKVector3Add(p2, p22), 2);
}

static void tapeFromPoints(GLKVector3 p1, GLKVector3 p2, GLKVector3 norm, GLfloat aTape[], GLfloat aTapeTexCoords[]) {
	GLKVector3 diff = GLKVector3Subtract(p2, p1);
    GLKVector3 mid = GLKVector3DivideScalar(GLKVector3Add(p1, p2), 2);
    float width = TAPE_WIDTH;//(fabsf(mid.z) / 10.0f) * TAPE_WIDTH;
    if (fabsf(mid.z) <= 10) {
        width = (fabsf(mid.z) / 10.0f) * TAPE_WIDTH;
    } else {
        width = TAPE_WIDTH * (log10(fabsf(mid.z)));
    }
	GLKVector3 halfwidth = GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(diff, norm)), width/2.0f);
    GLKVector3 horizontalWidth = GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(p2, p1)), width);
    GLKVector3 p11 = GLKVector3Add(p1, horizontalWidth);
    GLKVector3 p22 = GLKVector3Subtract(p2, horizontalWidth);
    
	GLKVector3 halfwidthNeg = GLKVector3Negate(halfwidth);
	GLKVector3 v1 = GLKVector3Add(p1, halfwidth);
	GLKVector3 v2 = GLKVector3Add(p1, halfwidthNeg);
	GLKVector3 v3 = GLKVector3Add(p2, halfwidth);
	GLKVector3 v4 = GLKVector3Add(p2, halfwidthNeg);
    GLKVector3 v11 = GLKVector3Add(p11, halfwidth);
    GLKVector3 v21 = GLKVector3Add(p11, halfwidthNeg);
    GLKVector3 v31 = GLKVector3Add(p22, halfwidth);
    GLKVector3 v41 = GLKVector3Add(p22, halfwidthNeg);
    
	aTape[0] = v1.x; aTape[1] = v1.y; aTape[2] = v1.z;
	aTape[3] = v2.x; aTape[4] = v2.y; aTape[5] = v2.z;
    
	aTape[6] = v11.x; aTape[7] = v11.y; aTape[8] = v11.z;
	aTape[9] = v21.x; aTape[10] = v21.y; aTape[11] = v21.z;
    
    aTape[12] = v11.x; aTape[13] = v11.y; aTape[14] = v11.z;
	aTape[15] = v21.x; aTape[16] = v21.y; aTape[17] = v21.z;
    
    aTape[18] = v31.x; aTape[19] = v31.y; aTape[20] = v31.z;
	aTape[21] = v41.x; aTape[22] = v41.y; aTape[23] = v41.z;
    
	aTape[24] = v31.x; aTape[25] = v31.y; aTape[26] = v31.z;
	aTape[27] = v41.x; aTape[28] = v41.y; aTape[29] = v41.z;
    
    aTape[30] = v3.x; aTape[31] = v3.y; aTape[32] = v3.z;
	aTape[33] = v4.x; aTape[34] = v4.y; aTape[35] = v4.z;
    
	aTapeTexCoords[12] = aTapeTexCoords[14] = GLKVector3Distance(p11, p22) / (2 * width);
}

@interface MeasureViewController ()

// Called when the device rotation is changed.
- (void) updateTape;
@property (strong, nonatomic) GLKTextureInfo* wireframeTex;
@end

@implementation MeasureViewController

@synthesize pickerView;
@synthesize buttonTapeCenter, buttonTapeLeft, buttonTapeRight, buttonTapeValue;
@synthesize imageView;

- (void)viewDidLoad{
    [super viewDidLoad];
    
	self.cubeTextureScale = kCubeWireframeRealWorldSize;
	// Tape data
	memcpy(tapeTexCoord, initTapeTex, sizeof(GLfloat) * TAPE_VERTS * TEX_COORDS);
	tapeP1 = GLKVector3Make(0, 1, 0);
	tapeP2 = GLKVector3Make(0, 0, 0);
	tapeNorm = GLKVector3Make(0, 0, -1);
	[self updateTape];
	
	UIPanGestureRecognizer* dragLeftTape = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTapePoint:)];
	[self.buttonTapeLeft addGestureRecognizer:dragLeftTape];
	UIPanGestureRecognizer* dragRightTape = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTapePoint:)];
	[self.buttonTapeRight addGestureRecognizer:dragRightTape];
	UIPanGestureRecognizer* dragCenterTape = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTape:)];
	[self.buttonTapeCenter addGestureRecognizer:dragCenterTape];
	
	self.buttonTapeValue.titleLabel.text = [[[NSNumber numberWithInt:TAPE_INIT_VALUE] stringValue] stringByAppendingString:@" cm"];
	self.pickerView.delegate = self;
	self.pickerView.dataSource = self;
    self.pickerView.hidden = NO;
    
    NSDictionary* textureOptions = @{GLKTextureLoaderGenerateMipmaps: @YES,
							  GLKTextureLoaderApplyPremultiplication: @YES};
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate textureLoader] textureWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"scale_arrows" withExtension:@"png"] options:textureOptions queue:NULL completionHandler:^(GLKTextureInfo *textureInfo, NSError *outError) {
		tapeTex = textureInfo;
	}];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tap.delegate = self;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.view sendSubviewToBack:[appDelegate glkView]];
    [self.view sendSubviewToBack:imageView];
  
    self.imageView.image = self.currentDesign.image;
	currentWall = WallFront;
	// Update cube verts array
	if (self.currentDesign.CubeVerts != nil) {
		GLKVector3 xDir;
		if ([self vertexInView:7]) {
			tapeP1 = [self getVectorForVertex:7];
			tapeP2 = [self getVectorForVertex:4];
			xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
		} else {
			tapeP1 = [self getVectorForVertex:6];
			tapeP2 = [self getVectorForVertex:5];
			xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:5]));
		}
		
		xDir = GLKVector3MultiplyScalar(xDir, BIG_EPSILON);
		tapeP1 = GLKVector3Add(tapeP1, xDir);
		tapeP2 = GLKVector3Add(tapeP2, xDir);
		tapeP1 = GLKVector3Add(tapeP1, GLKVector3Make(0, BIG_EPSILON, 0));
        GLKVector3 top = [self findEdgeOfLineStartingAt:tapeP1 end:tapeP2 withScreen:ScreenEdgeTop];
		tapeP2 = GLKVector3Add(tapeP1, GLKVector3Make(0, GLKVector3Distance(tapeP1, tapeP2)-BIG_EPSILON, 0));
        if (top.y < tapeP2.y) {
            tapeP2 = GLKVector3Add(tapeP1, GLKVector3Make(0, GLKVector3Distance(tapeP1, top)-BIG_EPSILON, 0));
        }
		tapeNorm = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:0]));
		[self updateTape];
	}
	[self.buttonTapeValue setTitle:@"_ _ _ _ _" forState:UIControlStateNormal];
	[self.buttonTapeValue setTitle:@"_ _ _ _ _" forState:UIControlStateHighlighted];
	[self.buttonTapeValue setTitle:@"_ _ _ _ _" forState:UIControlStateSelected];

    BOOL useCm = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"UnitSelected"] boolValue];
    
    if (useCm) {
        self.cmButton.selected=YES;
        self.fettButton.selected=NO;
    } else {
        self.cmButton.selected=NO;
        self.fettButton.selected=YES;
    }

    currentScale = self.currentDesign.GlobalScale;
	
    if (currentScale < 0.01f)
        currentScale = 1.0f;
    
    HSMDebugLog(@"Current Scale: %.2f", currentScale);
    [self.pickerView reloadAllComponents];
    
    HSMDebugLog(@"Tape length: %.2f", currentScale * GLKVector3Length(GLKVector3Subtract(tapeP2, tapeP1)));
    float val =  currentScale * GLKVector3Length(GLKVector3Subtract(tapeP2, tapeP1));
    
    [self setMeasuringTapeValue:val animated:NO];
    
    [self updateCurrentScale];
    
    if (editValueMode == NO) {
        [self iPadValuePressed:self];
    }
    self.buttonTapeValue.alpha = 1;
    [[HelpManager sharedInstance]presentHelpViewController:@"help_scale" withController:self isForceToShow:YES];
}

- (void)viewDidDisappear:(BOOL)animated {

    self.currentDesign = nil;

    [super viewDidDisappear:animated];
}

-(void)dealloc {
    
    self.imageView = nil;
    self.currentDesign = nil;

    // Tape controlls
    self.pickerView = nil;
    self.delegate = nil;
    
    if (self.wireframeTex) {
        GLuint name = self.wireframeTex.name;
        glDeleteTextures(1, &name);
        self.wireframeTex = nil;
    }
    
    if (tapeTex) {
        GLuint name = tapeTex.name;
        glDeleteTextures(1, &name);
        tapeTex = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc - MeasureViewController");
}

#pragma mark
// Is the given vertex visible in the view
-(BOOL)vertexInView:(int)idx {
	GLKVector3 v = [self getVectorForVertex:idx];
	GLKVector3 p = [self projectPointForVector:v];
	return p.x >= 0 && p.x<=self.view.bounds.size.width && p.y >= 0 && p.y <= self.view.bounds.size.height;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

#pragma mark GLKViewControllerDelegate
// Setup perspective, update wirefram, and set the controlls accordingly.
- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    [super glkViewControllerUpdate:controller];
	self.effect.light0.enabled = GL_FALSE;
    self.wallsTransparency = 0.375;
	GLKVector3 leftButtonPoint, rightButtonPoint;
    buttonPaintsFromTapePoints(tapeP1, tapeP2, &leftButtonPoint, &rightButtonPoint);
    
    if (!isnan(leftButtonPoint.x) && !isnan(leftButtonPoint.y)) {
        self.buttonTapeLeft.center = [self getPointForVector:leftButtonPoint];
    }
    
    if (!isnan(rightButtonPoint.x) && !isnan(rightButtonPoint.y)) {
        self.buttonTapeRight.center = [self getPointForVector:rightButtonPoint];
    }
    
	self.buttonTapeCenter.center = [self getPointForVector:GLKVector3DivideScalar(GLKVector3Add(tapeP1, tapeP2), 2.0f)];
	GLKVector2 p1 = vecFromPoint(self.buttonTapeLeft.center);
	GLKVector2 p2 = vecFromPoint(self.buttonTapeRight.center);
	GLKVector2 tapeDir = GLKVector2Normalize(GLKVector2Subtract(p2, p1));
	float tapeAngle = angleBetween2DVectors(GLKVector2Make(1, 0), tapeDir);
	GLKVector2 valuePos = vecFromPoint(self.buttonTapeCenter.center);
	self.buttonTapeCenter.transform = CGAffineTransformIdentity;
	self.buttonTapeCenter.frame = CGRectMake(0, 0, GLKVector2Length(GLKVector2Subtract(p2, p1)), 30);
	self.buttonTapeCenter.transform = CGAffineTransformMakeRotation(tapeAngle);
	self.buttonTapeCenter.center = pointFromVec(valuePos);
	self.buttonTapeLeft.transform = CGAffineTransformMakeRotation(tapeAngle);
	self.buttonTapeRight.transform = CGAffineTransformMakeRotation(tapeAngle);
    self.buttonTapeValue.transform = CGAffineTransformMakeRotation(tapeAngle);
    GLKVector2 perp = GLKVector2Make(-tapeDir.y, tapeDir.x);
    self.buttonTapeValue.center = pointFromVec(GLKVector2Add(valuePos, GLKVector2MultiplyScalar(perp, -25)));
    if (!CGRectContainsRect(self.view.bounds, self.buttonTapeValue.frame)) {
        self.buttonTapeValue.center = pointFromVec(GLKVector2Add(valuePos, GLKVector2MultiplyScalar(perp, 25)));
    }
}

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [super glkView:view drawInRect:rect];
    
	if (self.currentDesign.CubeVerts != nil) {		
		// Tape
        self.effect.texture2d0.name = tapeTex.name;
		if (tapeTex != nil) {
			self.effect.texture2d0.enabled = GL_TRUE;
			self.effect.useConstantColor = GL_FALSE;
		} else {
			self.effect.texture2d0.enabled = GL_FALSE;
			self.effect.useConstantColor = GL_TRUE;
		}
		[self.effect prepareToDraw];
		if (tapeTex != nil) {
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		}
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glEnableVertexAttribArray(GLKVertexAttribPosition);
		glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        
		glVertexAttribPointer(GLKVertexAttribPosition, COORDS, GL_FLOAT, GL_FALSE, 0, tapeVerts);
		glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, tapeTexCoord);

        glDrawElements(GL_TRIANGLES, 18, GL_UNSIGNED_BYTE, tape);
		glDrawArrays(GL_TRIANGLES, 0, TAPE_VERTS);
		
		glDisableVertexAttribArray(GLKVertexAttribPosition);
		glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
	}
}

- (void)iPadUnitsChanged:(id)sender {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        BOOL cm = self.cmButton.selected;
        
        [standardUserDefaults setObject:[NSNumber numberWithBool:cm] forKey:@"UnitSelected"];
        [standardUserDefaults synchronize];
    }
	[self.pickerView reloadAllComponents];
    
	[self setMeasuringTapeValue:currentScale * GLKVector3Distance(tapeP1, tapeP2) animated:NO];
}

- (IBAction)donePressed:(id)sender {
    
	[self updateCurrentScale];
    
    self.currentDesign.GlobalScale = currentScale;
    
    if ([self.delegate respondsToSelector:@selector(donePressed:)]) {
        [self.delegate donePressed:self];
    }
}

// Cancel the changes made to the design
- (IBAction)cancelPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelPressed:)]) {
        [self.delegate cancelPressed:self];
    }
}

- (void)dragTapePoint:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (editValueMode == YES) [self iPadValuePressed:self];
        [UIView animateWithDuration:0.2 animations:^{
            self.buttonTapeValue.alpha = 0;
        }];
    }
	UIButton *buttonPoint = (UIButton *)gesture.view;

	// Find the amount of movement in the corrected Y axis.
    GLKVector3 tapePos = buttonPoint.tag == 1 ? tapeP1 : tapeP2;
	GLKVector3 xDirection, planeNormal;
	GLKVector2 pivotStart, pivotEnd;
	WallSide wallStart = [self wallAtPosition:tapePos x:&xDirection pivot:&pivotStart normal:&planeNormal previousWall:currentWall];
    GLKVector3 newPos = [self findIntersectionOfPoint:[gesture locationInView:self.view] withPlaneAtPoint:tapePos withNormal:planeNormal];
    GLKVector3 worldMove = GLKVector3Subtract(newPos, tapePos);
	WallSide wallEnd = [self wallAtPosition:newPos x:&xDirection pivot:&pivotEnd normal:&planeNormal previousWall:currentWall];

	for (int i = 0; wallEnd != wallStart && i < 2; ++i) {
        if (wallEnd == WallCeilling || wallEnd == WallFloor) {
            worldMove.y = 0;
        } else {
            worldMove.x = 0;
            worldMove.z = 0;
        }
        newPos = GLKVector3Add(tapePos, worldMove);
        wallEnd = [self wallAtPosition:newPos x:&xDirection pivot:&pivotEnd normal:&planeNormal previousWall:currentWall];
    }
	if (wallEnd == wallStart && [self.view pointInside:[self getPointForVector:newPos] withEvent:nil] == YES) {
		GLKVector3 tempP;
		float tempLength;
		switch (buttonPoint.tag) {
			case 1:
				tempP = GLKVector3Add(tapeP1, worldMove);
				tempLength = GLKVector3Length(GLKVector3Subtract(tapeP2, tempP));
				if (tempLength < MIN_TAPE_LENGTH) break;
				if (tempLength * currentScale < MIN_LENGTH_IN_CM * CM_IN_METER) break;
				tapeP1 = GLKVector3Add(tapeP1, worldMove);
				
                if (currentScale * GLKVector3Distance(tapeP1, tapeP2) > MAX_LENGTH_IN_CM * CM_IN_METER) {
                    tapeP1 = GLKVector3Add(tapeP2, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(tapeP1, tapeP2)), (MAX_LENGTH_IN_CM * CM_IN_METER) / currentScale));
                }
                buttonPoint.center = [self getPointForVector:tapeP1];
				break;
			case 2:
				tempP = GLKVector3Add(tapeP2, worldMove);
				tempLength = GLKVector3Length(GLKVector3Subtract(tempP, tapeP1));
				if (tempLength < MIN_TAPE_LENGTH) break;
				if (tempLength * currentScale < MIN_LENGTH_IN_CM * CM_IN_METER) break;
				tapeP2 = GLKVector3Add(tapeP2, worldMove);
                if (currentScale * GLKVector3Distance(tapeP1, tapeP2) > MAX_LENGTH_IN_CM * CM_IN_METER) {
                    tapeP2 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(tapeP2, tapeP1)), (MAX_LENGTH_IN_CM * CM_IN_METER )/ currentScale));
                }
                buttonPoint.center = [self getPointForVector:tapeP2];
        
				break;
			default:
				break;
		}
		[self updateTape];
	}
	
	[gesture setTranslation:CGPointZero inView:buttonPoint];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.buttonTapeValue.alpha = 1;
        }];
        [self setMeasuringTapeValue:currentScale * GLKVector3Distance(tapeP2, tapeP1) animated:NO];
    }
}

-(void)dragTape:(UIPanGestureRecognizer*)gesture {
	//if (editValueMode == YES) return;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (editValueMode == YES) [self iPadValuePressed:self];
    }
	UIButton *buttonPoint = (UIButton *)gesture.view;
    BOOL tapeOutsideView = [self.view pointInside:[self getPointForVector:tapeP1] withEvent:nil] == NO || [self.view pointInside:[self getPointForVector:tapeP2] withEvent:nil] == NO;
	GLKVector3 tapePos = GLKVector3DivideScalar(GLKVector3Add(tapeP1, tapeP2), 2);
	GLKVector3 xDirection, planeNormal;
	GLKVector2 pivotStart, pivotEnd;
	WallSide wallStart = [self wallAtPosition:tapePos x:&xDirection pivot:&pivotStart normal:&planeNormal previousWall:currentWall];
    GLKVector3 newPos = [self findIntersectionOfPoint:[gesture locationInView:self.view] withPlaneAtPoint:tapePos withNormal:planeNormal];
    GLKVector3 worldMove = GLKVector3Subtract(newPos, tapePos);
	
	tapePos = GLKVector3Add(tapeP1, worldMove);
    if (tapeOutsideView == NO && [self.view pointInside:[self getPointForVector:tapePos] withEvent:nil] == NO) return;
	WallSide wallEnd1 = [self wallAtPosition:tapePos x:&xDirection pivot:&pivotEnd normal:&planeNormal previousWall:currentWall];
	tapePos = GLKVector3Add(tapeP2, worldMove);
    if (tapeOutsideView == NO && [self.view pointInside:[self getPointForVector:tapePos] withEvent:nil] == NO) return;
	WallSide wallEnd2 = [self wallAtPosition:tapePos x:&xDirection pivot:&pivotEnd normal:&planeNormal previousWall:currentWall];
	if (wallStart == wallEnd1 && wallStart == wallEnd2) {
		tapeP1 = GLKVector3Add(tapeP1, worldMove);
		self.buttonTapeLeft.center = [self getPointForVector:tapeP1];
		tapeP2 = GLKVector3Add(tapeP2, worldMove);
		self.buttonTapeRight.center = [self getPointForVector:tapeP2];
		
		[self updateTape];
		[gesture setTranslation:CGPointZero inView:buttonPoint];
	} else {
		GLKVector2 touchP = vecFromPoint([gesture locationInView:self.view]);
		GLKVector2 buttonP = vecFromPoint(self.buttonTapeCenter.center);
		if (GLKVector2Length(GLKVector2Subtract(touchP, buttonP)) > 40) {
			WallSide newWall;
			if (wallEnd1 != wallStart) {
				newWall = wallEnd1;
			} else {
				newWall = wallEnd2;
			}
			GLKVector3 xDir, top;
            float dist = GLKVector3Distance([self getVectorForVertex:7], [self getVectorForVertex:4]);
			switch (newWall) {
				case WallFront:
					if (currentWall != WallFloor) {
						float oldY = MIN(tapeP1.y, tapeP2.y);
						if (wallStart == WallLeft) {
							tapeP1 = [self getVectorForVertex:7];
							tapeP2 = [self getVectorForVertex:4];
							xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
						} else {
							tapeP1 = [self getVectorForVertex:6];
							tapeP2 = [self getVectorForVertex:5];
							xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:5]));
						}
						tapeP1 = GLKVector3Make(tapeP1.x, oldY, tapeP1.z);
					} else {
						xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
						GLKVector3 t = tapeP1;
						t.y = [self getVectorForVertex:7].y;
						float length = GLKVector3Distance([self getVectorForVertex:7], t);
						tapeP1 = [self getVectorForVertex:7];
						tapeP2 = [self getVectorForVertex:6];
						GLKVector3 tapeDir = GLKVector3Normalize(GLKVector3Subtract(tapeP2, tapeP1));
						tapeP1 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(tapeDir, length));
						tapeP2 = GLKVector3Add(tapeP2, GLKVector3MultiplyScalar(tapeDir, length));
					}
                    
					xDir = GLKVector3MultiplyScalar(xDir, BIG_EPSILON);
					tapeP1 = GLKVector3Add(tapeP1, xDir);
					tapeP2 = GLKVector3Add(tapeP2, xDir);
					tapeP1 = GLKVector3Add(tapeP1, GLKVector3Make(0, BIG_EPSILON, 0));
					tapeP2 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(tapeP2,tapeP1)), MIN(TAPE_INIT_LENGTH, dist)));
                    top = [self findEdgeOfLineStartingAt:tapeP1 end:tapeP2 withScreen:ScreenEdgeTop];
                    if (top.y < tapeP2.y) {
                        tapeP2 = GLKVector3Add(tapeP1, GLKVector3Make(0, GLKVector3Distance(tapeP1, top) - BIG_EPSILON, 0));
                    }
					tapeNorm = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:4], [self getVectorForVertex:0]));
					currentWall = newWall;
					[self updateTape];
					break;
				case WallLeft:
					if (currentWall != WallFloor) {
						float oldY = MIN(tapeP1.y, tapeP2.y);
						tapeP1 = [self getVectorForVertex:7];
						tapeP2 = [self getVectorForVertex:4];
						tapeP1 = GLKVector3Make(tapeP1.x, oldY, tapeP1.z);
					} else {
						GLKVector3 t = GLKVector3MultiplyScalar(GLKVector3Add(tapeP1, tapeP2), 0.5f);
						t.y = [self getVectorForVertex:7].y;
						float length = GLKVector3Distance([self getVectorForVertex:7], t);
						tapeP2 = [self getVectorForVertex:7];
						tapeP1 = [self getVectorForVertex:3];
						GLKVector3 tapeDir = GLKVector3Normalize(GLKVector3Subtract(tapeP1, tapeP2));
						tapeP1 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(tapeDir, length));
						tapeP2 = GLKVector3Add(tapeP2, GLKVector3MultiplyScalar(tapeDir, length));
					}
					
					xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:3], [self getVectorForVertex:7]));
					xDir = GLKVector3MultiplyScalar(xDir, BIG_EPSILON);
					tapeP1 = GLKVector3Add(tapeP1, xDir);
					tapeP2 = GLKVector3Add(tapeP2, xDir);
					tapeP1 = GLKVector3Add(tapeP1, GLKVector3Make(0, BIG_EPSILON, 0));
					tapeP2 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(tapeP2,tapeP1)), MIN(TAPE_INIT_LENGTH, dist)));
                    top = [self findEdgeOfLineStartingAt:tapeP1 end:tapeP2 withScreen:ScreenEdgeTop];
                    if (top.y < tapeP2.y) {
                        tapeP2 = GLKVector3Add(tapeP1, GLKVector3Make(0, GLKVector3Distance(tapeP1, top) - BIG_EPSILON, 0));
                    }
					tapeNorm = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:1], [self getVectorForVertex:0]));
					currentWall = newWall;
					[self updateTape];
					break;
				case WallRight:
					if (currentWall != WallFloor) {
						float oldY = MIN(tapeP1.y, tapeP2.y);
						tapeP1 = [self getVectorForVertex:6];
						tapeP2 = [self getVectorForVertex:5];
						tapeP1 = GLKVector3Make(tapeP1.x, oldY, tapeP1.z);
					} else {
						GLKVector3 t = tapeP1;
						t.y = [self getVectorForVertex:6].y;
						float length = GLKVector3Distance([self getVectorForVertex:6], t);
						tapeP1 = [self getVectorForVertex:6];
						tapeP2 = [self getVectorForVertex:2];
						GLKVector3 tapeDir = GLKVector3Normalize(GLKVector3Subtract(tapeP2, tapeP1));
						tapeP1 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(tapeDir, length));
						tapeP2 = GLKVector3Add(tapeP2, GLKVector3MultiplyScalar(tapeDir, length));
					}
					xDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:2], [self getVectorForVertex:6]));
					xDir = GLKVector3MultiplyScalar(xDir, BIG_EPSILON);
					tapeP1 = GLKVector3Add(tapeP1, xDir);
					tapeP2 = GLKVector3Add(tapeP2, xDir);
					tapeP1 = GLKVector3Add(tapeP1, GLKVector3Make(0, BIG_EPSILON, 0));
					tapeP2 = GLKVector3Add(tapeP1, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(tapeP2,tapeP1)), TAPE_INIT_LENGTH));
					tapeNorm = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:1]));
					currentWall = newWall;
					[self updateTape];
					break;
				case WallFloor:

					break;
				case WallCeilling:

					break;
				default:
					break;
			}
			[gesture setTranslation:CGPointZero inView:buttonPoint];
		}
	}
}

- (void) updateTape {
	tapeFromPoints(tapeP1, tapeP2, tapeNorm, tapeVerts, tapeTexCoord);
}

- (IBAction)iPadValuePressed:(id)sender {
    @synchronized(self) {
        if (self.iPadValueButton.enabled == NO) return;
        self.iPadValueButton.enabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.buttonTapeValue.alpha = 1;
        }];
        static float dx = 0, dy = 0;
        float diff = self.pickerView.bounds.size.height + self.iPadBottomBar.bounds.size.height;
        if (self.pickerView.center.x < 0) {
            dx = diff;
        } else if (self.pickerView.center.x > self.view.bounds.size.width) {
            dx = -diff;
        } else if (self.pickerView.center.y < 0) {
            dy = diff;
        } else if (self.pickerView.center.y > self.view.bounds.size.height){
            dy = -diff+1;
        }
        
        if (editValueMode == NO) {
            editValueMode = YES;
            self.buttonTapeValue.userInteractionEnabled = NO;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.pickerView.alpha = 1;
                self.pickerView.center = CGPointMake(self.pickerView.center.x + dx, self.pickerView.center.y + dy);
            } completion:^(BOOL finished) {
                self.buttonTapeValue.userInteractionEnabled = YES;
                self.iPadValueButton.enabled = YES;
            }];
        } else {
            self.buttonTapeValue.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.2 animations:^{
                self.pickerView.alpha = 0;
                self.pickerView.center = CGPointMake(self.pickerView.center.x - dx, self.pickerView.center.y - dy);
            } completion:^(BOOL finished) {
                self.buttonTapeValue.userInteractionEnabled = YES;
                self.iPadValueButton.enabled = YES;
                editValueMode = NO;
            }];
        }
        [self updateTapeLabel];
    }
}

#pragma mark UIPickerView
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString* majorUnit = @"";
	NSString* minorUnit = @"";
    bool useCm = YES;
    if (self.cmButton.selected==NO){
        useCm = NO;
    }
	if (useCm) {
		majorUnit = @"m";
		minorUnit = @"cm";
		switch (component) {
			case MAJOR_UNIT:
				return [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:row], majorUnit];
				break;
			case MINOR_UNIT:
				if ([self.pickerView selectedRowInComponent:MAJOR_UNIT] == 0) row += MIN_LENGTH_IN_CM;
				return [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:row], minorUnit];
				break;
			default:
				return @"Error";
		}
	} else {
		majorUnit = @"ft";
		minorUnit = @"in";
		switch (component) {
			case MAJOR_UNIT:
				return [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:row+1], majorUnit];
				break;
			case MINOR_UNIT:
				return [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInteger:row], minorUnit];
				break;
			default:
				return @"Error";
		}
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (component == MAJOR_UNIT) [self.pickerView reloadComponent:1];
    [self updateTapeLabel];
	[self updateCurrentScale];
	
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    bool useCm = true;
    if (self.cmButton.selected==NO) {
        useCm = false;
    }
	if (useCm) {
		switch (component) {
			case MAJOR_UNIT:
				return 20;
				break;
            case MINOR_UNIT:{
                return 100;
            }
				break;
			default:
				return 0;
		}
	} else {
		switch (component) {
			case MAJOR_UNIT:
				return 65;
				break;
			case MINOR_UNIT:
				return 100;
				break;
			default:
				return 0;
		}
	}
}

- (void)setTapeLabel:(NSString*) title{
    [self.buttonTapeValue setTitle:title forState:UIControlStateNormal];
	[self.buttonTapeValue setTitle:title forState:UIControlStateHighlighted];
	[self.buttonTapeValue setTitle:title forState:UIControlStateSelected];
    [self.iPadValueButton setTitle:title forState:UIControlStateNormal];
	[self.iPadValueButton setTitle:title forState:UIControlStateHighlighted];
	[self.iPadValueButton setTitle:title forState:UIControlStateSelected];
}

- (void)updateTapeLabel {
	NSString* majorUnit = @"";
	NSString* minorUnit = @"";
    bool useCm = true;
    if (self.cmButton.selected==NO) {
        useCm = false;
    }
	if (useCm) {
		majorUnit = @".";
		minorUnit = @" m";
	} else {
		majorUnit = @"' ";
		minorUnit = @"\"";
	}
	NSInteger majorScale = [self.pickerView selectedRowInComponent:MAJOR_UNIT];
	if (!useCm) ++majorScale;
	NSInteger minorScale = [self.pickerView selectedRowInComponent:MINOR_UNIT];
	if (majorScale == 0) minorScale += MIN_LENGTH_IN_CM;
	NSString* title = [NSString stringWithFormat:@"%ld%@%02ld%@", (long)majorScale, majorUnit, (long)minorScale, minorUnit];
	[self setTapeLabel:title];
}

- (void)updateCurrentScale {
    bool useCm = YES;
    
    if (self.cmButton.selected==NO) {
        useCm = NO;
    }
    
	float majorScale = [self.pickerView selectedRowInComponent:MAJOR_UNIT];
	if (!useCm)
        majorScale += 1;
	float minorScale = [self.pickerView selectedRowInComponent:MINOR_UNIT];
	if (useCm && majorScale == 0) minorScale += MIN_LENGTH_IN_CM;
	if (!useCm) {
		majorScale *= FEET_IN_METERS;
		minorScale *= INCH_IN_CM;
	}

	float actualSize = majorScale + minorScale * CM_IN_METER;
	currentScale = actualSize / GLKVector3Distance(tapeP1, tapeP2);
    self.worldScale = currentScale;
}

- (void)setMeasuringTapeValue:(float)value animated:(BOOL)animated{

	if (value < MIN_LENGTH_IN_CM * CM_IN_METER) return;
    if (value > MAX_LENGTH_IN_CM * CM_IN_METER){
        value = MAX_LENGTH_IN_CM * CM_IN_METER;
    }
    
    if (value ==NAN) return;
    
    bool useCm = true;
    animated = NO;
    
    if ((self.cmButton.selected==NO)) {
        useCm = false;
    }
    
	if (useCm) {
        int major = truncf(value);
        int minor = roundf((value - truncf(value)) * METER_IN_CM);
        if (minor >= METER_IN_CM) {
            major++;
            minor -= METER_IN_CM;
        }
		[self.pickerView selectRow:major inComponent:MAJOR_UNIT animated:animated];
        [self.pickerView reloadComponent:1];
		if (major == 0) {
			[self.pickerView selectRow:minor-MIN_LENGTH_IN_CM inComponent:MINOR_UNIT animated:animated];
		} else {
			[self.pickerView selectRow:minor inComponent:MINOR_UNIT animated:animated];
		}
	} else {
		float feet = value / FEET_IN_METERS;
        int major = truncf(feet);
        int minor = roundf((feet - truncf(feet))*FEET_IN_INCH);
        if (minor >= FEET_IN_INCH) {
            major++;
            minor -= FEET_IN_INCH;
        }
		[self.pickerView selectRow:major - 1 inComponent:MAJOR_UNIT animated:animated];
		[self.pickerView selectRow:minor inComponent:MINOR_UNIT animated:animated];
	}

	[self updateTapeLabel];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
        
}

- (IBAction)changeMeasureType:(id)sender {
    
    if ([sender isEqual:self.cmButton]) {
        self.cmButton.selected=YES;
        self.fettButton.selected=NO;
    }else{
        self.cmButton.selected=NO;
        self.fettButton.selected=YES;
    }
    
    [self iPadUnitsChanged:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGRect helpFrame = [[HelpManager sharedInstance] frameOfHelpWithKey:@"help_scale"];
    if ((!CGRectIsNull(helpFrame) && CGRectContainsPoint(helpFrame, [gestureRecognizer locationInView:self.view])) ||
        [gestureRecognizer locationInView:self.view].y > self.view.bounds.size.height - ([self isBottomBarVisible] ? self.iPadBottomBar.frame.size.height : 0) ||
        CGRectContainsPoint(self.pickerView.frame, [gestureRecognizer locationInView:self.view])) {
        
        return NO;
    }
    return YES;
}

-(void)tapBackground:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (editValueMode == YES) {
            [self iPadValuePressed:self];
        } else {
            [self toggleBottomBarVisibility];
        }
    }
}

- (void)toggleBottomBarVisibility {
    [self toggleBottomBarVisibility:self.iPadBottomBar];
}

@end




