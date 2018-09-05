//
//  CubeViewController.m
//  CmyCasa


#import "CubeViewController.h"
#import "UIImage+Scale.h"
#import "UIImage+fixOrientation.h"
#import "AppDelegate.h"

#import "MathMacros.h"
#import "UIViewController+Helpers.h"
#import "ControllersFactory.h"
#import "ESOrientationManager.h"

#define WALL_SPEED_FACTOR (60.0f)

#define ROTATIONBUTTONLEFT (1)
#define ROTATIONBUTTONRIGHT (1)

typedef enum {
    NONE = 0,
    LEFT,
    RIGHT,
    BOTTOM
} RotationButtonId;

// defualt cube
static const GLfloat initCube[CUBE_VERTS*COORDS] = {
	-(INITIAL_WIDTH / 2.0f), INITIAL_HEIGHT, INITIAL_FAR_Z + CUBE_DEPTH, // ntl
    (INITIAL_WIDTH / 2.0f), INITIAL_HEIGHT, INITIAL_FAR_Z + CUBE_DEPTH, // ntr
    (INITIAL_WIDTH / 2.0f),  INITIAL_FLOOR, INITIAL_FAR_Z + CUBE_DEPTH, // nbr
	-(INITIAL_WIDTH / 2.0f),  INITIAL_FLOOR, INITIAL_FAR_Z + CUBE_DEPTH, // nbl
	
	-(INITIAL_WIDTH / 2.0f), INITIAL_HEIGHT, INITIAL_FAR_Z, // ftl
    (INITIAL_WIDTH / 2.0f), INITIAL_HEIGHT, INITIAL_FAR_Z, // ftr
    (INITIAL_WIDTH / 2.0f),  INITIAL_FLOOR, INITIAL_FAR_Z, // fbr
	-(INITIAL_WIDTH / 2.0f),  INITIAL_FLOOR, INITIAL_FAR_Z, // fbl
};

@interface CubeViewController ()

// cube rotation handler
- (void)rotateCube:(UIRotationGestureRecognizer*)gesture;
// cube drag handler for walls
- (void)dragWall:(UIPanGestureRecognizer *)gesture;
// Called when the device rotation is changed.
- (void) didRotate:(NSNotification *)notification;
// Returned true of the camera ray directly intersects the wall
- (BOOL)cameraDirectlyIntersectsWall:(WallSide)wall;
@end

@implementation CubeViewController
@synthesize  imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self resetCube];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWall:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    [self.arrowLeftButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWallFromOutside:)]];
    [self.arrowRightButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWallFromOutside:)]];
    [self.arrowBottomButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWallFromOutside:)]];
    [self.arrowUpButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWallFromOutside:)]];
    [self.rotateLeftButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateButtonSlider:)]];
    [self.rotateRightButton addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateButtonSlider:)]];
    [self.rotateLeftButton setTag:LEFT];
    [self.rotateRightButton setTag:RIGHT];
    
	UIRotationGestureRecognizer* rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateCube:)];
	[self.view addGestureRecognizer:rotate];
	    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScreen:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(uploadFinishedNotification:)
												 name:@"UploadFinished"
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(imageAnalysisFinishedNotification:)
												 name:@"ImageAnalysisFinished"
											   object:nil];
	
	measureViewOpen = NO;
    
    self.cubeTextureScale = kCubeWireframeRealWorldSize;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didRotate:nil];
    
    if (measureViewOpen == NO) {
        self.currentDesign = [[[DesignsManager sharedInstance] workingDesign] copy];
        
//        if ([[DesignsManager sharedInstance] workingDesign].GyroData == nil ||
//            [[DesignsManager sharedInstance] workingDesign].CubeVerts == nil) {
//            self.cancelButton.hidden = YES;
//        } else {
//            self.cancelButton.hidden = NO;
//        }
    } else {
        measureViewOpen = NO;
    }
    
    self.imageView.image = self.currentDesign.image;
    self.gyroData = self.currentDesign.GyroData;
    self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
    self.worldScale = self.currentDesign.GlobalScale;
    
    if (!self.currentDesign.CubeVerts)
    {
        if (![ConfigManager isAnyNetworkAvailable])
        {
            [self prepareDefaultCube];
        }
        else
        {
            [self uploadImage];
        }
        
    } else {
        [[HelpManager sharedInstance] presentHelpViewController:@"help_3danalysis" withController:self isForceToShow:YES];
    }
    
    [self glkViewLogic];

    [self reloadCube];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self refreshGLView];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self.view sendSubviewToBack:[appDelegate glkView]];
    [self.view sendSubviewToBack:imageView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	if (measureViewOpen == NO) {
		self.currentDesign = nil;
	}
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)uploadImage
{
    NSString* searchingStr = NSLocalizedString(@"searching_vidible_corners", @"Searching for visible corners");
    [ProgressPopupViewController sharedInstance].lblLoadingCenter.text = searchingStr;
    
    UIImage* image = [self.currentDesign.originalImage scaleToFitLargestSide:640.0];
    
    image = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:self.currentDesign.Orientation];
    image = [image normalizedImage];
    
    if (image != nil) {
        [[ServerUtils sharedInstance] uploadImage:image andParmaters:nil andCallback: @"UploadFinished"];
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        self.iPadBottomBar.hidden = YES;
    }
}

- (void)uploadFinishedNotification:(NSNotification *)notification
{
	BOOL isSuccess;
    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];
    
    if (isSuccess) {
        NSString* strURL = [[notification userInfo] objectForKey:@"responseString"];
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        
        //we send empty matrix - server dont need it
        [[ServerUtils sharedInstance] serverImageAnalysis:GLKMatrix3Make(0, 0, 0, 0, 0, 0, 0, 0, 0)
                                              focalLength:[[DesignsManager sharedInstance] workingDesign].FocalLengthIn35mmFilm
                                              strImageURL:strURL];
    } else { // show default cube
        [[ProgressPopupBaseViewController sharedInstance] reset];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        [self alertImageAnalysisError];
	}
}

- (void)prepareDefaultCube
{
    if (self.currentDesign.GyroData == nil) {
        self.currentDesign.GyroData = [[SavedGyroData alloc] initWithRotationMatrix:GLKMatrix3Identity withModMatrix:GLKMatrix4MakeRotation(M_PI_2, 0, 0, 1)];
    }
    self.gyroData = self.currentDesign.GyroData;
    self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
    [self resetCube];
    [self reloadCube];
}

- (void)imageAnalysisFinishedNotification:(NSNotification *)notification
{
    //ImageAnalysisFinished
    [[ProgressPopupBaseViewController sharedInstance] reset];
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    
	BOOL isSuccess;
    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];
    
    if (isSuccess) {
		NSDictionary* data = [[notification userInfo] objectForKey:@"jsonData"];
		if ([data objectForKey:@"Error"] == nil) {
            UIImage* frontImage = self.currentDesign.image;
            //old
			self.currentDesign = [SavedDesign initWithParams:self.currentDesign.originalImage ImageOrientation:self.currentDesign.Orientation JSON:data];
            NSDictionary * jsonData = [self.currentDesign jsonData];
            SavedDesign * design = [SavedDesign designWithJSONDictionary:jsonData];
            
            self.currentDesign.camera = design.camera;
            self.currentDesign.GyroData = design.GyroData;
            self.currentDesign.image = frontImage;
			self.gyroData = self.currentDesign.GyroData;
			self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
            
        } else { // Use default cube and default orientation
            [self resetCubeToDefault:self];
            [self defaultCube];
		}
        [self onFinishImageAnalysis];
    } else {
        [self alertImageAnalysisError];
    }
}

- (void)alertImageAnalysisError
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"progress_label_err_network", @"Network Error") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_retry", @"Retry") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self uploadImage];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Use default cube and default orientation
        [self resetCubeToDefault:self];
        [self defaultCube];
        [self onFinishImageAnalysis];
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onFinishImageAnalysis
{
    self.iPadBottomBar.hidden = NO;
    
    [self reloadCube];
    
    // TODO (Avihay): Move the pause/resume renderer function from FurnitureVC to base class
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.glkVC setPaused:NO];
    
    [[HelpManager sharedInstance] presentHelpViewController:@"help_3danalysis" withController:self isForceToShow:YES];
}

-(void)defaultCube{
    self.currentDesign.GyroData = [[SavedGyroData alloc] initWithRotationMatrix:GLKMatrix3Identity withModMatrix:GLKMatrix4MakeRotation(M_PI_2, 0, 0, 1)];
    self.gyroData = self.currentDesign.GyroData;
    self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
}

- (void) didRotate:(NSNotification *)notification
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIDeviceOrientation orientation = [appDelegate getSavedDesignOrientation];
    CGRect screenRect = [UIScreen currentScreenBoundsDependOnOrientation];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    CGAffineTransform arrowUp = CGAffineTransformMakeRotation(-M_PI_2);
    CGAffineTransform arrowDown = CGAffineTransformMakeRotation(M_PI_2);
    CGAffineTransform arrowLeft = CGAffineTransformMakeRotation(M_PI);
    CGAffineTransform arrowRight = CGAffineTransformMakeRotation(0);
  
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight:
        case UIDeviceOrientationLandscapeLeft:
        {
				CGAffineTransform tr = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
                self.iPadBottomBar.transform = tr;
                self.iPadBottomBar.center = CGPointMake(screenWidth/2, self.view.bounds.size.height - self.iPadBottomBar.bounds.size.height/2);
                self.rotateLeftButton.transform = tr;
                self.rotateRightButton.transform = tr;
                self.dragCeilingButton.transform = tr;
                self.dragFloorButton.transform = tr;
                self.dragFrontWallButton.transform = tr;
                self.dragLeftWallButton.transform = tr;
                self.dragRightWallButton.transform = tr;
                self.arrowBottomButton.transform = CGAffineTransformConcat(tr, arrowDown);
                self.arrowUpButton.transform = CGAffineTransformConcat(tr, arrowUp);
                self.arrowRightButton.transform = CGAffineTransformConcat(tr, arrowRight);
                self.arrowLeftButton.transform = CGAffineTransformConcat(tr, arrowLeft);
                
                self.arrowLeftButton.center = CGPointMake(self.arrowLeftButton.bounds.size.width/2, (screenHeight + self.iPadBottomBar.bounds.size.height)/2);
                self.arrowRightButton.center = CGPointMake(screenWidth - self.arrowRightButton.bounds.size.width/2, (screenHeight + self.iPadBottomBar.bounds.size.height)/2);
                self.arrowUpButton.center = CGPointMake(screenWidth / 2, self.arrowUpButton.bounds.size.width/2);
                self.arrowBottomButton.center = CGPointMake(screenWidth / 2, screenHeight - self.arrowBottomButton.bounds.size.width/2 - self.iPadBottomBar.bounds.size.height);
        }
             break;
                        
        case UIDeviceOrientationPortrait:
        {
                CGAffineTransform tr = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
                self.iPadBottomBar.transform = tr;
                self.iPadBottomBar.center = CGPointMake(screenHeight/2, screenWidth - self.iPadBottomBar.bounds.size.height/2);
                self.rotateLeftButton.transform = tr;
                self.rotateRightButton.transform = tr;
                self.dragCeilingButton.transform = tr;
                self.dragFloorButton.transform = tr;
                self.dragFrontWallButton.transform = tr;
                self.dragLeftWallButton.transform = tr;
                self.dragRightWallButton.transform = tr;
                self.arrowBottomButton.transform = CGAffineTransformConcat(tr, arrowDown);
                self.arrowUpButton.transform = CGAffineTransformConcat(tr, arrowUp);
                self.arrowRightButton.transform = CGAffineTransformConcat(tr, arrowRight);
                self.arrowLeftButton.transform = CGAffineTransformConcat(tr, arrowLeft);
                self.arrowLeftButton.center = CGPointMake(screenHeight - self.arrowLeftButton.bounds.size.width/2, screenWidth / 2);
                self.arrowRightButton.center = CGPointMake(self.arrowRightButton.bounds.size.width/2, screenWidth / 2);
                self.arrowUpButton.center = CGPointMake(screenHeight/2, self.arrowUpButton.bounds.size.width/2);
                self.arrowBottomButton.center = CGPointMake(screenHeight/2, screenWidth - self.arrowBottomButton.bounds.size.width/2);
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        {
				CGAffineTransform tr = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
                self.iPadBottomBar.transform = tr;
                self.iPadBottomBar.center = CGPointMake(screenHeight/2, self.iPadBottomBar.bounds.size.height/2);
                self.rotateLeftButton.transform = tr;
                self.rotateRightButton.transform = tr;
                self.dragCeilingButton.transform = tr;
                self.dragFloorButton.transform = tr;
                self.dragFrontWallButton.transform = tr;
                self.dragLeftWallButton.transform = tr;
                self.dragRightWallButton.transform = tr;
                self.arrowBottomButton.transform = CGAffineTransformConcat(tr, arrowDown);
                self.arrowUpButton.transform = CGAffineTransformConcat(tr, arrowUp);
                self.arrowRightButton.transform = CGAffineTransformConcat(tr, arrowRight);
                self.arrowLeftButton.transform = CGAffineTransformConcat(tr, arrowLeft);
                self.arrowLeftButton.center = CGPointMake(self.arrowLeftButton.bounds.size.width/2, screenWidth / 2);
                self.arrowRightButton.center = CGPointMake(screenHeight - self.arrowRightButton.bounds.size.width/2, screenWidth / 2);
                self.arrowUpButton.center = CGPointMake(screenHeight/2, screenWidth - self.arrowUpButton.bounds.size.width/2);
                self.arrowBottomButton.center = CGPointMake(screenHeight/2, self.arrowBottomButton.bounds.size.width/2);
            break;
        }
            
        default:
            break;
    }
}

#pragma mark GLKViewControllerDelegate
// Setup perspective, update wirefram, and set the controlls accordingly.
- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    [self glkViewLogic];
}

-(void)glkViewLogic{
    [super glkViewLogic];
    
    self.wallsTransparency = 0.375;
    // Hide the controlls when the wireframe is hidden
    self.dragRightWallButton.hidden = self.wireframeHidden;
    self.dragLeftWallButton.hidden = self.wireframeHidden;
    self.dragFrontWallButton.hidden = self.wireframeHidden;
    self.dragFloorButton.hidden = self.wireframeHidden;
    self.dragCeilingButton.hidden = self.wireframeHidden;
    self.rotateLeftButton.hidden = self.wireframeHidden;
    self.rotateRightButton.hidden = self.wireframeHidden;
    self.arrowLeftButton.hidden = self.wireframeHidden;
    self.arrowRightButton.hidden = self.wireframeHidden;
    self.arrowUpButton.hidden = self.wireframeHidden;
    self.arrowBottomButton.hidden = self.wireframeHidden;
    
    if (!self.wireframeHidden) {
        CGPoint pTopLeft = [self getPointForVertex:4];
        CGPoint pTopRight = [self getPointForVertex:5];
        CGPoint pBottomRight = [self getPointForVertex:6];
        CGPoint pBottomLeft = [self getPointForVertex:7];
        
        if ([self.view pointInside:pTopLeft withEvent:nil] == NO) {
            
            pTopLeft = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:7] end:[self getVectorForVertex:4] withScreen:ScreenEdgeTop]];
        }
        
        if ([self.view pointInside:pBottomLeft withEvent:nil] == NO) {
            pBottomLeft = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:7] end:[self getVectorForVertex:4] withScreen:ScreenEdgeBottom]];
        }
        
        if ([self.view pointInside:pTopRight withEvent:nil] == NO) {
            pTopRight = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:6] end:[self getVectorForVertex:5] withScreen:ScreenEdgeTop]];
        }
        
        if ([self.view pointInside:pBottomRight withEvent:nil] == NO) {
            pBottomRight = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:6] end:[self getVectorForVertex:5] withScreen:ScreenEdgeBottom]];
        }
        
        if (isnan(pTopLeft.x) || isnan(pTopLeft.y) || isnan(pTopRight.x) || isnan(pTopRight.y) ||
            isnan(pBottomRight.x) || isnan(pBottomRight.y) || isnan(pBottomLeft.x) || isnan(pBottomLeft.y)) {
            NSAssert(NO, @"Rotation button position in cubeview is wrong");
            return;
        }
        
        self.rotateLeftButton.center = pointAverage(pBottomLeft, pTopLeft);
        self.rotateLeftButton.hidden = !CGRectContainsRect(self.view.bounds, self.rotateLeftButton.frame);
        
        self.rotateRightButton.center = pointAverage(pBottomRight, pTopRight);
        self.rotateRightButton.hidden = !CGRectContainsRect(self.view.bounds, self.rotateRightButton.frame);
        self.arrowLeftButton.hidden = [self getPointForVertex:4].x > 40 || [self getPointForVertex:7].x > 40;
        self.arrowRightButton.hidden = [self getPointForVertex:5].x < self.view.bounds.size.width - 40 || [self getPointForVertex:6].x < self.view.bounds.size.width - 40;
        self.arrowBottomButton.hidden = [self getPointForVertex:7].y < self.view.bounds.size.height - 80 || [self getPointForVertex:6].y < self.view.bounds.size.height - 80;
        self.arrowUpButton.hidden = [self getPointForVertex:4].y > 40 || [self getPointForVertex:5].y > 40;
        
        
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        //   Haven't changed the orientation of screen edges right!! //
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////
        
        
        
        CGPoint pBottomLeftFar, pBottomRightFar, pTopLeftFar, pTopRightFar;
        pBottomLeftFar = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:7] end:[self getVectorForVertex:3] withScreen:ScreenEdgeTop]];
        if ([self.view pointInside:pBottomLeftFar withEvent:nil] == NO) {
            pBottomLeftFar = CGPointMake(0, 0);
        }
        pBottomRightFar = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:6] end:[self getVectorForVertex:2] withScreen:ScreenEdgeBottom]];
        if ([self.view pointInside:pBottomRightFar withEvent:nil] == NO) {
            pBottomRightFar = CGPointMake(0, self.view.bounds.size.height);
        }
        pTopLeftFar = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:4] end:[self getVectorForVertex:0] withScreen:ScreenEdgeTop]];
        if ([self.view pointInside:pTopLeftFar withEvent:nil] == NO) {
            pTopLeftFar = CGPointMake(self.view.bounds.size.width, 0);
        }
        pTopRightFar = [self getPointForVector:[self findEdgeOfLineStartingAt:[self getVectorForVertex:5] end:[self getVectorForVertex:1] withScreen:ScreenEdgeBottom]];
        if ([self.view pointInside:pTopRightFar withEvent:nil] == NO) {
            pTopRightFar = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height);
        }
        
        self.dragFrontWallButton.center = pointAverage(pointAverage(pTopLeft, pTopRight), pointAverage(pBottomLeft, pBottomRight));
        self.dragLeftWallButton.center = pointAverage(pointAverage(pTopLeft, pBottomLeft), pointAverage(pTopLeftFar, pBottomLeftFar));
        self.dragRightWallButton.center = pointAverage(pointAverage(pTopRight, pBottomRight), pointAverage(pTopRightFar, pBottomRightFar));
        self.dragFloorButton.center = pointAverage(pointAverage(pBottomLeft, pBottomRight), pointAverage(pBottomLeftFar, pBottomRightFar));
        self.dragCeilingButton.center = pointAverage(pointAverage(pTopLeft, pTopRight), pointAverage(pTopLeftFar, pTopRightFar));
        
        self.dragCeilingButton.hidden = YES;
        self.dragFloorButton.hidden = YES;
        self.dragRightWallButton.hidden = YES;
        self.dragLeftWallButton.hidden = YES;
        self.dragFrontWallButton.hidden = YES;
    }
}

#pragma mark UI
- (void)singleTapScreen:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self toggleBottomBarVisibility:self.iPadBottomBar];
    }
}

- (void)rotateButtonSlider:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        ((UIButton*)gesture.view).selected = YES;
    }
    
    NSInteger rotationButtonId = ([(UIButton*)gesture.view tag]);
    float amount=0;
    switch(rotationButtonId){
        case BOTTOM:
            amount = [gesture translationInView:gesture.view].y/250;
            break;
        case LEFT:
        case RIGHT:
        case NONE:
            amount = -[gesture translationInView:gesture.view].x/250;
            break;
            
    }
    
    [self rotateCubeBy:amount
            atLocation:gesture.view.center gestureState:gesture.state
            withRotationButton:(int)rotationButtonId];
    
    [gesture setTranslation:CGPointZero inView:gesture.view];
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        ((UIButton*)gesture.view).selected = NO;
    }
}

- (void)rotateCubeBy:(float)rotation atLocation:(CGPoint)location gestureState:(UIGestureRecognizerState)state withRotationButton:(RotationButtonId)rotationButtonId {
    static bool cameraAlreadyOutside = false;
    
    int pivotIdx = -1;
         
    // when using gesture rotation, we need to estimate the closest button to the gesture
    if (rotationButtonId == NONE) {
        // Pick the pivot to be one of the visible corners (else use the camera as the pivot).
        CGPoint p = location;
        GLKVector3 v = [self findIntersectionOfPoint:p withPlaneAtPoint:[self getVectorForVertex:4] withNormal:GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]))];
        
        GLKVector3 pBottomLeft = [self getVectorForVertex:7];
        GLKVector3 pTopLeft = [self getVectorForVertex:4];
        float distanceLeft = distanceBetweenPointAndLine(v, pBottomLeft, pTopLeft);
        
        GLKVector3 pBottomRight = [self getVectorForVertex:6];
        GLKVector3 pTopRight = [self getVectorForVertex:5];
        float distanceRight = distanceBetweenPointAndLine(v, pBottomRight, pTopRight);
        
        if (distanceLeft < distanceRight) {
            pivotIdx = 7;
        } else {
            pivotIdx = 6;
        }
    }
    
    // make sure PI > rotation > -PI, for applying the correct rotation speed factor
    while (rotation > M_PI) rotation -= 2 * M_PI;
    while (rotation < -M_PI) rotation += 2 * M_PI;
    
    GLKVector3 rotationPlane = GLKVector3Make(0, 1, 0);
    GLKVector3 pivot  = GLKVector3Make(0, 1, 0);
                  
    switch(rotationButtonId){
        case NONE:
            pivot = [self getVectorForVertex:pivotIdx];
            rotationPlane = GLKVector3Make(0, 1, 0);
            break;
        case LEFT:
            rotationPlane = GLKVector3Make(0, 1, 0);
            pivot = [self getVectorForVertex:7];
            break;
        case RIGHT:
            rotationPlane = GLKVector3Make(0, 1, 0);
            pivot = [self getVectorForVertex:6];
            break;
        case BOTTOM:
            rotationPlane = GLKVector3Subtract([self getVectorForVertex:7], [self getVectorForVertex:6]);
            pivot = [self getVectorForVertex:6];
            break;
    }
         
    GLKMatrix4 rot = GLKMatrix4MakeRotation(- rotation / 2, rotationPlane.x,
                                            rotationPlane.y,rotationPlane.z);
         
	GLKMatrix4 toPivot = GLKMatrix4MakeTranslation(pivot.x, pivot.y, pivot.z);
	GLKMatrix4 fromPivot = GLKMatrix4MakeTranslation(-pivot.x, -pivot.y, -pivot.z);
	
	GLKMatrix4 matrix = GLKMatrix4Multiply(toPivot, GLKMatrix4Multiply(rot, fromPivot));
	
	for (int i=0; i < CUBE_VERTS; i++) {
		GLKVector3 v = [self getVectorForVertex:i];
		v = GLKMatrix4MultiplyVector3WithTranslation(matrix, v);
		[self setVector:v forVertex:i];
	}
    if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
        bool invertible;
        matrix = GLKMatrix4Invert(matrix, &invertible);
        if (!invertible) {
            rot = GLKMatrix4MakeRotation(rotation / 2, 0, 1, 0);
            matrix = GLKMatrix4Multiply(toPivot, GLKMatrix4Multiply(rot, fromPivot));
        }
        for (int i=0; i < CUBE_VERTS; i++) {
            GLKVector3 v = [self getVectorForVertex:i];
            v = GLKMatrix4MultiplyVector3WithTranslation(matrix, v);
            [self setVector:v forVertex:i];
        }
    }
}

- (void)rotateCube:(UIRotationGestureRecognizer*)gesture {
    [self rotateCubeBy:gesture.rotation atLocation:[gesture locationInView:self.view] gestureState:gesture.state
    withRotationButton:NONE];
    [gesture setRotation:0];
}

- (void)dragWall:(UIPanGestureRecognizer *)gesture overrideWall:(WallSide)currentWall {
    static bool cameraAlreadyOutside = false;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        cameraAlreadyOutside = ![self isCameraInsideCube];
    }

    CGPoint translation = [gesture translationInView:self.view];
	GLKVector3 diff, cubeDir, oldPoint;
    GLKVector2 dir;
	switch (currentWall) {
        case WallLeft:
            cubeDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:1], [self getVectorForVertex:0]));
            oldPoint = [self getVectorForVertex:7];
            dir = GLKVector2Normalize(GLKVector2Make(cubeDir.x, cubeDir.z));
            diff = GLKVector3MultiplyScalar(cubeDir, (fabsf(oldPoint.z) / 5.0f) * (GLKVector2DotProduct(vecFromPoint(translation), dir)) / WALL_SPEED_FACTOR);
			
			// Update the vertices
			[self translateVertex:7 withVector:diff];
			[self translateVertex:0 withVector:diff];
			[self translateVertex:3 withVector:diff];
			[self translateVertex:4 withVector:diff];
            if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
                diff = GLKVector3Negate(diff);
                [self translateVertex:7 withVector:diff];
                [self translateVertex:0 withVector:diff];
                [self translateVertex:3 withVector:diff];
                [self translateVertex:4 withVector:diff];
            }
			break;
		case WallFront: // Similar to above
			cubeDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]));
            if ([self.view pointInside:[self getPointForVertex:7] withEvent:nil] && ![self.view pointInside:[self getPointForVertex:6] withEvent:nil]) {
                oldPoint = [self getVectorForVertex:7];
            } else if (![self.view pointInside:[self getPointForVertex:7] withEvent:nil] && [self.view pointInside:[self getPointForVertex:6] withEvent:nil]) {
                oldPoint = [self getVectorForVertex:6];
            } else {
                oldPoint = GLKVector3DivideScalar(GLKVector3Add([self getVectorForVertex:6], [self getVectorForVertex:7]), 2);
            }
            dir = GLKVector2Normalize(GLKVector2Make(cubeDir.x, cubeDir.z));
            diff = GLKVector3MultiplyScalar(cubeDir, (fabsf(oldPoint.z) / 5.0f) * (GLKVector2DotProduct(vecFromPoint(translation), dir)) / WALL_SPEED_FACTOR);
            
			[self translateVertex:4 withVector:diff];
			[self translateVertex:5 withVector:diff];
			[self translateVertex:6 withVector:diff];
			[self translateVertex:7 withVector:diff];
            if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
                diff = GLKVector3Negate(diff);
                [self translateVertex:4 withVector:diff];
                [self translateVertex:5 withVector:diff];
                [self translateVertex:6 withVector:diff];
                [self translateVertex:7 withVector:diff];
            }
			break;
		case WallRight:
			// Find the direction of movement in 3D world
			cubeDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:1]));
            oldPoint = [self getVectorForVertex:6];
            
            dir = GLKVector2Normalize(GLKVector2Make(cubeDir.x, cubeDir.z));
            diff = GLKVector3MultiplyScalar(cubeDir, (fabsf(oldPoint.z) / 5.0f) * (GLKVector2DotProduct(vecFromPoint(translation), dir)) / WALL_SPEED_FACTOR);
			
			[self translateVertex:6 withVector:diff];
			[self translateVertex:1 withVector:diff];
			[self translateVertex:2 withVector:diff];
			[self translateVertex:5 withVector:diff];
            if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
                diff = GLKVector3Negate(diff);
                [self translateVertex:6 withVector:diff];
                [self translateVertex:1 withVector:diff];
                [self translateVertex:2 withVector:diff];
                [self translateVertex:5 withVector:diff];
            }
			break;
        case WallFloor:
            cubeDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:3]));
            oldPoint = [self getVectorForVertex:6];
            
            diff = GLKVector3MultiplyScalar(cubeDir, -(fabsf(oldPoint.z) / 5.0f) * translation.y / WALL_SPEED_FACTOR);
            [self translateVertex:2 withVector:diff];
            [self translateVertex:3 withVector:diff];
            [self translateVertex:6 withVector:diff];
            [self translateVertex:7 withVector:diff];
            
            if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
                diff = GLKVector3Negate(diff);
                [self translateVertex:2 withVector:diff];
                [self translateVertex:3 withVector:diff];
                [self translateVertex:6 withVector:diff];
                [self translateVertex:7 withVector:diff];
            }
            break;
        case WallCeilling:
            cubeDir = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:3], [self getVectorForVertex:0]));
            oldPoint = [self getVectorForVertex:6];
            
            diff = GLKVector3MultiplyScalar(cubeDir, (fabsf(oldPoint.z) / 5.0f) * translation.y / WALL_SPEED_FACTOR);
            [self translateVertex:0 withVector:diff];
            [self translateVertex:1 withVector:diff];
            [self translateVertex:4 withVector:diff];
            [self translateVertex:5 withVector:diff];
            
            if (cameraAlreadyOutside == NO && [self isCameraInsideCube] == NO) {
                diff = GLKVector3Negate(diff);
                [self translateVertex:0 withVector:diff];
                [self translateVertex:1 withVector:diff];
                [self translateVertex:4 withVector:diff];
                [self translateVertex:5 withVector:diff];
            }
            
            break;
		default:
			break;
	}
	
	// reset translation
	[gesture setTranslation:CGPointZero inView:self.view];
}

- (void)dragWall:(UIPanGestureRecognizer *)gesture {
    static WallSide currentWall = WallNone;
    if (gesture.state == UIGestureRecognizerStateBegan) {        
        currentWall = [self wallAtIntersectionOfPoint:[gesture locationInView:self.view]];
    }
    [self dragWall:gesture overrideWall:currentWall];
}

- (void)dragWallFromOutside:(UIPanGestureRecognizer*)gesture {
    if (gesture.view == self.arrowBottomButton) {
        [self dragWall:gesture overrideWall:WallFloor];
    } else if (gesture.view == self.arrowUpButton) {
        [self dragWall:gesture overrideWall:WallCeilling];
    } else if (gesture.view == self.arrowRightButton) {
        [self dragWall:gesture overrideWall:WallRight];
    } else if (gesture.view == self.arrowLeftButton) {
        [self dragWall:gesture overrideWall:WallLeft];
    }
}

// Update the global design
- (void)donePressed:(id)sender {
	if (sender == _measureViewController) {
        
        [_measureViewController dismissViewControllerAnimated:YES completion:^{
            _measureViewController.delegate = nil;
            _measureViewController = nil;
            
            self.currentDesign.CubeVerts = self.cubeNSArray;
            self.currentDesign.FormatVersion = [DesignsManager sharedInstance].workingDesign.FormatVersion;
            [DesignsManager sharedInstance].workingDesign = self.currentDesign;
            
            [[DesignsManager sharedInstance] startAutoSave];
            
            if ([self.delegate respondsToSelector:@selector(donePressed:)]) {
                [self.delegate donePressed:nil];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
	} else {
		measureViewOpen = NO;
	}
}

// Cancel the changes made to the design
- (IBAction)cancelPressed:(id)sender
{
 	if (_measureViewController != nil && sender == _measureViewController){
        [_measureViewController dismissViewControllerAnimated:YES completion:nil];
        _measureViewController.delegate = nil;
        _measureViewController = nil;
	}else{
		measureViewOpen = NO;
        [self resetCube];
        
        if ([self.delegate respondsToSelector:@selector(cancelPressed:)]) {
            [self.delegate cancelPressed:nil];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)nextPressed:(id)sender
{
    [self performAdjustScale];
}

// Reset the cube to original state before cube modification, or of the previous state is undefined, use the default cube.
- (void)resetCube {
 	if ([[DesignsManager sharedInstance] workingDesign].CubeVerts == nil) {
		[self setDefaultCube:self];
	} else {
        self.cubeNSArray = [[DesignsManager sharedInstance] workingDesign].CubeVerts;
	}
}

- (void)setDefaultCube:(id)sender {
    NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:CUBE_VERTS * COORDS];
    for (int i = 0; i < CUBE_VERTS * COORDS; i++) {
        [temp addObject:[NSNumber numberWithFloat:initCube[i]]];
    }
    self.currentDesign.CubeVerts = [temp copy];
    [self reloadCube];
}

- (void)resetCubeAndGyro {
    [[DesignsManager sharedInstance] workingDesign].GyroData = nil;
   
    [self resetCubeToDefault:self];
}

- (IBAction)resetCubeToDefault:(id)sender {
	if ([[DesignsManager sharedInstance] workingDesign].GyroData == nil) {
        [self setDefaultCube:self];
        GLKMatrix3 orientationMatrix = GLKMatrix3Identity;
        switch ([[DesignsManager sharedInstance] workingDesign].Orientation) {
            case UIImageOrientationRight:
                orientationMatrix = GLKMatrix3Identity;
                break;
            case UIImageOrientationLeft:
                orientationMatrix = GLKMatrix3MakeRotation(M_PI, 0, 0, 1);
                break;
            case UIImageOrientationUp:
                orientationMatrix = GLKMatrix3MakeRotation(-M_PI_2, 0, 0, 1);
                break;
            case UIImageOrientationDown:
                orientationMatrix = GLKMatrix3MakeRotation(M_PI_2, 0, 0, 1);
                break;
            default:
                orientationMatrix = GLKMatrix3Identity;
                break;
        }
		self.currentDesign.GyroData = [[SavedGyroData alloc] initWithCameraMatrix:orientationMatrix];
		self.gyroData = self.currentDesign.GyroData;
		self.camera.fovVertical = [self.currentDesign fovForScreenSize:self.view.bounds.size];
	} else {
		[self setDefaultCube:self];
	}
}

- (void)performAdjustScale {
	//fix crash for duplicate adjust scale action
    if ([_measureViewController isModal]) {
        return;
    }
    measureViewOpen = YES;
    
    self.currentDesign.CubeVerts = self.cubeNSArray;
    
    if (!_measureViewController) {
        _measureViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"MeasureViewController" inStoryboard:kRedesignStoryboard];
        _measureViewController.delegate = self;
    }
    
	_measureViewController.currentDesign = self.currentDesign;

    [_measureViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
   
    [self presentViewController:_measureViewController animated:YES completion:nil];
}

- (BOOL)point:(CGPoint)p directlyIntersectsWall:(WallSide)wall {
    // Cube's sides
    GLKVector3 floorPoint = [self getVectorForVertex:7];
    GLKVector3 floorNormal = GLKVector3Make(0, 1, 0);
    GLKVector3 ceilingPoint = [self getVectorForVertex:4];
    GLKVector3 ceilingNormal = GLKVector3Make(0, -1, 0);
    GLKVector3 frontPoint = ceilingPoint;
    GLKVector3 frontNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:0], [self getVectorForVertex:4]));
    GLKVector3 leftPoint = ceilingPoint;
    GLKVector3 leftNormal = GLKVector3Normalize(GLKVector3Subtract([self getVectorForVertex:5], [self getVectorForVertex:4]));
    GLKVector3 rightPoint = [self getVectorForVertex:5];
    GLKVector3 rightNormal = GLKVector3Negate(leftNormal);
    
    GLKVector3 planePoint, planeNormal;
    switch (wall) {
        case WallFront:
            planePoint = frontPoint;
            planeNormal = frontNormal;
            break;
        case WallLeft:
            planePoint = leftPoint;
            planeNormal = leftNormal;
            break;
        case WallRight:
            planePoint = rightPoint;
            planeNormal = rightNormal;
            break;
        case WallFloor:
            planePoint = floorPoint;
            planeNormal = floorNormal;
            break;
        case WallCeilling:
            planePoint = ceilingPoint;
            planeNormal = ceilingNormal;
            break;
        default:
            return NO;
            break;
    }
    GLKVector3 point = [self findIntersectionOfPoint:p
                                    withPlaneAtPoint:planePoint withNormal:planeNormal];
    bool t = point.z  < 0;
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, frontPoint), frontNormal) >= -EPSILON; // Before front
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, leftPoint), leftNormal) >= -EPSILON; // Object is right to the left wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, rightPoint), rightNormal) >= -EPSILON; // Object is left to the right wall.
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, ceilingPoint), ceilingNormal) >= -EPSILON; // Object is below ceiling
    t = t && GLKVector3DotProduct(GLKVector3Subtract(point, floorPoint), floorNormal) >= -EPSILON; // object is above floor
    return t;
}

- (WallSide)wallAtIntersectionOfPoint:(CGPoint)p {
    if ([self point:p directlyIntersectsWall:WallFront]) return WallFront;
    if ([self point:p directlyIntersectsWall:WallLeft])  return WallLeft;
    if ([self point:p directlyIntersectsWall:WallRight])  return WallRight;
    if ([self point:p directlyIntersectsWall:WallCeilling])  return WallCeilling;
    if ([self point:p directlyIntersectsWall:WallFloor])  return WallFloor;
    return WallNone;
}

- (BOOL)cameraDirectlyIntersectsWall:(WallSide)wall {
    return [self point:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2) directlyIntersectsWall:wall];
}

- (BOOL)isCameraInsideCube {
    int wallCount = 0;
    if ([self cameraDirectlyIntersectsWall:WallFront]) wallCount++;
    if ([self cameraDirectlyIntersectsWall:WallLeft]) wallCount++;
    if ([self cameraDirectlyIntersectsWall:WallRight]) wallCount++;
    if ([self cameraDirectlyIntersectsWall:WallCeilling]) wallCount++;
    if ([self cameraDirectlyIntersectsWall:WallFloor]) wallCount++;
    return wallCount == 1;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGRect helpFrame = [[HelpManager sharedInstance] frameOfHelpWithKey:@"help_3danalysis"];
    if ((!CGRectIsNull(helpFrame) && CGRectContainsPoint(helpFrame, [gestureRecognizer locationInView:self.view])) ||
        [gestureRecognizer locationInView:self.view].y > self.view.bounds.size.height - ([self isBottomBarVisible] ? self.iPadBottomBar.frame.size.height : 0)) {
        return NO;
    }
    return YES;
}
@end
