//
//  ARViewController.m
//  Homestyler
//
//  Created by xiefei on 7/9/17.
//
//

#import "ARViewController.h"
#import "ConfigManager.h"
#import "ARConfigManager.h"

#import "ARModel.h"
#import "ARPlane.h"
#import "ARMessageView.h"
#import "ModelsCache.h"
#import "ModelsDownloadHandler.h"
#import "ControllersFactory.h"
#import "ProgressPopupBaseViewController.h"
#import "ProductsCatalogBaseViewController.h"
#import "NSDictionary+Helpers.h"

#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreMotion/CoreMotion.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <RQShineLabel/RQShineLabel.h>
#import <ZCAnimatedLabel/ZCDashLabel.h>
#import <ReplayKit/ReplayKit.h>
#import "SDRecordButton.h"
#import "ImageEffectsBaseViewController.h"
#import "ImageEffectShareBaseViewController.h"
#import "HSSharingLogic.h"
#import "ARShareViewController.h"
#import <sys/utsname.h>
#import "ESOrientationManager.h"

const float tolerance = 0.05;
const int VIDEOMAXDURATION  = 15;
typedef void(^ARGuidanceBlock)();
@interface ARViewController () <ARSCNViewDelegate,UIGestureRecognizerDelegate,ProductsCatalogDelegate,ModelsDownloadHandlerDelegate,UIPopoverPresentationControllerDelegate,RPPreviewViewControllerDelegate>

@property (strong, nonatomic) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIButton *catalogBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet SDRecordButton *snapshotBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet ZCDashLabel *hintlbl;
@property (weak, nonatomic) IBOutlet UILabel *beginDesignLb;
@property (weak, nonatomic) IBOutlet UILabel *marker;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet MessageView *messageViewer;
@property (weak, nonatomic) IBOutlet UIImageView *recordImage;
@property (weak, nonatomic) IBOutlet UILabel *recordTime;

@property (nonatomic, strong) ARWorldTrackingConfiguration *arConfig;
@property (nonatomic, strong) ARConfiguration *arTest;
@property (nonatomic, assign) ARTrackingState currentTrackingState;
@property (nonatomic, strong) SCNParticleSystem *blinkParticleSystem;

@property (nonatomic, assign) SCNVector3 initEulerAngles;
@property (nonatomic, assign) SCNVector3 initPosition;
@property (nonatomic, assign) SCNVector3 initScale;
@property (nonatomic, strong) ARModel * selectNode;
@property (nonatomic, strong) NSMutableDictionary<NSUUID *, ARPlane *> *planes;
@property (nonatomic, strong) NSMutableArray<ARModel *> *models;

@property (nonatomic, strong) ModelsCache *modelsCache;
@property (nonatomic, strong) ModelsDownloadHandler* modelsDownloadHandler;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL IS_VIEW_LOADED;
@property (nonatomic, assign) BOOL IS_CAMERA_INITED;

@property (nonatomic, copy) NSString* prodBrand;
@property (nonatomic, copy) NSString* prodName;

@property (weak, nonatomic) IBOutlet UIView *aRGuidanceMaskView;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *aRGuidanceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSizeConstant;
@property (assign,nonatomic) CGFloat currentSize;
@property (weak, nonatomic) IBOutlet UIView *guideViewRight;
@property (weak, nonatomic) IBOutlet UILabel *guideLabelRight;
@property (weak, nonatomic) IBOutlet UIView *guideViewLeft;
@property (weak, nonatomic) IBOutlet UILabel *guideLabelLeft;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (strong, nonatomic) ProductsCatalogBaseViewController* productCatalogView;
@end

@implementation ARViewController

#pragma mark Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupMotion];
    [self setupScene];
    [self setupSession];
    [self setupGestures];
//    [self setupParticle];
    [self setupUI];
    
    self.modelsCache = [[ModelsCache alloc] init];
    self.modelsDownloadHandler = [[ModelsDownloadHandler alloc] initDownloader];
    self.modelsDownloadHandler.delegate = self;
    
    _IS_CAMERA_INITED = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _IS_VIEW_LOADED = YES;
    //开启横屏
    [ESOrientationManager setAllowRotation:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Run the view's session
    [self.sceneView.session runWithConfiguration:self.arConfig];
    [self showMessage:@"AR session begins to run"];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
    [self showMessage:@"AR session is paused"];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //关闭横屏
    [ESOrientationManager setAllowRotation:NO];
}

#pragma mark UIViewControllerRotation
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)setupMotion {
    self.motionManager = [[CMMotionManager alloc] init];
    if ([self.motionManager isDeviceMotionAvailable]) {
        self.motionManager.deviceMotionUpdateInterval = 1;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion * _Nullable motion,
                                                              NSError * _Nullable error) {
     
                                                    if (_IS_VIEW_LOADED && IS_IPHONE) {
                                                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
                                                        [UIViewController attemptRotationToDeviceOrientation];
                                                        _IS_VIEW_LOADED = NO;
                                                    } else {
                                                        double gravityX = motion.gravity.x;
                                                        if (gravityX > 0.5) {
                                                            [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
                                                            [UIViewController attemptRotationToDeviceOrientation];
                                                        }else if (gravityX < -0.5){
                                                            [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
                                                            [UIViewController attemptRotationToDeviceOrientation];
                                                        }
                                                    }
                                                }];
    }
}

#pragma mark ARSessionObserver

- (void)setupSession {
    // Create a ARSession config object we can re-use
    self.arConfig = [ARWorldTrackingConfiguration new];
    self.arConfig.lightEstimationEnabled = YES;
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
    
    // Used to keep track of the current tracking state of the ARSession
    self.currentTrackingState = ARTrackingStateNormal;
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    ARTrackingState trackingState = camera.trackingState;
    if (self.currentTrackingState == trackingState) {
        return;
    }
    self.currentTrackingState = trackingState;
    
    switch(trackingState) {
        case ARTrackingStateNotAvailable:
            [self showMessage:@"Camera tracking is not available on this device"];
            break;
            
        case ARTrackingStateLimited:
            switch(camera.trackingStateReason) {
                case ARTrackingStateReasonInitializing: {
                    [self showMessage:@"Camera tracking is initialzing"];

                    if (!_IS_CAMERA_INITED) {
                        _IS_CAMERA_INITED = YES;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.backBtn.hidden = NO;
                            [self showScan];
                        });
                    }
                    break;
                }
                    
                case ARTrackingStateReasonExcessiveMotion:
                    [self showMessage:@"Limited tracking: slow down the movement of the device"];
                    break;
                    
                case ARTrackingStateReasonInsufficientFeatures:
                    [self showMessage:@"Limited tracking: too few feature points, view areas with more textures"];
                    break;
                    
                case ARTrackingStateReasonNone:
                    NSLog(@"Tracking limited none");
                    break;
            }
            break;
            
        case ARTrackingStateNormal:
            [self showMessage:@"Tracking is back to normal"];
            break;
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    [self showMessage:@"session error"];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay, or being put in to the background
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Interruption" message:@"The tracking session has been interrupted. The session will be reset once the interruption has completed" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:ok];
//    [self presentViewController:alert animated:YES completion:^{
//    }];
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    [self showMessage:@"Tracking session has been reset due to interruption"];
//    [self refresh];
}

- (void)refresh {
    for (NSUUID *planeId in self.planes) {
        [self.planes[planeId] remove];
    }
    for (ARModel *model in self.models) {
        [model remove];
    }
    [self.models removeAllObjects];
    
    [self.sceneView.session runWithConfiguration:self.arConfig options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
}

#pragma mark - ARSCNViewDelegate

- (void)setupScene {

    self.sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0,0,MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)) ];
    
    [self.view addSubview:self.sceneView];
    [self.view sendSubviewToBack:self.sceneView];
    
    // Setup the ARSCNViewDelegate - this gives us callbacks to handle new geometry creation
    self.sceneView.delegate = self;
    
    // A dictionary of all the current planes being rendered in the scene
    self.planes = [NSMutableDictionary new];
    
    // A list of all the cubes being rendered in the scene
    self.models = [NSMutableArray new];
    
    // Make things look pretty :)
    self.sceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    
    // Setup debug options
    SCNDebugOptions opts = SCNDebugOptionNone;
    opts = ARSCNDebugOptionShowFeaturePoints | SCNDebugOptionShowCameras;
    self.sceneView.debugOptions = opts;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = NO;
    
    //    // This is the object that we add all of our geometry to, if you want
    //    // to render something you need to add it here
    self.sceneView.scene = [SCNScene new];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    ARLightEstimate *estimate = self.sceneView.session.currentFrame.lightEstimate;
    if (!estimate) {
        return;
    }
    
    // A value of 1000 is considered neutral, lighting environment intensity normalizes
    // 1.0 to neutral so we need to scale the ambientIntensity value
    CGFloat intensity = estimate.ambientIntensity / 1000.0;
    self.sceneView.scene.lightingEnvironment.intensity = intensity;
}

/**
 Called when a new node has been mapped to the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that maps to the anchor.
 @param anchor The added anchor.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
    if (self.planes.count > 0)
        return;
    
    ARPlane *plane = [[ARPlane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: NO];
    [self.planes setObject:plane forKey:anchor.identifier];
    [node addChildNode:plane];
    
    [plane runAction:[SCNAction fadeInWithDuration:1.0]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideScan];
        [self showButtons];
    });
    
    //    [self showMessage:[NSString stringWithFormat:@"New place is traced at %f,%f,%f", plane.position.x, plane.position.y, plane.position.z]];
}

/**
 Called when a node has been updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    ARPlane *plane = [self.planes objectForKey:anchor.identifier];
    if (plane == nil) {
        return;
    }
    
    // When an anchor is updated we need to also update our 3D geometry too. For example
    // the width and height of the plane detection may have changed so we need to update
    // our SceneKit geometry to match that
    [plane update:(ARPlaneAnchor *)anchor];
    [self showMessage:[NSString stringWithFormat:@"The place is update by %fx%fx%f", plane.planeGeometry.width, plane.planeGeometry.height, plane.planeGeometry.length]];
}

/**
 Called when a mapped node has been removed from the scene graph for the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that was removed.
 @param anchor The anchor that was removed.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    // Nodes will be removed if planes multiple individual planes that are detected to all be
    // part of a larger plane are merged.
    [self.planes removeObjectForKey:anchor.identifier];
}

/**
 Called when a node will be updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that will be updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}

#pragma mark UIGestureRecognizerDelegate
- (void)setupGestures {
    
    UITapGestureRecognizer *pickGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectModel:)];
    pickGestureRecognizer.numberOfTapsRequired = 1;
    pickGestureRecognizer.delegate = self;
    [self.sceneView addGestureRecognizer:pickGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveModel:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self.sceneView addGestureRecognizer:panGestureRecognizer];
    
    UIPanGestureRecognizer *liftGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(liftModel:)];
    liftGestureRecognizer.minimumNumberOfTouches = 2;
    liftGestureRecognizer.delegate = self;
    [self.sceneView addGestureRecognizer:liftGestureRecognizer];
    
    UIRotationGestureRecognizer *rotGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateModel:)];
    rotGestureRecognizer.delegate = self;
    [self.sceneView addGestureRecognizer:rotGestureRecognizer];
    
    UIPinchGestureRecognizer *pinGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleModel:)];
    pinGestureRecognizer.delegate = self;
    [self.sceneView addGestureRecognizer:pinGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        if (self.selectNode)
            self.initEulerAngles = self.selectNode.eulerAngles;
    }
    else if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.selectNode)
            self.initPosition = self.selectNode.position;
    }
    else if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        if (self.selectNode)
            self.initScale = self.selectNode.scale;
    }
    return YES;
}

- (void)selectModel:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint tapPoint = [recognizer locationInView:self.sceneView];
    NSArray<SCNHitTestResult *> *result = [self.sceneView hitTest:tapPoint
                                                          options:@{SCNHitTestOptionSearchMode: @0}];

    if (result.count == 0) {
        [self select:nil];
        return;
    }
    
    ARModel* selected;
    SCNHitTestResult * hitResult = [result firstObject];
    if ([hitResult.node.parentNode isKindOfClass:[ARModel class]] )
    {
        selected = (ARModel*)hitResult.node.parentNode;
    } else if ([hitResult.node isKindOfClass:[ARModel class]]) {
        selected = (ARModel*)hitResult.node;
    }
    
    if (self.selectNode != selected) {
        [self select:selected];
    }
}

- (void)moveModel:(UIPanGestureRecognizer *)recognizer {
    SCNNode *node = self.selectNode;
    if (node) {
        
        SCNVector3 initPos = [self.sceneView projectPoint:self.initPosition];
        CGPoint offset = [recognizer translationInView:self.sceneView];
        CGPoint newPos = CGPointMake(initPos.x + offset.x, initPos.y + offset.y);
        
        node.position = [self rayIntersectionWithHorizontalPlane:newPos planeY:self.initPosition.y];
    }
}

- (void)liftModel:(UIPanGestureRecognizer *)recognizer {
    SCNNode *node = self.selectNode;
    if (node) {
        SCNVector3 initPos = [self.sceneView projectPoint:self.initPosition];
        CGPoint offset = [recognizer translationInView:self.sceneView];
        CGPoint newPosInScreen = CGPointMake(initPos.x + offset.x, initPos.y + offset.y);
        SCNVector3 newPos = [self.sceneView unprojectPoint:SCNVector3Make(newPosInScreen.x, newPosInScreen.y, initPos.z)];
        
        newPos.x = self.initPosition.x;
        newPos.z = self.initPosition.z;
        
        if (fabsf(newPos.y - self.initPosition.y) < tolerance) {
            newPos.y = self.initPosition.y;
        }

        node.position = newPos;
    }
}

- (void)rotateModel:(UIRotationGestureRecognizer *)recognizer {
    SCNNode *node = self.selectNode;
    if (node) {
        CGFloat yaw = self.initEulerAngles.y - recognizer.rotation;
        node.eulerAngles = SCNVector3Make(0, yaw, 0);
    }
}

- (void)scaleModel:(UIPinchGestureRecognizer *)recognizer {
    if (self.selectNode) {
        CGFloat scale = recognizer.scale;
        if (self.selectNode.isLocked) {
            if (fabs(scale - 1) < 0.5)
                return;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"scale_lock_alert_copy_title", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"scale_lock_alert_btn1", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.selectNode.isLocked = NO;
                CGFloat scale = recognizer.scale;
                self.selectNode.scale = SCNVector3Make(self.initScale.x * scale, self.initScale.y * scale, self.initScale.z * scale);
                [self.selectNode updateDimension];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"scale_lock_alert_btn2", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }];
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            self.selectNode.scale = SCNVector3Make(self.initScale.x * scale, self.initScale.y * scale, self.initScale.z * scale);
            
            [self.selectNode updateDimension];
        }
    }
}

- (BOOL)isModel:(SCNNode*)node
{
    if (!node) {
        return NO;
    }
    if ([node isKindOfClass:[ARModel class]]) {
        return YES;
    }
    
    return [self isModel:node.parentNode];
}

- (SCNVector3)rayIntersectionWithHorizontalPlane:(CGPoint)pos planeY:(CGFloat)plane{
    ARCamera *camera = self.sceneView.session.currentFrame.camera;
    simd_float3 campos =  simd_make_float3(camera.transform.columns[3].x, camera.transform.columns[3].y, camera.transform.columns[3].z);
    
    // Note: z: 1.0 will unproject() the screen position to the far clipping plane.
    SCNVector3 scnpos = [self.sceneView unprojectPoint:SCNVector3Make(pos.x, pos.y, 1.0)];
    simd_float3 sscnpos = simd_make_float3(scnpos.x, scnpos.y, scnpos.z);
    simd_float3 raydir = simd_normalize(sscnpos - campos);
    
    // The distance from the ray's origin to the intersection point on the plane is:
    //   (pointOnPlane - rayOrigin) dot planeNormal
    //  --------------------------------------------
    //          direction dot planeNormal
    
    // Since we know that horizontal planes have normal (0, 1, 0), we can simplify this to:
    float dist = (plane - campos.y) / raydir.y;
    
    simd_float3 intersect = campos + raydir * dist;
    return SCNVector3Make(intersect.x, intersect.y, intersect.z);
}

- (void)showMessage:(NSString *)message {
    [self.messageViewer queueMessage:message];
}

#pragma mark particle system
- (void)setupParticle {
    self.blinkParticleSystem = [SCNParticleSystem particleSystemNamed:@"blink.scnp" inDirectory:nil];
    self.blinkParticleSystem.loops = NO;
}

#pragma mark UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark ProductsCatalogDelegate
- (void) productSelected:(NSString*)productId andVariateId:(NSString*)variateId andVersion:(NSString*)timeStamp {
    
    // First check if the product is an Assembly.
    ShoppingListItem *shoppingListItem = [[ModelsHandler sharedInstance] shoppingListItemForModelId:productId];
    self.prodName = shoppingListItem.Name;
    self.prodBrand = shoppingListItem.vendorName;
    
    if ([shoppingListItem isAssembly]){
        //        [self getCollection:shoppingListItem productId:productId variateId:variateId];
    }else{
        [self flurry:productId];
        // Model was not found. Start the loading screen and download the model
        HSSingleModelDownloadDecriptor *descriptor = [HSSingleModelDownloadDecriptor new];
        descriptor.modelId = productId;
        if (variateId) {
            descriptor.variationId = variateId;
        } else {
            descriptor.variationId = productId;
        }
        
        NSArray* res = [self.modelsCache getModel:descriptor.modelId
                                      variationId:descriptor.variationId
                                   andGlobalScale:1.0f];
        
        if (res) {
            NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:[self.view center] types:ARHitTestResultTypeExistingPlane];
            
            if (result.count == 0) {
                return;
            }
            
            // If there are multiple hits, just pick the closest plane
            ARHitTestResult * hitResult = [result firstObject];
            SCNVector3 position = SCNVector3Make(hitResult.worldTransform.columns[3].x,
                                                 hitResult.worldTransform.columns[3].y,
                                                 hitResult.worldTransform.columns[3].z);
            
            ARModel* model = [self loadModel:descriptor.modelId fromObj:res[0] fromTexture:res[2] at:position];
            model.name = self.prodName;
            model.brand = self.prodBrand;
            
            [self select:model];
            
            for (NSUUID *planeId in self.planes) {
                [self.planes[planeId] runAction:[SCNAction fadeOutWithDuration:0.5]];
            }
            
            [self showButtons];
            
        } else {
            [self showLoading];
            [self.modelsDownloadHandler downloadSingleModel:descriptor
                                                 andVersion:timeStamp];
        }
    }
}

- (void)singleModelDownloadEnded:(HSSingleModelDownloadDecriptor*)modelDescriptor
                     successFlag:(Boolean)isSucceeded
{
    [self hideLoading];
    [self showButtons];
    
    if (!isSucceeded) {
        return;
    }
    
    if (self.planes.count == 0)
        return;
    
    NSArray<ARHitTestResult *> *result = [self.sceneView hitTest:[self.view center] types:ARHitTestResultTypeExistingPlane];

    if (result.count == 0) {
        return;
    }
    
    // If there are multiple hits, just pick the closest plane
    ARHitTestResult * hitResult = [result firstObject];
    SCNVector3 position = SCNVector3Make(hitResult.worldTransform.columns[3].x,
                                         hitResult.worldTransform.columns[3].y,
                                         hitResult.worldTransform.columns[3].z);
    
    NSArray* res = [self.modelsCache getModel:modelDescriptor.modelId
                                  variationId:modelDescriptor.variationId
                               andGlobalScale:1.0f];

    if (!res)
        return;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ARGuidance"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"ARGuidance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        __weak typeof (self) weakSelf = self;
        [self showARGuidance:^{
            [weakSelf setsingleModel:modelDescriptor AndArray:res AndPosition:position];
        }];
    } else {
        [self setsingleModel:modelDescriptor AndArray:res AndPosition:position];
    }

    for (NSUUID *planeId in self.planes) {
        [self.planes[planeId] runAction:[SCNAction fadeOutWithDuration:0.5]];
    }
}

-(void)setsingleModel:(HSSingleModelDownloadDecriptor*)modelDescriptor AndArray:(NSArray *)res AndPosition:(SCNVector3)position{
    ARModel* model = [self loadModel:modelDescriptor.modelId fromObj:res[0] fromTexture:res[2] at:position];
    model.name = self.prodName;
    model.brand = self.prodBrand;
    [self select:model];
}

- (ARModel *)loadModel:(NSString *)modelId fromObj:obj fromTexture:texture at:(SCNVector3)position {
    
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
                          stringByAppendingPathComponent:@"/ARData"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    //RecordAndPhoto Guide
    [self isDisplayGuide:filePath];
    
    NSString *objPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.obj", modelId]];
    NSString *pngPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", modelId]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:objPath])
        [[NSFileManager defaultManager] createFileAtPath:objPath contents:obj attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pngPath]) {
        [[NSFileManager defaultManager] createFileAtPath:pngPath contents:texture attributes:nil];
    }
    
    ARModel * model = [[ARModel alloc] initWithObj:objPath withMaterial:pngPath position:position];
    
    if (model) {
        model.id = modelId;
        [self.models addObject:model];
        
        model.scale = SCNVector3Make(model.scale.x/4, model.scale.y/4, model.scale.z/4);
        [self.sceneView.scene.rootNode addChildNode:model];
        SCNAction *zoomIn = [SCNAction scaleBy:5 duration:0.4];
        SCNAction *zoomOut = [SCNAction scaleBy:0.8 duration:0.1];
        SCNAction *sequence = [SCNAction sequence:@[zoomIn, zoomOut]];
        [model runAction:sequence];

        return model;
    } else {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"failed_load_catalog_item", @"")
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        [alert show];
    }
    return nil;
}

#pragma mark UIEvents
- (IBAction)comeBack:(id)sender {
    
    if (self.models.count == 0 && self.planes.count == 0) {
        [[UIMenuManager sharedInstance] backPressed:sender];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"ask_quit_design", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"sign_out", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIMenuManager sharedInstance] backPressed:sender];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)goToCatalog:(id)sender {
    
    if (!self.productCatalogView) {
        self.productCatalogView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProductCatalogView"
                                                                                 inStoryboard:kRedesignStoryboard];
        self.productCatalogView.delegate = (id <ProductsCatalogDelegate>) self;
        self.productCatalogView.isFromAR = YES;
        self.productCatalogView.edgesForExtendedLayout = UIRectEdgeNone;
        self.productCatalogView.preferredContentSize = CGSizeMake(640, 320);
        self.productCatalogView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.productCatalogView.view.backgroundColor = [UIColor colorWithRed:(52/255.0) green:(58/255.0) blue:(64/255.0) alpha:0.6];
    }
    
    if (![ConfigManager isAnyNetworkAvailableOrOffline])
    {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"failed_action_no_network_found", @"We lost you! Check your network connection.")
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    

    self.productCatalogView.view.alpha = 0.0;
    [self presentViewController:self.productCatalogView animated:NO completion:^{
        [UIView animateWithDuration:0.5f animations:^{
            self.productCatalogView.view.alpha = 1.0;
        }];
    }];
    
    [self hideButtons];
    
    if (ANALYTICS_ENABLED){
//        [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_CATALOG withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_AR}];
    }
}

- (IBAction)infoAction:(id)sender {
    ARModel *node = self.selectNode;
    if (node) {
        self.infoBtn.selected = !self.infoBtn.selected;
        
        if (self.infoBtn.selected) {
            [node hideBasement];
            [node showDimension];
        } else {
            [node hideDimension];
            [node showBasement];
        }
        
        if (self.infoBtn.selected) {
            self.marker.hidden = NO;
        } else {
            self.marker.hidden = YES;
        }
    }
}


- (IBAction)deleteAction:(id)sender {
    ARModel *model = self.selectNode;
    if (model) {
        [self select:nil];
        
        // Emit particles.
//        CGFloat radius;
//        SCNVector3 center = SCNVector3Make(0, 0, 0);
//        [model.childNodes[0] getBoundingSphereCenter:&center radius:&radius];
//
//        SCNMatrix4 particleSystemPosition = model.childNodes[0].worldTransform;
//        self.blinkParticleSystem.emitterShape = [SCNSphere sphereWithRadius:radius/2];
//        [self.sceneView.scene addParticleSystem:self.blinkParticleSystem withTransform:particleSystemPosition];
        
        SCNAction *zoomOut = [SCNAction scaleBy:0.05 duration:0.2];
        [model runAction:zoomOut completionHandler:^{
            [model removeFromParentNode];
        }];
        
        [self.models removeObject:model];
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_DELETE_PRODUCT withParameters:@{@"product_id_AR": model.id}];
    }
    
    if (self.models.count == 0) {
        self.infoBtn.selected = NO;
    }
}

- (void)select:(ARModel*)model
{
    BOOL infoState = self.infoBtn.selected;
    
    if (self.selectNode) {
        infoState?[self.selectNode hideDimension]:[self.selectNode hideBasement];
    }
    
    if (self.selectNode == nil && model != nil) {
        [self toggleDeleteButton:YES];
        [self toggleInfoButton:YES];
    }
    if (self.selectNode != nil && model == nil) {
        [self toggleDeleteButton:NO];
        [self toggleInfoButton:NO];
    }
    
    self.selectNode = model;
    if (model) {
        infoState?[model showDimension]:[model showBasement];
        
        NSString* modelName = model.name;
        if (IS_IPHONE && model.name.length > 12) {
            modelName = [model.name stringByReplacingCharactersInRange:NSMakeRange(12, model.name.length - 12) withString:@"..."];
        }
        NSString * string = [NSString stringWithFormat:@"%@ | %@ | %.1fx%.1fx%.1fcm (orginal)",  model.brand, modelName, model.width, model.level, model.height];
        NSMutableAttributedString *modelInfo = [[NSMutableAttributedString alloc] initWithString:string];
        [modelInfo addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[string rangeOfString:model.brand]];
        
        self.marker.attributedText = modelInfo;
        self.marker.hidden = !infoState;
    } else {
        self.marker.hidden = YES;
    }
}

#pragma mark UILayout

- (void)setupUI {
    [self hideButtons];
    
    self.hintlbl.layerBased = YES;
    self.hintlbl.animationDuration = 0.5;
    
    if (IS_IPAD) {
        [self.recordTime setFont:[UIFont systemFontOfSize:18]];
        [self.beginDesignLb setFont:[UIFont systemFontOfSize:20]];
    }
    
    self.beginDesignLb.text = NSLocalizedString(@"Ready to design", @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateButtons)
                                                 name:@"ShowMainMenuButtonNotification"
                                               object:nil];
    
    self.logoImage.image = [UIImage imageNamed:[[ConfigManager getTenantIdName] isEqualToString:@"ezhome"] ? @"watermark_ezhome" : @"watermark"];
}

- (void)updateButtons {
    if (![self isLoading]) {
        [self showButtons];
    }
}

- (void)showButtons {
    
    self.backBtn.hidden = NO;
    self.catalogBtn.hidden = NO;
    self.snapshotBtn.hidden = NO;
    
    CABasicAnimation *animUp = [CABasicAnimation animationWithKeyPath:@"transform"];
    animUp.duration = 0.2;
    animUp.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 50, 0)];
    [self.snapshotBtn.layer addAnimation:animUp forKey:nil];
    [self.catalogBtn.layer addAnimation:animUp forKey:nil];
    
    if (self.selectNode) {
        [self toggleDeleteButton:YES];
        [self toggleInfoButton:YES];
        self.marker.hidden = !self.infoBtn.selected;
    }
}

- (void)hideButtons {
    
    self.marker.hidden  = YES;
    self.backBtn.hidden = YES;
    self.infoBtn.hidden = YES;
    self.hintlbl.hidden = YES;
    self.catalogBtn.hidden  = YES;
    self.snapshotBtn.hidden = YES;
    self.imageView.hidden   = YES;
    self.deleteBtn.hidden   = YES;

}

- (void)toggleDeleteButton:(BOOL)show {

    if (show) {
        self.deleteBtn.hidden = NO;
        CABasicAnimation *animUp = [CABasicAnimation animationWithKeyPath:@"transform"];
        animUp.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 50, 0)];
        CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeIn.toValue = [NSNumber numberWithFloat:1];
        
        CAAnimationGroup *group=[CAAnimationGroup animation];
        group.duration = 0.2f;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.animations = [NSArray arrayWithObjects: animUp,fadeIn, nil];
        [self.deleteBtn.layer addAnimation:group forKey:nil];
    } else {
        CABasicAnimation *animDown = [CABasicAnimation animationWithKeyPath:@"transform"];
        animDown.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 50, 0)];
        CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOut.toValue = [NSNumber numberWithFloat:0];
        
        CAAnimationGroup *group=[CAAnimationGroup animation];
        group.duration = 0.2f;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.animations = [NSArray arrayWithObjects: animDown,fadeOut,nil];
        [self.deleteBtn.layer addAnimation:group forKey:nil];
    }
}

- (void)toggleInfoButton:(BOOL)show {
    
    if (show) {
        self.infoBtn.hidden = NO;
        CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform"];
        zoomIn.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0,0,0)];
        zoomIn.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        zoomIn.fillMode = kCAFillModeForwards;
        zoomIn.removedOnCompletion = NO;
        [self.infoBtn.layer addAnimation:zoomIn forKey:nil];
    } else {
        CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform"];
        zoomOut.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        zoomOut.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01,0.01,0.01)];
        zoomOut.fillMode = kCAFillModeForwards;
        zoomOut.removedOnCompletion = NO;
        [self.infoBtn.layer addAnimation:zoomOut forKey:nil];
    }
    
    if (ANALYTICS_ENABLED){
//        [HSFlurry logEvent:EVENT_AR withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN: EVENT_LABEL_AR_PRODUCT_INFO}];
    }
}

- (void)showScan {
    
    self.imageSizeConstant.constant = IS_IPHONE ? self.imageSizeConstant.constant * 0.6 : self.imageSizeConstant.constant * 0.8;
    self.currentSize = self.imageSizeConstant.constant;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"scan_floor" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    self.imageView.hidden = NO;
    self.hintlbl.hidden = NO;
    [self setHintlblString:NSLocalizedString(@"AR Check Begining", @"")];
}

- (void)hideScan {
    if (self.imageView) {
        self.imageView.hidden = YES;
        self.hintlbl.hidden = YES;
        //Add Products Guide
        [self isDisplayGuide:[NSUserDefaults standardUserDefaults]];
        [self showDesignLabel];
        
        self.sceneView.debugOptions = SCNDebugOptionNone;
    }
}

- (void)showLoading {
    self.imageSizeConstant.constant = self.currentSize * 0.6;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loading_model" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    [self.imageView setBounds:CGRectMake(0, 0, 160, 120)];
    self.loadingLabel.text = NSLocalizedString(@"loading_tips_loading_title", @"");
    self.loadingLabel.hidden = NO;
    self.imageView.hidden = NO;
}

- (void)hideLoading {
    self.loadingLabel.hidden = YES;
    self.imageView.hidden = YES;
}

- (BOOL)isLoading {
    return !self.imageView.hidden;
}

- (void)showARGuidance:(ARGuidanceBlock)block {
    [self hideButtons];
    self.backBtn.hidden = NO;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"introduction_small" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.aRGuidanceImageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    __weak typeof (self) weakSelf = self;
    self.aRGuidanceImageView.loopCompletionBlock = ^(NSUInteger loopCountRemaining){
        if (loopCountRemaining >= 1) {
            [weakSelf.aRGuidanceMaskView removeFromSuperview];
            block();
            [weakSelf showButtons];
        }
    };
    self.aRGuidanceMaskView.hidden = NO;
    self.aRGuidanceImageView.hidden = NO;
}

#pragma mark PhotoOrVideo Action

- (IBAction)btnTouchDown:(SDRecordButton *)sender {
    self.snapshotBtn.userInteractionEnabled = NO;
    [self performSelector:@selector(checkPhotoOrVideo) withObject:self afterDelay:1.0f];
}

- (IBAction)btnTouchUp:(SDRecordButton *)sender {
    if (self.snapshotBtn.isLongTouch) {
        [self stopVideo:YES];
        self.progress = 0;
        [self.progressTimer invalidate];
        self.snapshotBtn.isLongTouch = NO;
    }
}

-(void)checkPhotoOrVideo {
    if (self.snapshotBtn.state == UIControlStateHighlighted) {
        [self startVideo];
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        self.snapshotBtn.isLongTouch = YES;
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:EVENT_AR withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN: EVENT_LABEL_AR_SCREENRECORD}];
        }
    }else{
        self.snapshotBtn.isLongTouch = NO;
        UIImage * scene = [self.sceneView snapshot];
        
        UIImageWriteToSavedPhotosAlbum(scene, nil, nil, nil);
        
        UIView * flashView = [[UIView alloc] initWithFrame:self.view.frame];
        flashView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:flashView];
        
        [UIView animateWithDuration:0.5 delay:0.1 options:0 animations:^{
            flashView.alpha = 0;
        } completion:^(BOOL finished)
         {
             [flashView removeFromSuperview];
             [self thePhotoGotoShare:scene];
         }];
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:EVENT_AR withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN: EVENT_LABEL_AR_SCREENSHOT}];
        }
    }
    self.snapshotBtn.userInteractionEnabled = YES;
}

- (void)updateProgress {
    self.progress += 0.05/VIDEOMAXDURATION;
    [self.snapshotBtn setProgress:self.progress];
    
    self.recordTime.text = [NSString stringWithFormat:@"00:%02ld", lroundf(self.progress * VIDEOMAXDURATION)];
    
    if (self.progress >= 1){
        [self stopVideo:YES];
        [self.snapshotBtn setProgress:0];
        [self.progressTimer invalidate];
    }
}

-(void)startVideo {
//    NSLog(@"%@", @"btn down");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backBtn.hidden = YES;
        self.recordImage.hidden = NO;
        self.recordTime.hidden = NO;
        self.logoImage.hidden = NO;
        [self hideButtons];
        self.snapshotBtn.hidden = NO;
        
        [[RPScreenRecorder sharedRecorder] startRecordingWithHandler:^(NSError * _Nullable error) {
//            NSLog(@"%@", @"starting");
            if (!self.snapshotBtn.isLongTouch) {
                [self stopVideo:NO];
            }
        }];
    });
}

-(void)stopVideo:(BOOL)preview {
//    NSLog(@"%@", @"btn up");

    dispatch_async(dispatch_get_main_queue(), ^{
        self.backBtn.hidden = NO;
        self.recordImage.hidden = YES;
        self.recordTime.hidden = YES;
        self.logoImage.hidden = YES;
        [self showButtons];
        
        [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
//            NSLog(@"%@", @"stoping");
            if (!preview) {
                return;
            }
            if (previewViewController) {

                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    previewViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    previewViewController.popoverPresentationController.sourceRect = CGRectZero;
                    previewViewController.popoverPresentationController.sourceView = self.view;
                }
                
                previewViewController.previewControllerDelegate = self;
                [self presentViewController:previewViewController animated:YES completion:nil];
            }
        }];
    });
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [previewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -ShareDesign-

-(void)thePhotoGotoShare:(UIImage *)image {
    
    ARShareViewController *share = [[ARShareViewController alloc] init];
    
    share.edgesForExtendedLayout = UIRectEdgeNone;
    
    share.preferredContentSize = CGSizeMake(640, 320);
    
    share.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    share.image = image;
    
    [self presentViewController:share animated:YES completion:nil];

}

#pragma mark Label Tip Method
-(void)setHintlblString:(NSString*)string {
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:14]
                   constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                       lineBreakMode:NSLineBreakByWordWrapping];
    [self.hintlbl setBounds:CGRectMake(0, 0, size.width, size.height)];
    [self.hintlbl setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width /2, [UIScreen mainScreen].bounds.size.height/2+36) ];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mutableString = [[[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: [UIColor whiteColor]}] mutableCopy];
    self.hintlbl.attributedString = mutableString;
    [self.hintlbl startAppearAnimation];
}

-(void)showDesignLabel {

    self.beginDesignLb.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.beginDesignLb.hidden = YES;
    });
}

#pragma mark RecordAndPhoto Guide
-(void)isDisplayGuide:(id)object {
    
    if ([object isKindOfClass:[NSUserDefaults class]] && ![object objectForKey:@"FirstAddProducts"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.guideLabelLeft.text = NSLocalizedString(@"Add_Products_ForAR", @"");
            self.guideViewLeft.hidden = NO;
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"FirstAddProducts"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.guideViewLeft.hidden = YES;
            });
        });
    }else if ([object isKindOfClass:[NSString class]]) {
        NSArray *arModel = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:object error:nil];
        if (arModel.count <= 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.guideLabelRight.text = NSLocalizedString(@"Guide_to_Record", @"");
                self.guideViewRight.hidden = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.guideViewRight.hidden = YES;
                });
            });
        }
    }
}

#pragma mark Flurry
- (void) flurry:(NSString*)productid{
#ifdef USE_FLURRY
    if (productid==nil) {
        return;
    }
    
    if(ANALYTICS_ENABLED){
//        [ HSFlurry logEvent:FLURRY_CATALOG_PRODUCT_SELECT_CLICK withParameters:[NSDictionary dictionaryWithObject:productid forKey:@"product_id_AR"]];
    }
#endif
}


@end
