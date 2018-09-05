//
//  General3DViewController.m
//  CmyCasa
//
//  Created by Or Sharir on 11/11/12.
//
//

#import "General3DViewController.h"
#import "MathMacros.h"
#import "AppDelegate.h"

@interface General3DViewController ()
{
    UIView* _bottomBar;
    CGRect _originalBottomFrame;
    BOOL _isBottomBarVisible;
}
@end

@implementation General3DViewController
@synthesize gyroData, cameraHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.worldScale = 1;
        self.camera = [[SimpleCamera alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.worldScale = 1;
        self.camera = [[SimpleCamera alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_FALSE;
    self.gyroData = nil;
    self.cameraHeight = CAMERA_DEFAULT_HEIGHT;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateProjection];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate glkView].frame = self.view.bounds;
    [appDelegate setDrawableMultisample];
}

-(void)viewDidDisappear:(BOOL)animated {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate glkVC].delegate == self) {
        [appDelegate glkVC].delegate = nil;
    }
    if ([appDelegate glkView].delegate == self) {
        [appDelegate glkView].delegate = nil;
    }
    if ([[appDelegate glkView] superview] == self.view) {
        [[appDelegate glkView] removeFromSuperview];
    }
    [super viewDidDisappear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate glkVC].delegate == self) {
        [appDelegate glkVC].delegate = nil;
    }
    if ([appDelegate glkView].delegate == self) {
        [appDelegate glkView].delegate = nil;
    }
    
    self.gyroData = nil;
    self.camera = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateCamera
{
    // If we got the physical position of the device, then setup the camera accordinly.
    if (self.gyroData != nil)
    {
        [self.camera setupWithRotationMatrixAndGravity:self.gyroData.gyroRotationMatrix
                                               gravity:self.gyroData.gravity];
        [self.camera setCameraHeight:-self.cameraHeight];
    }
    else
    {
        [self.camera setCameraHeight:-CAMERA_DEFAULT_HEIGHT];
    }
}

-(void)updateProjection
{
    // Projection setup
    GLfloat ratio = self.view.bounds.size.width / self.view.bounds.size.height;
    [self updateProjectionWithRatio:ratio];
}

-(void)updateProjectionWithRatio:(GLfloat)ratio
{
    // Projection setup
    self.camera.aspectRatio = ratio;
    self.effect.transform.projectionMatrix = [self.camera projectionMatrix];
}

-(void)glkViewControllerUpdate:(GLKViewController *)controller {
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
}

// Keep the camera updsynchornizedate with the gyro data
-(void)setGyroData:(SavedGyroData *)newGyroData
{
    gyroData = newGyroData;
    
    //update camera only if newGyroData exist
    if (newGyroData) {
        [self updateCamera];
    }
}

// Keep the perspective synchornized with the FOV
-(void)setFov:(float)newFov
{
    self.camera.fovVertical = newFov;
    [self updateProjection];
}

-(void)setCameraHeight:(float)newCameraHeight
{
    if (newCameraHeight != cameraHeight) {
        cameraHeight = newCameraHeight;
        [self updateCamera];
    }
}

#pragma mark 3D Helpers

- (CGPoint)getPointForVector:(GLKVector3)vector {
	return pointFromVec([self getVector2ProjectionOfVector:vector]);
}

- (GLKVector2)getVector2ProjectionOfVector:(GLKVector3)vector {
    GLKVector3 p = [self projectPointForVector:vector];
	return GLKVector2Make(p.x, self.view.bounds.size.height - p.y);
}

- (GLKVector3)projectPointForVector:(GLKVector3)vector
{
    int viewport[4] = {self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height};
	return GLKMathProject(vector, [self.camera cameraMatrix], [self.camera projectionMatrix], viewport);
}

- (GLKVector3)unprojectPoint:(CGPoint)point withDepth:(float)z {
	return [self unprojectVector:GLKVector3Make(point.x, self.view.bounds.size.height - point.y, z)];
}

- (GLKVector3)unprojectVector:(GLKVector3)point {
    int viewport[4] = {self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height};
    bool success = NO;
	return GLKMathUnproject(point, [self.camera cameraMatrix], [self.camera projectionMatrix], viewport, &success);
}

- (GLKVector3)findVectorForRay:(CGPoint)point atDepth:(float)s {    
    GLKVector3 p0 = [self unprojectPoint:point withDepth:0];
	GLKVector3 p1 = [self unprojectPoint:point withDepth:1];
    return GLKVector3Add(p0, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3Subtract(p1, p0)), s));
}

- (GLKVector3)findIntersectionOfPoint:(CGPoint)point withPlaneAtPoint:(GLKVector3)v0 withNormal:(GLKVector3)n {
	GLKVector3 p0 = [self unprojectPoint:point withDepth:0];
	GLKVector3 p1 = [self unprojectPoint:point withDepth:1];
	return [self findIntersectionOfLineStartingAt:p0 ending:p1 withPlaneAtPoint:v0 withNormal:n];
}

- (GLKVector3)findIntersectionOfLineStartingAt:(GLKVector3)start ending:(GLKVector3)end withPlaneAtPoint:(GLKVector3)v0 withNormal:(GLKVector3)n {
    GLKVector3 p0 = start;
	GLKVector3 p1 = end;
	GLKVector3 u = GLKVector3Normalize(GLKVector3Subtract(p1, p0));
	if (fabsf(GLKVector3DotProduct(u, n)) < EPSILON) {
		if (fabsf(GLKVector3DotProduct(n, GLKVector3Subtract(p0, v0))) < EPSILON) {
			return p0;
		} else {
			return GLKVector3Make(0, 0, 0);
		}
	}
	float s = GLKVector3DotProduct(GLKVector3Subtract(v0, p0), n) / GLKVector3DotProduct(u, n);
	return GLKVector3Add(p0, GLKVector3MultiplyScalar(u, s));
}

- (GLKVector3)findIntersectionPlaneOfEntity:(Entity*)entity withPoint:(CGPoint)point {
    int resolution = 10;
    float height = [entity widthY];
    GLKVector3 up = GLKVector3Make(0, 1, 0);
    GLKVector3 basePoint = entity.position;
    GLKVector3 bestPoint = basePoint;
    float bestDistance = INFINITY;
    float step = height / resolution;
    step = step > 0 ? step : 1;
    for (float level = 0; level <= height; level += step) {
        GLKVector3 currentPoint = GLKVector3Add(basePoint, GLKVector3MultiplyScalar(up, level));
        GLKVector3 intersection = [self findIntersectionOfPoint:point withPlaneAtPoint:currentPoint withNormal:up];
        float distance = GLKVector3Distance(currentPoint, intersection);
        if (distance < bestDistance) {
            bestDistance = distance;
            bestPoint = currentPoint;
        }
    }
    return bestPoint;
}

- (GLKVector3)findEdgeOfLineStartingAt:(GLKVector3)start end:(GLKVector3)end withScreen:(ScreenEdge)screenEdge {
    GLKVector3 p1, p2, p3;
    
    switch (screenEdge) {
        case ScreenEdgeBottom:
            p1 = [self findVectorForRay:CGPointMake(0, self.view.bounds.size.height) atDepth:0];
            p2 = [self findVectorForRay:CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height) atDepth:0];
            p3 = [self findVectorForRay:CGPointMake(0, self.view.bounds.size.height) atDepth:1];
            break;
        case ScreenEdgeTop:
            p1 = [self findVectorForRay:CGPointMake(0, 0) atDepth:0];
            p2 = [self findVectorForRay:CGPointMake(self.view.bounds.size.width, 0) atDepth:0];
            p3 = [self findVectorForRay:CGPointMake(0, 0) atDepth:1];
            break;
        case ScreenEdgeLeft:
            p1 = [self findVectorForRay:CGPointMake(0, 0) atDepth:0];
            p2 = [self findVectorForRay:CGPointMake(0, self.view.bounds.size.height) atDepth:0];
            p3 = [self findVectorForRay:CGPointMake(0, 0) atDepth:1];
            break;
        case ScreenEdgeRight:
            p1 = [self findVectorForRay:CGPointMake(self.view.bounds.size.width, 0) atDepth:0];
            p2 = [self findVectorForRay:CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height) atDepth:0];
            p3 = [self findVectorForRay:CGPointMake(self.view.bounds.size.width, 0) atDepth:1];
            break;

        default:
            break;
    }
    
    GLKVector3 norm = GLKVector3Normalize(GLKVector3CrossProduct(GLKVector3Subtract(p2, p1), GLKVector3Subtract(p3, p1)));
    return [self findIntersectionOfLineStartingAt:start ending:end withPlaneAtPoint:p1 withNormal:norm];
}

- (void)toggleBottomBarVisibility:(UIView*)bottomBar {
    //bottomBar.hidden = !bottomBar.hidden;
    if (_bottomBar == nil) {
        _bottomBar = bottomBar;
        _isBottomBarVisible = !_bottomBar.hidden;
    } else if (_bottomBar != bottomBar) {
        NSAssert(NO, @"invalid bottom bar");
        return;
    }
    [self _toggleBottomBarVisibility];
}

- (void)_toggleBottomBarVisibility {
    NSAssert(_bottomBar != nil, @"invalid bottom bar");
    if (_bottomBar == nil)
        return;

    CGRect bottomFrame = _bottomBar.frame;
    CGFloat bottomY = CGRectGetMaxY(self.view.frame);
    if (_isBottomBarVisible) {
        // to hide
        NSAssert(bottomFrame.origin.y < bottomY - 1, @"bottom bar should be visible");
        if (CGRectIsEmpty(_originalBottomFrame)) {
            _originalBottomFrame = bottomFrame;
        }
        bottomFrame.origin.y = bottomY;
    } else {
        // to show
        if (bottomFrame.origin.y < bottomY - 1) {
            // move down if it is inside view
            bottomFrame.origin.y = bottomY;
            _bottomBar.frame = bottomFrame;
        }
        _bottomBar.hidden = NO;
        NSAssert(!CGRectIsEmpty(_originalBottomFrame), @"unexpected empty _originalBottomFrame");
        if (!CGRectIsEmpty(_originalBottomFrame)) {
            bottomFrame = _originalBottomFrame;
        }
    }
    _isBottomBarVisible = !_isBottomBarVisible;
    
    [UIView animateWithDuration:0.2 animations:^ {
        _bottomBar.frame = bottomFrame;
    } completion:^(BOOL finished) {
        if (!_isBottomBarVisible) {
            _bottomBar.hidden = YES;
        }
    }];
}

- (BOOL)isBottomBarVisible {
    return _bottomBar == nil || _isBottomBarVisible;
}

@end
