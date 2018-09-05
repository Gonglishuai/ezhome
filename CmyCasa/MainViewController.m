//
//  MainViewController.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "MainViewController.h"
#import "UIViewController+Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "GraphicObject.h"
#import "AppDelegate.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Scale.h"
#import "UIImage+Masking.h"
#import "NSDictionary+Helpers.h"
#import "SaveDesignFlowBaseController.h"
#import "ControllersFactory.h"
#import "ImageEffectsBaseViewController.h"
#import "ConcealViewController.h"
#import "UIView+Effects.h"
#import "ImageFetcher.h"
#import "NotificationNames.h"
#import "UIView+ReloadUI.h"
#import "ModelsCache.h"
#import "ModelsHandler.h"
#import "FileDownloadManager.h"
#import "NSString+JSONHelpers.h"
#import "zipzap/zipzap.h"
#import "CubeViewController.h"
#import "LevitateView.h"
//#import "UMMobClick/MobClick.h"
#import "ESOrientationManager.h"

#pragma mark- IPHONE STUFF

#ifdef SERVER_RENDERING
#include "ServerRendererManager.h"
#endif

typedef enum
{
    AlertTypeScaleRealScale = 3,
    AlertTypeScaleNoRealScale = 4,
    AlertTypeShareSignInRequired = 5,
    AlertTypeSaveSignInRequired = 6
}AlertType;

///////////////////////////////////////////////////////////////////
//                      INTERFACE                                //
///////////////////////////////////////////////////////////////////

@interface MainViewController ()
{
    BOOL isSaveRequestedBeforeLeave;
    BOOL bViewDidAppear;
    BOOL bRunAdjust;
    BOOL _hasRunImageAnalysis;
    BOOL _isBackPressed;
    BOOL _isModelsLoadedForDesign;
}

@property (nonatomic) BOOL isDownloadCompleted;
@property (strong, nonatomic) ModelsCache* modelsCache;
@property (nonatomic) BOOL isPaintViewPresented;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *catalogBtnWidth;

@end
///////////////////////////////////////////////////////////////////
//                  IMPLEMENTATION                               //
///////////////////////////////////////////////////////////////////

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_3DTOOL_SCREEN;
    
    _isModelsLoadedForDesign = NO;
    _hasRunImageAnalysis = NO;
    
    //QA Compatibility Labels:
    self.view.accessibilityLabel = @"Room Designer";
    self.modelsCache = [[ModelsCache alloc] init];
    
    isSaveRequestedBeforeLeave = NO;
    bViewDidAppear = NO;
    
    [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    
    [self loadGridOptionDialogView];
    
    [self loadFurniture3DViewController];
    
    self.imageView.image = [[DesignsManager sharedInstance] workingDesign].image;
    
    if (IS_IPAD) {
        self.productTagBaseView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProductTagView" inStoryboard:kProductTagViewStoryboard];
        
        _imageOptionsView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ImageOptionsViewController" inStoryboard:kRedesignStoryboard];
        
        [self.view bringSubviewToFront:self.iPadTopBar];
        [self.view bringSubviewToFront:self.undoView];
    }else{
        
        [self loadImageOptionDialogView];
        
        self.productTagBaseView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProductTagViewIphone" inStoryboard:kProductTagViewStoryboard];
        
        [self.view bringSubviewToFront:self.undoView];
        [self.view bringSubviewToFront:self.iphoneCatalogButtonView];
        
        if (!self.iphoneMenuVC) {
            self.iphoneMenuVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"redesignToolMenuViewController" inStoryboard:kRedesignStoryboard];
            self.iphoneMenuVC.mainVc = self;
            [self.view addSubview:self.iphoneMenuVC.view];
            [self addChildViewController:self.iphoneMenuVC];
            
            [self.iphoneMenuVC hideMenuButton];
        }
    }
    
    self.productTagBaseView.productDelegate = self;
    self.productTagBaseView.genericWebViewDelegate = self;
    
    _modelsDownloadHandler = [[ModelsDownloadHandler alloc] initDownloader];
    _modelsDownloadHandler.delegate = self;
    
    _saveDesignFlow = [ControllersFactory instantiateViewControllerWithIdentifier:@"SaveDesignFlowController" inStoryboard:kRedesignStoryboard];
    _saveDesignFlow.designDelegate = self;
        
    [self updateUndoRedoStates];
    
    // Check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged" object:nil];
    [self.view reloadUI];
    
    self.catalogBtnWidth.constant = [ConfigManager deviceTypeisIPhoneX] ? 98 : 55;
    
    //开启横屏
    if (IS_IPHONE) {
        [ESOrientationManager setAllowRotation:YES];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
        [self savePressed];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // check if loading self from 'back pressed' method (back from cube screen)
    if (_isBackPressed == NO){
        
        SavedDesign* design = [[DesignsManager sharedInstance] workingDesign];
        if (design != nil && (design.GyroData == nil || design.CubeVerts == nil))
        {
            if (_hasRunImageAnalysis)
            {
                // close this design if back from image analysis and no cube data determined
                _hasRunImageAnalysis = NO;
                [self exitDesign:NO];
                return;
            }
            
            if (!bRunAdjust) {
//                [HSFlurry logAnalyticEvent:EVENT_NAME_REAL_SCALE_WIZARD withParameters:@{EVENT_PARAM_WIZARD_TRIGGER:EVENT_PARAM_VAL_PHOTO}];
            }
            
            [self runAdjust];
        }
        
        bViewDidAppear = YES;
        bRunAdjust = NO;
        
    }else{
        _isBackPressed = NO;
    }
    
    if (!_isModelsLoadedForDesign) {
        _isModelsLoadedForDesign = YES;
        [self loadModels];
    }
    
    if (self.isLoadedFromCatalogBeforeMainWasActive) {
        [self productSelected:self.productId andVariateId:self.variationId andVersion:self.timeStamp];
        self.productId = nil;
        self.variationId = nil;
        self.timeStamp = nil;
        self.isLoadedFromCatalogBeforeMainWasActive = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopEditing];
        
//    self.originalDesignObject = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.view
                                                    name:@"NetworkStatusChanged"
                                                  object:nil];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc {
    NSLog(@"dealloc - MainViewController");
}

#pragma mark - Class Function
-(void)loadFurniture3DViewController{
    //add 3D view to main window
    self.furniture3DViewController = (Furniture3DViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"Furniture3DViewController" inStoryboard:kRedesignStoryboard];
    self.furniture3DViewController.selectionDelegate = self;
    [self.furniture3DViewController.view setFrame:self.view.bounds];
    [self.view addSubview:self.furniture3DViewController.view];
    [self addChildViewController:self.furniture3DViewController];
    
    SavedDesign * savedDesign = [[DesignsManager sharedInstance] workingDesign];
    self.furniture3DViewController.gyroData = savedDesign.GyroData;
    self.furniture3DViewController.cubeVerts = savedDesign.CubeVerts;
    self.furniture3DViewController.camera.fovVertical = [savedDesign fovForScreenSize:self.furniture3DViewController.view.bounds.size];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadGridOptionDialogView{
    if (!IS_IPAD)
    {
        if (!self.gridOptionsDialogView) {
            self.gridOptionsDialogView = [[[NSBundle mainBundle] loadNibNamed:@"GridOptionsDialogView" owner:self options:nil] objectAtIndex:0];
            [self.gridOptionsDialogView setFrame:self.view.frame];
            [self.gridOptionsDialogView.optionsContainerView setCenter:CGPointMake([UIScreen currentScreenBoundsDependOnOrientation].size.width/2, self.gridOptionsDialogView.frame.origin.y)];
            [self.gridOptionsDialogView setAlpha:0.0];
            [self.gridOptionsDialogView setDelegate:self];
            [self.view addSubview:self.gridOptionsDialogView];
        }
        
        [self.gridOptionsDialogView setSnapToGridActive:[ConfigManager isProductSnappingToWallActive]];
    }
    else
    {
        [self loadIpadGridOptionDialogView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadImageOptionDialogView{
    
    if (!self.imageOptionsDialogView) {
        self.imageOptionsDialogView =  [[[NSBundle mainBundle] loadNibNamed:@"ImageOptionsDialogView" owner:self options:nil] objectAtIndex:0];
        [self.imageOptionsDialogView setAlpha:0.0];
        [self.imageOptionsDialogView setDelegate:self];
        [self.view addSubview:self.imageOptionsDialogView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadIpadGridOptionDialogView{
    if (!self.gridOptionsViewController) {
        self.gridOptionsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"GridOptionsDialogView" inStoryboard:kRedesignStoryboard];
        [self.gridOptionsDialogView setFrame:self.view.frame];
        [self.gridOptionsViewController.view setAlpha:0.0];
        [self.gridOptionsViewController setDelegate:self];
        [self.gridOptionsViewController setSnapToGridActive:[ConfigManager isProductSnappingToWallActive]];
        [self addChildViewController:self.gridOptionsViewController];
        [self.view addSubview:self.gridOptionsViewController.view];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//add delete x for all entity
-(void)startEditing
{
    if (editingMode)
        return;
    
    UIImage* x = [UIImage imageNamed:@"circle_x.png"];
    NSMutableArray* entities;
    Entity * active = nil;
    
    if ([self.furniture3DViewController hasActiveObject]) {
        entities = [@[self.furniture3DViewController.activeEntity] mutableCopy];
        active = self.furniture3DViewController.activeEntity;
    } else {
        entities = [self.furniture3DViewController.entities mutableCopy];
    }
    
    if (entities.count > 0)
        editingMode = true;
    
    for (Entity* entity in entities)
    {
        active = entity;
        UIButton* r = [UIButton buttonWithType:UIButtonTypeCustom];
        [r addTarget:self action:@selector(removeEntity:) forControlEvents:UIControlEventTouchUpInside];
        [r setImage:x forState:UIControlStateNormal];
        r.tag = [active.key integerValue];
        CGPoint p = [self.furniture3DViewController getEntityPoint:active];
        p.y = p.y - x.size.height / 2.0f;
        p.y = MAX(0.0f, MIN(p.y, self.view.bounds.size.height - 2*x.size.height));
        p.x = p.x - x.size.width / 2.0f;
        p.x = MAX(0.0f, MIN(p.x, self.view.bounds.size.width - 2*x.size.width));
        r.frame = CGRectMake(p.x, p.y, 2*x.size.width, 2*x.size.height);
        [self.view addSubview:r];
    }
}

- (void)stopEditing {
    editingMode = false;
    
    for (UIView* view in self.view.subviews) {
        if (view.tag > 0) [view removeFromSuperview];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)adjustPressed {
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_REAL_SCALE_WIZARD withParameters:@{EVENT_PARAM_WIZARD_TRIGGER:EVENT_PARAM_VAL_BUTTON}];
    
    [self stopEditing];
    
    [self runAdjust];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)runAdjust {
    
    if(!bRunAdjust)
    {
        bRunAdjust = YES;
        
        if (self.imageView.image) {
            
            [[DesignsManager sharedInstance] workingDesign].image = self.imageView.image;
            
            [self openCubeViewController];
        }
    }
}

-(void)openCubeViewController{
    if (self.presentedViewController) {
        //hot fix
        [self performSelector:@selector(openCubeViewController) withObject:nil afterDelay:0.5];
    }else{
        CubeViewController* cubeViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"CubeViewController" inStoryboard:kRedesignStoryboard];
        cubeViewController.delegate = self;
        [self presentViewController:cubeViewController animated:YES completion:nil];
        _hasRunImageAnalysis = YES;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Style Toolbar Button
- (void)paintPressed {

    if (self.paintView) {
        [self.paintView reset];
        [self.paintView removeFromParentViewController];
        [self.paintView.view removeFromSuperview];
        [self.paintView setDelegate:nil];
        self.paintView = nil;
    }
    
    self.paintView = (PaintBaseViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"PaintView" inStoryboard:kRedesignStoryboard];
    [self.paintView.view setFrame:self.view.bounds];
    self.paintView.delegate = self;
    
    [[DesignsManager sharedInstance] workingDesign].image = self.imageView.image;
    [self.furniture3DViewController pauseRenderer];

    //defult value
    [self.paintView setPaintMode:ePaintModeColor];
    
    [self.view addSubview:self.paintView.view];
    [self addChildViewController:self.paintView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)donePressed:(id)sender {

//    [HSFlurry logAnalyticEvent:EVENT_NAME_REAL_SCALE_WIZARD withParameters:@{EVENT_PARAM_WIZARD_FINISHED: EVENT_PARAM_VAL_DONE}];

    [self doneReState];
    
    self.imageView.image = [[DesignsManager sharedInstance] workingDesign].image;
    self.furniture3DViewController.cubeVerts = [[DesignsManager sharedInstance] workingDesign].CubeVerts;
    self.furniture3DViewController.gyroData = [[DesignsManager sharedInstance] workingDesign].GyroData;
    self.furniture3DViewController.camera.fovVertical = [[[DesignsManager sharedInstance] workingDesign] fovForScreenSize:self.furniture3DViewController.view.bounds.size];
    
    [[DesignsManager sharedInstance] workingDesign].dirty = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)cancelPressed:(id)sender
{
//    [HSFlurry logAnalyticEvent:EVENT_NAME_REAL_SCALE_WIZARD withParameters:@{EVENT_PARAM_WIZARD_FINISHED: EVENT_PARAM_VAL_CANCELED}];
    [self doneReState];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)doneReState{
    
    if (self.paintView) {
        [self.paintView reset];
        [self.paintView.view removeFromSuperview];
        [self.paintView removeFromParentViewController];
    }
    
    [self.furniture3DViewController updateGLOwner];
    [self.furniture3DViewController resumeRenderer];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Catalog Toolbar Button

- (void)catalogPressed {
    [self openCatalogFromViewController];
    
    //close menu
    [self.iphoneMenuVC forceClosingMenu];
    [self.iphoneMenuVC hideMenuButton];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)openCatalogFromViewController{
    if (![ConfigManager isAnyNetworkAvailableOrOffline]) {
        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                      message:NSLocalizedString(@"failed_action_no_network_found", @"We lost you! Check your network connection.")
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    if (![CatalogMenuLogicManger sharedInstance].catalogView) {
        [CatalogMenuLogicManger sharedInstance].catalogView = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProductCatalogView"
                                                                                                             inStoryboard:kRedesignStoryboard];
    }
    
    if ([[CatalogMenuLogicManger sharedInstance].catalogView isModal]) {
        return;
    }
    
    [[CatalogMenuLogicManger sharedInstance].catalogView setDelegate:(id <ProductsCatalogDelegate>)self];
    [[CatalogMenuLogicManger sharedInstance].catalogView setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    if ([CatalogMenuLogicManger sharedInstance].showTopLevel) {
        [[CatalogMenuLogicManger sharedInstance] backToDefault];
        [[CatalogMenuLogicManger sharedInstance] setShowTopLevel:NO];
    }
    
    [self presentViewController:[CatalogMenuLogicManger sharedInstance].catalogView animated:YES completion:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadModelFromZip:(NSString*)modelId withVariationId:(NSString*)variationId
{
    NSLog(@"%@ variationId ", variationId);
    NSLog(@"%@ current variationId", self.furniture3DViewController.activeEntity.variationId);
    NSArray* components = [self.modelsCache needModel:modelId
                                          variationId:variationId
                                       andGlobalScale:[[DesignsManager sharedInstance] workingDesign].GlobalScale];
    if (components)
    {
        GraphicObject* graphicObj = components[0];
        GLKTextureInfo* textureImageInfo = components[1];
        NSDictionary* metaDict = components[2];
        
        if (self.currentlyReplacingProduct)
        {
            self.currentlyReplacingProduct = NO;
            
            NSAssert(self.entityToReplace, @"Replacing product, but no product to replace found");
            RETURN_VOID_ON_NIL(self.entityToReplace);
            
            self.entityToReplace.variationId = variationId;
            self.entityToReplace.graphicObj = graphicObj;
            self.entityToReplace.texture = textureImageInfo;
            
            [self.furniture3DViewController updateActiveEntity];
            self.entityToReplace = nil;
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        }else{
            
            GLKVector3 scaleForNewEntity = GLKVector3Make(1.0f, 1.0f, 1.0f);
            
            if (self.currentlyDuplicatingProduct && self.entityToDuplicate) {
                scaleForNewEntity = self.entityToDuplicate.scale;
                self.currentlyDuplicatingProduct = NO;
                self.entityToDuplicate = nil;
            }
            

            [self.furniture3DViewController addEntity:modelId
                                          variationId:variationId
                                              withObj:graphicObj
                                      withTextureInfo:textureImageInfo
                                         withMetadata:metaDict
                                         withPosition:(GLKVector3Make(0.0f, 0.0f, 0.0f))
                                         withRotation:(GLKVector3Make(0.0f, 0.0f, 0.0f))
                                            withScale:scaleForNewEntity];
            
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        }
        
        [[DesignsManager sharedInstance] workingDesign].dirty = YES;
    }
    else
    {
        //bad model item show error
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        
        NSString *errorMsg = [NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"failed_load_catalog_item", @"Sorry, this product is currently unavailable."), NSLocalizedString(@"failed_load_catalog_item_p2", @"Please select another product.")];
       
        [[[UIAlertView alloc]initWithTitle:@"" message:errorMsg delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];

#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED)
        {
            NSError *error = [NSError errorWithDomain:@"homestyler.com" code:42 userInfo:nil];
//            [Flurry logError:@"loadModelFromZip" message:modelId error:error];
            NSArray * objs=[NSArray arrayWithObjects:modelId, nil];
            NSArray * keys=[NSArray arrayWithObjects:@"model_id" ,nil];
//            [HSFlurry logEvent:FLURRY_LOAD_MODEL_FAILED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
#endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loadSavedModelFromZip:(Entity*)model
{
    NSAssert(!model.parentEntity, @"Cannot load from zip an assemblys child directly");
    
    if ([model isCollection])
    {
        [[self.furniture3DViewController entities] addObject:model];
        [[self.furniture3DViewController entitiesShadows] addObject:model];
        [[self.furniture3DViewController entitiesDict] setObject:model forKey:model.key];
        
        for (Entity *entity in [model uniqueModels])
        {
            NSArray* components = [self.modelsCache needModel:entity.modelId
                                                  variationId:entity.variationId
                                               andGlobalScale:1.0f];
            
            // If any of the models fail, return failure to the caller
            RETURN_ON_NIL(components, NO);
            
            GraphicObject* graphicObj = components[0];
            GLKTextureInfo* textureImageInfo = components[1];
            NSMutableDictionary* metaDict = [components[2] mutableCopy];
            [metaDict setObject:[NSNumber numberWithFloat:entity.brightness] forKey:EntityKeyBrightness];
            
            NSLog(@"Scene :: Adding model: %@ from collection: %@ to Scene",entity.modelId, model.modelId);
        
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [model alignModelsAccordingToZIndex];

                [self.furniture3DViewController addEntityFromCollection:model
                                                                modelId:entity.modelId
                                                            variationId:entity.variationId
                                                                withObj:graphicObj
                                                        withTextureInfo:textureImageInfo
                                                           withMetadata:metaDict
                                                           withPosition:entity.position
                                                           withRotation:entity.rotation
                                                              withScale:entity.scale];
                
                
            });
        }
    }
    else
    {
        NSArray* components = [self.modelsCache needModel:model.modelId
                                              variationId:model.variationId
                                           andGlobalScale:[[DesignsManager sharedInstance] workingDesign].GlobalScale];
        
        // If any of the models fail, return failure to the caller
        RETURN_ON_NIL(components, NO);
        
        GraphicObject* graphicObj = components[0];
        GLKTextureInfo* textureImageInfo = components[1];
        NSMutableDictionary* metaDict = [components[2] mutableCopy];
        [metaDict setObject:[NSNumber numberWithFloat:model.brightness] forKey:EntityKeyBrightness];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.furniture3DViewController addEntity:model.modelId
                                          variationId:model.variationId
                                              withObj:graphicObj
                                      withTextureInfo:textureImageInfo
                                         withMetadata:metaDict
                                         withPosition:model.position
                                         withRotation:model.rotation
                                            withScale:model.scale];
        });
        
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)singleModelDownloadEnded:(HSSingleModelDownloadDecriptor*)modelDescriptor
                     successFlag:(Boolean)isSucceeded
{
    if (!isSucceeded) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        return;
    }
    
    [self loadModelFromZip:modelDescriptor.modelId
           withVariationId:modelDescriptor.variationId];
    
    [self.furniture3DViewController resumeRenderer];
    
    [[HelpManager sharedInstance] presentHelpViewController:@"help_3item" withController:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)modelLiftEnded {
//    [[HelpManager sharedInstance] helpClosedForKey:@"help_lift"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

+(NSArray*)extractEntitiesFromFloorplannerJSONString:(NSString*)jsonString
{
    NSMutableArray *entitiesArray = [NSMutableArray new];
    
    NSDictionary *fpDictionary = [jsonString parseJsonStringIntoMutableDictionary];
    NSArray *productArray = [[fpDictionary objectForKey:@"Products"] allObjects];
    
    for (NSDictionary *entityDict in productArray)
    {
        [entitiesArray addObject:[Entity entityWithFloorplanDictionary:entityDict]];
    }
    
    return entitiesArray;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
//add product from catalog entrypoint
- (void)productSelected:(NSString*)productId
           andVariateId:(NSString*)variateId
             andVersion:(NSString*)timeStamp
{
#ifdef USE_UMENG
//    [MobClick event:@"model" label:productId];
#endif
    
    [[DesignsManager sharedInstance] workingDesign].dirty = YES;
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

    //update delete button
    [self.deleteButton setEnabled:YES];
    
    // First check if the product is an Assembly.
    ShoppingListItem *shoppingListItem = [[ModelsHandler sharedInstance] shoppingListItemForModelId:productId];

    if ([shoppingListItem isAssembly]){
        [self getCollection:shoppingListItem productId:productId variateId:variateId];
    }else{
        // Model was not found. Start the loading screen and download the model
        HSSingleModelDownloadDecriptor *descriptor = [HSSingleModelDownloadDecriptor new];
        descriptor.modelId = productId;
        if (variateId) {
            descriptor.variationId = variateId;
        } else {
            descriptor.variationId = productId;
        }
        
        [_modelsDownloadHandler downloadSingleModel:descriptor
                                         andVersion:timeStamp];
    }
}

-(void)getCollection:(ShoppingListItem *)shoppingListItem
           productId:(NSString*)productId
           variateId:(NSString*)variateId{
    
    
    // The following completion block will be called AFTER the scene JSON file
    // will be downloaded successfuly
    HSFDCompletionBlock completionBlock = ^(NSData* data)
    {
        RETURN_VOID_ON_NIL(data);
        
        NSMutableArray *collectionModels = [NSMutableArray array];

        NSString *sceneJson = [[NSString alloc] initWithData:data
                                                    encoding:NSUTF8StringEncoding];
        
        NSArray *extractedEntities = [MainViewController extractEntitiesFromFloorplannerJSONString:sceneJson];
        [collectionModels addObjectsFromArray:extractedEntities];
        
        NSMutableDictionary *assemblyMetadata = [NSMutableDictionary new];
        if (shoppingListItem && shoppingListItem.zedIndex) {
            [assemblyMetadata setObject:shoppingListItem.zedIndex forKey:Z_INDEX];
        }
        
        Entity *assembly = [[Entity alloc] initAsCollection:self.entityToReplace.position
                                               withRotation:self.entityToReplace.rotation
                                                  withScale:GLKVector3Make(1.0f, 1.0f, 1.0f)
                                     withMetadataDictionary:assemblyMetadata];
    
        assembly.modelId = productId;
        assembly.variationId = variateId;
        assembly.shouldApplyFloorplanFix = YES;
        
        for (Entity *collectionEntity in collectionModels)
        {
            [assembly addEntityToCollection:collectionEntity];
        }
        
        if(self.currentlyReplacingProduct){
            [self removeProduct:self.entityToReplace];
            self.entityToReplace = nil;
        }
        
        [_modelsDownloadHandler downloadModels:collectionModels
                                     allModels:collectionModels];
    };
    
    NSString *sceneGraphUrl = [shoppingListItem modelUrl];
    RETURN_VOID_ON_NIL(sceneGraphUrl);
    
    [[FileDownloadManager sharedInstance] loadFileFromUrl:sceneGraphUrl
                                                  success:completionBlock
                                                  failure:nil
                                                 progress:nil];
}

- (void)homePressed{
    if ([[DesignsManager sharedInstance] workingDesign].dirty && [ConfigManager isAnyNetworkAvailable]){
        
        _warningPopup = (WarningPopupViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"WarningPopup" inStoryboard:kRedesignStoryboard];
        [_warningPopup.view setFrame:self.view.bounds];
        _warningPopup.delegate = self;
        
        [self addChildViewController:_warningPopup];
        [self.view addSubview:_warningPopup.view];
    }else{
        [self leavePressed];
    }
}

#pragma mark- Furniture3dViewSelectionDelegate
-(void)activeObjectScaleTryWhenLocked{
    
    self.furniture3DViewController.contourColorChange = YES;
    self.furniture3DViewController.contourColorChange = NO;
    
    [self showScaleDialog:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)activeObjectSelected:(Entity*)entity
{    
    if ([ConfigManager isLevitateButtonActive]) {
        
        //clear prevoius button
        if (self.levitateButton) {
            [self.levitateButton removeFromSuperview];
            self.levitateButton = nil;
        }
        
        [self addLevitateButton];
    }
    
    //clear prevoius button
    if (self.productInfoButton) {
        [self.productInfoButton removeFromSuperview];
        self.productInfoButton = nil;
    }
    
    [self addInfoButton];

    if ([self.productTagBaseView.view superview]!=nil) {
        [self.productTagBaseView closeProductInfoView:nil];
    }
}

-(void)activeObjectDeselected {
    [self.productInfoButton removeFromSuperview];
    [self.levitateButton removeFromSuperview];
    
    if ([self.productTagBaseView.view superview]!=nil && self.productTagBaseView.holdViewWhileSwitchingObjects==NO) {
        
        [self closeProductInfoView];
    }
    self.productTagBaseView.holdViewWhileSwitchingObjects=NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

// This function should always be called on the main thread
-(void)updateProductInfoButtonForEntity:(Entity*)entity
{
    DISPATCH_ASYNC_ON_MAIN_QUEUE(
                                 ModelBoundingBox *entityBoundingBox = [entity getEntityBoundingBox];
                                 
                                 GLKVector3 upperLeftEntityCorner = GLKVector3Make(entityBoundingBox.minX,
                                                                                   entityBoundingBox.maxY,
                                                                                   entityBoundingBox.minZ);
                                
                                 
                                 upperLeftEntityCorner = GLKVector3Multiply(upperLeftEntityCorner, entity.scale);
                                 
                                 CGPoint pUpperLeft = [self.furniture3DViewController getEntityPoint:entity
                                                                                          withOffset:upperLeftEntityCorner];
                                 
                                 
                                 pUpperLeft.y = MAX(self.productInfoButton.frame.size.height * 2.2,
                                                    MIN(pUpperLeft.y, self.view.bounds.size.height - self.productInfoButton.frame.size.height * 2));
                                 
                                 pUpperLeft.x = MAX(self.productInfoButton.frame.size.width,
                                                    MIN(pUpperLeft.x, self.view.bounds.size.width - self.productInfoButton.frame.size.width));
                                 
                                 self.productInfoButton.center = CGPointMake(pUpperLeft.x, pUpperLeft.y - self.productInfoButton.frame.size.height/2);
                                 
                                 if ([ConfigManager isLevitateButtonActive]) {
                                     GLKVector3 lowerRightEntityCorner = GLKVector3Make(entityBoundingBox.maxX,
                                                                                        entityBoundingBox.minY,
                                                                                        entityBoundingBox.minZ);
                                     lowerRightEntityCorner = GLKVector3Multiply(lowerRightEntityCorner, entity.scale);
                                     
                                     CGPoint pLowerRight = [self.furniture3DViewController getEntityPoint:entity
                                                                                               withOffset:lowerRightEntityCorner];
                                     
                                    self.levitateButton.center = CGPointMake(pLowerRight.x + self.levitateButton.frame.size.width/2,
                                                                             pLowerRight.y + self.levitateButton.frame.size.height/2);
                                    
                                 });
}


-(void)addInfoButton{
    NSString* strIcon = IS_IPAD ? @"product_tag_icon.png" : @"iph_product_tag_icon.png";
    NSString* strIconPressed = IS_IPAD ? @"product_tag_icon_press.png" : @"iph_product_tag_icon_press.png";
    
    UIImage* x = [UIImage imageNamed:strIcon];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:x forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:strIconPressed] forState:UIControlStateHighlighted];
    btn.frame = IS_IPAD ? CGRectMake(0, 0, 45, 45) : CGRectMake(0, 0, 31, 31);
    
    [btn addTarget:self action:@selector(openProductInfoForEntity:) forControlEvents:UIControlEventTouchUpInside];
    self.productInfoButton = btn;
    
    if ([self.productInfoButton superview] == nil) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView * loadingView = [self.view viewWithTag:LOADING_VIEW_TAG];
            if (loadingView) {
                [self.view insertSubview:self.productInfoButton belowSubview:loadingView];
            }else{
                [self.view addSubview:self.productInfoButton];
            }
        });
    }
}

-(void)addLevitateButton{

    self.levitateButton = [[LevitateView alloc] initWithFrame:IS_IPAD ? CGRectMake(0, 0, 40, 100) : CGRectMake(0, 0, 30, 67)];

    if ([self.levitateButton superview] == nil) {
        [self.furniture3DViewController.view addSubview:self.levitateButton];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - WarningPopupDelegate
- (void)saveDesignOnExit{
    
    isSaveRequestedBeforeLeave = YES;
    [self savePressed];
}

- (void)leavePressed
{
    [self exitDesign:YES];
}

- (void)exitDesign:(BOOL)animated
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [DesignsManager sharedInstance].workingDesign = nil;
    
    // Reset the paint view controller
    [self.paintView reset];
    [self.paintView removeFromParentViewController];
    [self.paintView.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"designSaveOnExitNotification" object:nil];
    _productCatalogView.delegate = nil;
    _modelsDownloadHandler.delegate = nil;
    _modelsDownloadHandler = nil;
    _saveDesignFlow.designDelegate = nil;
    
    [_warningPopup.view removeFromSuperview];
    [_warningPopup removeFromParentViewController];
    [_warningPopup setDelegate:nil];
    
    self.imageOptionsView = nil;
    self.furniture3DViewController = nil;
    self.imageView.image = nil;
    
    [[UIManager sharedInstance] setMainViewController:nil];
    
    //deallocate this memory temporarily until it becomes visible again.
    [appDelegate.glkView deleteDrawable];
    
    [appDelegate glkView].delegate = nil;
    
    //When leaving the redesign process, enable memory caching again
    [[ImageFetcher sharedInstance]setMemoryCachingEnabled:YES];
    
    [self.furniture3DViewController clearScene];
    [self.modelsCache clearCache];
    
    if (!IS_IPAD) {
        // Reset the iphoneMenuVC view controller
        [self.iphoneMenuVC.view removeFromSuperview];
        [self.iphoneMenuVC removeFromParentViewController];
        [self setIphoneMenuVC:nil];
        
        [self dismissViewControllerAnimated:animated completion:nil];
    }else{
        if (self.shouldGoToRoot) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    [CatalogMenuLogicManger sharedInstance].searchHistory = nil;
}

/////////////////////////////////////////////////////////
//          Shsre methods                              //
/////////////////////////////////////////////////////////

#pragma mark - Share
- (void)sharePressed {
    [self sharePressedWhileUserIsSignedIn];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)sharePressedWhileUserIsSignedIn
{
    [self stopEditing];
    
    if (IS_IPAD)
    {
        if ([[[DesignsManager sharedInstance] workingDesign] dirty])
        {
            [self savePressed];
        }
        else
        {
            [[DesignsManager sharedInstance] workingDesign].ImageWithFurnitures = [self getScreenShot];
            
            if([_saveDesignFlow.view isHidden] == YES)
            {
                
                [_saveDesignFlow openShareDialog:ShareScreenModeOpenByUser];
                [_saveDesignFlow.view setHidden:NO];
                [self.view bringSubviewToFront:_saveDesignFlow.view];
                
            }
            else
            {    [self.view addSubview:_saveDesignFlow.view];
                [self addChildViewController:_saveDesignFlow];
                [_saveDesignFlow openShareDialog:ShareScreenModeOpenByUser];
                
            }
            
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_OPEN withParameters:@{
//                                                                                 EVENT_PARAM_UI_ORIGIN:EVENT_PARAM_VAL_UISOURCE_DESIGN_TOOL
//                                                                                 }];
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_DESIGN withParameters:@{EVENT_PARAM_ORGIN: EVENT_PARAM_VAL_3D}];
        }
        
    }else{
        
        if ([[[DesignsManager sharedInstance] workingDesign] dirty]) {
            [self savePressed:nil];
        }else{
            [[DesignsManager sharedInstance] workingDesign].ImageWithFurnitures = [self getScreenShot];
            
            if([_saveDesignFlow.view isHidden] == YES)
            {
                [_saveDesignFlow.view setHidden:NO];
                [self.view bringSubviewToFront:_saveDesignFlow.view];
                [_saveDesignFlow.saveDesignDialog refreshSaveDialog];
                [_saveDesignFlow openShareDialog:ShareScreenModeOpenByUser];
            }
            else
            {    [self.view addSubview:_saveDesignFlow.view];
                [self addChildViewController:_saveDesignFlow];
                [_saveDesignFlow.saveDesignDialog refreshSaveDialog];
                [_saveDesignFlow openShareDialog:ShareScreenModeOpenByUser];
            }
            
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_UI_OPEN withParameters:@{
//                                                                                 EVENT_PARAM_UI_ORIGIN:EVENT_PARAM_VAL_UISOURCE_DESIGN_TOOL
//                                                                                 }];
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SHARE_DESIGN withParameters:@{EVENT_PARAM_ORGIN: EVENT_PARAM_VAL_3D}];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)savePressediPhoneInternal :(BOOL) bAlreadyLogged{
    if(bAlreadyLogged == NO)
    {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_SAVE_DESIGN, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_SAVEDESIGN}];
        [[UIMenuManager sharedInstance] loginRequestedIphone:self loadOrigin:EVENT_PARAM_LOAD_ORIGIN_SAVEDESIGN ];
    }
    else
    {
        if (!self.originalDesignObject) {
            self.originalDesignObject=[[GalleryItemDO alloc] init];
            self.originalDesignObject.author=[[[UserManager sharedInstance] currentUser]getUserFullName];
        }
        
        [self saveWorkingDesignState];
        
        [self handleSaveDesignVc];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveLogicIsUserLogedIn :(BOOL)bAlreadyLogged
{
    if(bAlreadyLogged == NO)
    {
        [[UIMenuManager sharedInstance] loginRequestedIpad:self loadOrigin:EVENT_PARAM_LOAD_ORIGIN_SAVEDESIGN ];
    }
    else
    {
        [self saveWorkingDesignState];
        
        if (!self.originalDesignObject) {
            self.originalDesignObject = [[GalleryItemDO alloc] init];
            self.originalDesignObject.author = [[[UserManager sharedInstance] currentUser] getUserFullName];
        }
        
        [self handleSaveDesignVc];
    }
}

-(void)saveWorkingDesignState{
    [[DesignsManager sharedInstance] workingDesign].date = [NSDate date];
    [[DesignsManager sharedInstance] workingDesign].models = self.furniture3DViewController.entities;
    [[[DesignsManager sharedInstance] workingDesign] generateUniqueuId];
}

-(void)handleSaveDesignVc{
    
    if([_saveDesignFlow.view isHidden] == YES)
    {
        [_saveDesignFlow.view setHidden:NO];
        [self.view bringSubviewToFront:_saveDesignFlow.view];
    }
    else
    {
        [self.view addSubview:_saveDesignFlow.view];
        [self addChildViewController:_saveDesignFlow];
    }
    
    [_saveDesignFlow.saveDesignDialog refreshSaveDialog];
    [_saveDesignFlow openSaveDialog];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)savePressed {
    
    [self stopEditing];

    if([[ReachabilityManager sharedInstance] isConnentionAvailable] && [[UserManager sharedInstance] isLoggedIn] == NO)
    {
        [[UIManager sharedInstance] setIsRedirectToLogin:YES];
        
        if(IS_IPAD) {
            [self saveLogicIsUserLogedIn:NO];
        }else{
            [self savePressediPhoneInternal:NO];
        }
    } else {
        if(IS_IPAD) {
            [self saveLogicIsUserLogedIn:YES];
        }else{
            [self savePressediPhoneInternal:YES];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)saveDesign:(NSString*)name {
    if([name length] == 0)
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
        
        NSString* dateString = [formatter stringFromDate:[NSDate date]];
        [[DesignsManager sharedInstance] workingDesign].name = dateString;
    }
    else
    {
        [[DesignsManager sharedInstance] workingDesign].name = name;
    }
    
    [self saveWorkingDesignState];
}

- (void)saveDesignPopupClosedOnCancel
{
    if (isSaveRequestedBeforeLeave) {
        isSaveRequestedBeforeLeave=NO;
    }
}

-(void)saveDesignPopupClosed
{
    [[DesignsManager sharedInstance] workingDesign].dirty = NO;
    [[CatalogMenuLogicManger sharedInstance] setSelectedCategoryId:nil];
   
    if (isSaveRequestedBeforeLeave) {
        isSaveRequestedBeforeLeave = NO;
    }
}

-(void)recheckAllModelsAddedToScene
{    
    if (self.isDownloadCompleted  &&
        [[DesignsManager sharedInstance] workingDesign].image)
    {
        self.currentlyReplacingProduct = NO;
        
        [[DesignsManager sharedInstance] workingDesign].models = self.furniture3DViewController.entities;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //do the first save manualy not wait for the timer
            [[DesignsManager sharedInstance] performAutoSavingAsync];
        });
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)finishedDownloadingAllModels
{
    [self.furniture3DViewController resumeRenderer];

    self.isDownloadCompleted = YES;
    
    [self recheckAllModelsAddedToScene];
    
    [[HelpManager sharedInstance] presentHelpViewController:@"help_3item" withController:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)finishedDownloadingModels:(NSArray*)models
{
    BOOL isAllLoaded = YES;
    NSMutableSet *collectionModels = [NSMutableSet new];
    for(Entity *savedEntity in models)
    {
        // If an entity is a part of an assembly, add it to the list of assemblies that needs
        // to be added to the scene
        if (savedEntity.parentEntity)
        {
            [collectionModels addObject:savedEntity.parentEntity];
            continue;
        }
        
        if (![self loadSavedModelFromZip:savedEntity])
        {
            isAllLoaded = NO;
        }
    }
    
    // For every assembly we downloaded, load it if and only if all it's models were downloaded
    for (Entity *collection in collectionModels)
    {
        NSArray *cachedModels = [[ModelsHandler sharedInstance] getCachedModelsFromArray:collection.nestedEntities];
        if ([cachedModels count] != [collection.nestedEntities count])
        {
            NSLog(@"Finished downloading %lu models for collection: %@,\
                  however not all collection models were downloaded.\
                  Waiting for rest of models",(unsigned long)[cachedModels count], collection.modelId);
            
            isAllLoaded = NO;
        }
        
        
        if (![self loadSavedModelFromZip:collection])
        {
            isAllLoaded = NO;
        }
    }
    
    if (!isAllLoaded) {
        // TODO: popup the error message
    }
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)modelsDownloadedEndedWithErrors:(int)succededDownloadCount
                            errorsCount:(int)errorsCount
                          isSingleModel:(BOOL)isSingleModel
{
    
    if(isSingleModel)
    {
        
        NSString *errorMsg = [NSString stringWithFormat:@"%@ %@",
                              NSLocalizedString(@"failed_load_catalog_item",
                                                @"Sorry, this product is currently unavailable."),
                              NSLocalizedString(@"failed_load_catalog_item_p2",
                                                @"Please select another product.")];
        
        [[[UIAlertView alloc]initWithTitle:@""
                                   message:errorMsg
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")
                         otherButtonTitles: nil] show];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)removedEntity:(NSString *)modelId andVariationId:(NSString*)variationId
{
    if ([self.furniture3DViewController.entities count] == 0) {
        [self.deleteButton setEnabled:NO];
    }
    
    [self.modelsCache releaseModel:modelId
                    andVariationId:variationId];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadModels{
    
    SavedDesign * savedDesign = [[DesignsManager sharedInstance] workingDesign];

    NSMutableArray *fullModelList = [NSMutableArray new];
    for (Entity *entity in savedDesign.models)
    {
        if ([entity isCollection])
        {
            [fullModelList addObjectsFromArray:[entity uniqueModels]];
        }
        else
        {
            [fullModelList addObject:entity];
        }
    }
    
    if ([ConfigManager isDesignLayersActive]) {
        [[DesignsManager sharedInstance] getMetadataForDesignModels];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
        NSArray* cachedModels = [[ModelsHandler sharedInstance] getCachedModelsFromArray:fullModelList];
        
        // (2) Find the subset of models that remain to download
        NSPredicate *relativeComplement = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", cachedModels];
        NSArray *modelsToDownload = [fullModelList filteredArrayUsingPredicate:relativeComplement];
        
        // (3) If we have anything to download we start the process and return
        if ([modelsToDownload count] > 0)
        {
            [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
            
            NSArray* modelsToDownloadArr = [[NSSet setWithArray:modelsToDownload] allObjects]; //remove duplicates
            [_modelsDownloadHandler downloadModels:modelsToDownloadArr
                                         allModels:fullModelList];
        }else{
            if ([fullModelList count] > 0) {
                [self extractAllModelFromDevice:fullModelList];
            }
        }
    });
}

-(void)extractAllModelFromDevice:(NSArray*)fullModelList{
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    // (4) If everything is in cache, alert that we finished downloading all models
    if([self finishedDownloadingModels:fullModelList])
    {
        [self finishedDownloadingAllModels];
        [self.furniture3DViewController updateFloor];
    }
    
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) updateBGImage{
    
    SavedDesign *design = [[DesignsManager sharedInstance] workingDesign];
    [self changeBackgroundBrightness:design.bgBrightness];
    
    [self.furniture3DViewController updateBackgroundColor];
    
    if ([[DesignsManager sharedInstance] workingDesign] != nil &&
        ([[DesignsManager sharedInstance] workingDesign].GyroData == nil ||
         [[DesignsManager sharedInstance] workingDesign].CubeVerts == nil)){
            
        if (bViewDidAppear) {
            if (!bRunAdjust) {
//                [HSFlurry logAnalyticEvent:EVENT_NAME_REAL_SCALE_WIZARD withParameters:@{EVENT_PARAM_WIZARD_TRIGGER:EVENT_PARAM_VAL_PHOTO}];
            }
            
            [self runAdjust];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
//                      IBActions                                           //
//////////////////////////////////////////////////////////////////////////////

- (IBAction)backPressed:(id)sender {
    [self closeProductInfoView];
    self.shouldGoToRoot = NO;
    [self homePressed];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)sharePressed:(id)sender
{
#ifdef USE_UMENG
//    [MobClick event:@"share"];
#endif
    
    [self closeProductInfoView];
    if([[UserManager sharedInstance] isLoggedIn] == NO && ([[[DesignsManager sharedInstance] workingDesign]dirty]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"redesign_sign_in_to_save_and_share_your_design.",@"User sign in required") delegate:self cancelButtonTitle:NSLocalizedString(@"redesign_sign_in_cancel_button",@"redesign cancel button title") otherButtonTitles:NSLocalizedString(@"redesign_sign_in_sign_in_button",@"redesign sign in button title"), nil];
        alert.tag = AlertTypeShareSignInRequired;
        [alert setAccessibilityLabel:@"redesign_sign_in_to_save_and_share_your_design_alert"];
        [alert show];
    }
    else if ([[[DesignsManager sharedInstance] workingDesign] dirty])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"redesign_sign_in_to_save",@"User sign in required") delegate:self cancelButtonTitle:NSLocalizedString(@"redesign_sign_in_cancel_button",@"redesign cancel button title") otherButtonTitles:NSLocalizedString(@"redesign_save_button",@"redesign save button title"), nil];
        alert.tag = AlertTypeShareSignInRequired;
        [alert show];
    }
    else
    {
        [self sharePressedWhileUserIsSignedIn];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)catalogPressed:(id)sender {
    
#ifdef USE_UMENG
//    [MobClick event:@"catalog"];
#endif
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_CATALOG withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_DESIGN_TOOL}];
    [self closeProductInfoView];
    [self catalogPressed];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)paintPressed:(id)sender
{
    [self closeProductInfoView];
    [self paintPressed];
}


////////////////////////////////////////////////////////////////
//                  ImageOptionsDialogViewDelegate            //
////////////////////////////////////////////////////////////////

#pragma mark - ImageOptionsDialogViewDelegate
-(void)concealClicked{
    [self chooseImageOption:IMAGE_OPTION_CONCEAL];
    [self closeImageOptionsDialogView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)brightnessClicked{
    [self chooseImageOption:IMAGE_OPTION_BRIGHTNESS];
    [self closeImageOptionsDialogView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)closeImageOptionsDialogView{
    [UIView animateWithDuration:0.3 animations:^{
        self.imageOptionsDialogView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)closeGridOptionsDialogView{
    [UIView animateWithDuration:0.3 animations:^{
        self.gridOptionsDialogView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

////////////////////////////////////////////////////////////////
//                  Class Function                            //
////////////////////////////////////////////////////////////////

#pragma mark - Class Function
- (void)imageOptionsDialogViewPressed:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat height = [UIScreen currentScreenBoundsDependOnOrientation].size.height;
        CGFloat width = [UIScreen currentScreenBoundsDependOnOrientation].size.width;
        
        [self.imageOptionsDialogView setFrame:CGRectMake(0, 0, width, height)];
        [UIView animateWithDuration:0.3 animations:^{
            self.imageOptionsDialogView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:self.imageOptionsDialogView];
        }];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)iphonePaintPressed:(id)sender
{
    [self paintPressed];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)realScaleClicked
{
    if (![self showScaleDialog:YES])
    {
        [self closeProductInfoView];
        [self adjustPressed];
        [self closeGridOptionsDialogView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)scalePressed:(id)sender
{
    if (IS_IPAD)
    {
        // check if any extra grid options are available to the user , if not activate 'RealScale' method.
        [self closeProductInfoView];
        if ([ConfigManager isShowGridActive] == NO && [ConfigManager isProductSnappingToWallActive] == NO)
        {
            [self realScaleClicked];
        }
        else
        {
            [self.gridOptionsViewController.view setFrame:self.view.frame];
            [self addChildViewController:self.gridOptionsViewController];
            [self.gridOptionsViewController.view setAlpha:0];
            [self.gridOptionsViewController.view setHidden:NO];
            [self.gridOptionsViewController.optionsContainerView setCenter:CGPointMake([(UIButton *)sender center].x,self.gridOptionsViewController.optionsContainerView.center.y)];
            
            self.gridOptionsViewController.view.alpha = 1;
            [self.gridOptionsViewController setDelegate:self];
            [self.view addSubview:self.gridOptionsViewController.view];
        }
    }
    else
    {
        // check if any extra grid options are available to the user , if not activate 'RealScale' method.
        if ([ConfigManager isShowGridActive] == NO && [ConfigManager isProductSnappingToWallActive] == NO)
        {
            [self realScaleClicked];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.gridOptionsDialogView setSnapToGridActive:[ConfigManager isProductSnappingToWallActive]];
                [self.gridOptionsDialogView.optionsContainerView setCenter:CGPointMake([UIScreen currentScreenBoundsDependOnOrientation].size.width/2, [UIScreen currentScreenBoundsDependOnOrientation].size.height/2)];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.gridOptionsDialogView.alpha = 1;
                } completion:^(BOOL finished) {
                    [self.view bringSubviewToFront:self.gridOptionsDialogView];
                    
                }];
            });
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)showScaleDialog:(BOOL)shouldDisplayRealScaleOnUnlock
{
    if (![[[DesignsManager sharedInstance] workingDesign] isScalingLocked])
        return NO;
    
    if (!self.alertShowing) {
        self.alertShowing = YES;

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"scale_lock_alert_copy_title", @"")
                                                         message:NSLocalizedString(@"scale_lock_alert_copy", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"scale_lock_alert_btn1", @"")
                                               otherButtonTitles:NSLocalizedString(@"scale_lock_alert_btn2", @""), nil];
        
        alert.tag = AlertTypeScaleNoRealScale;
        if (shouldDisplayRealScaleOnUnlock) {
            alert.tag = AlertTypeScaleRealScale;
        }
        
        [alert setAccessibilityLabel:@"scale_lock_alert_copy_alert"];
        [alert show];
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) loginRequestEndedwithState:(BOOL) state
{
    if (state==NO) {
        return;
    }
    
    [self saveWorkingDesignState];
    
    [[DesignsManager sharedInstance] workingDesign].ImageWithFurnitures = [self getScreenShot];
    
    [self performSelector:@selector(handleSaveDesignVc) withObject:nil afterDelay:0.4];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL) onProgressTimeoutNotification
{
    return YES;
}

////////////////////////////////////////////////////////////////
//                 UIAlertViewDelegate                        //
////////////////////////////////////////////////////////////////

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.alertShowing = NO;
    
    if (1 == buttonIndex)
    {
        switch (alertView.tag)
        {
            case AlertTypeShareSignInRequired:
            {
                [self sharePressedWhileUserIsSignedIn];
                return;
            } break;
                
            case AlertTypeSaveSignInRequired:
            {
                [self closeProductInfoView];
                [self savePressed];
                return;
                
            } break;
                
            default: break;
        };
    }
    
    if ([[alertView message]isEqualToString:NSLocalizedString(@"scale_lock_alert_copy", @"")]) {
        
        switch (buttonIndex) {
            case 0:
            {
//                [HSFlurry logAnalyticEvent:EVENT_NAME_UNLOCK_REALSCALE
//                            withParameters:@{EVENT_PARAM_SCALE_LOCK_STATUS:EVENT_PARAM_VAL_UNLOCK}];
                
                SavedDesign *design = [[DesignsManager sharedInstance] workingDesign];
                [design changeScaleLock:NO];
                
                if (AlertTypeScaleRealScale == alertView.tag)
                {
                    [self closeGridOptionsDialogView];
                    [self runAdjust];
                }
                
            } break;
            case 1:
            {
                //do nothing, user don't want to change scale
//                [HSFlurry logAnalyticEvent:EVENT_NAME_UNLOCK_REALSCALE withParameters:@{EVENT_PARAM_SCALE_LOCK_STATUS: EVENT_PARAM_VAL_LOCK}];
            } break;
            default: break;
        }
    }
}

////////////////////////////////////////////////////////////////
//                 Product Tag actions                        //
////////////////////////////////////////////////////////////////

#pragma mark- Product Tag actions

-(void)openProductInfoForEntity:(id)sender{
    //tomer
    Entity *entity = [self.furniture3DViewController activeEntity];
    SavedDesign * design = [[DesignsManager sharedInstance] workingDesign];
    
    if (entity==nil || design==nil) {
        return;
    }
    
    if ([self.productTagBaseView.view superview] == nil)
    {
        // move menu to location and set alpha to zero (0.01)
        CGRect rect = CGRectZero;
        if (IS_IPAD)
        {
            CGRect size= [UIScreen currentScreenBoundsDependOnOrientation];
            NSInteger originX = size.size.width - self.productTagBaseView.view.frame.size.width ;
            // callculate the frame for product info view with top menu view
            rect=CGRectMake(originX, 52, self.productTagBaseView.view.frame.size.width,[UIScreen currentScreenBoundsDependOnOrientation].size.height - 52 );
        }
        else
        {
            rect = CGRectMake([UIScreen currentScreenBoundsDependOnOrientation].size.width -self.productTagBaseView.view.frame.size.width,
                              0,
                              self.productTagBaseView.view.frame.size.width,
                              [UIScreen currentScreenBoundsDependOnOrientation].size.height);
        }
        
        self.productTagBaseView.view.alpha = 0.01;
        self.productTagBaseView.view.frame = rect;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.productTagBaseView.view.alpha = 1;
        } completion:nil];
        
        [self.productTagBaseView updateCurrentProductInfo:entity];
        [self addChildViewController: self.productTagBaseView];
        [self.view addSubview:self.productTagBaseView.view];
    }
    else
    {
        [self closeProductInfoView];
    }
}

////////////////////////////////////////////////////////////////
//                 ProductTagActionsDelegate                  //
////////////////////////////////////////////////////////////////

#pragma mark- ProductTagActionsDelegate
-(void)removeProduct:(Entity*)entity
{
    RETURN_VOID_ON_NIL(entity);
    [self closeProductInfoView];
    [self.productTagBaseView removeProductAfterConfirm];

    [[DesignsManager sharedInstance] workingDesign].dirty = YES;
    
    [self.furniture3DViewController removeEntity:[entity.key intValue]];

    
    if (self.furniture3DViewController.entities.count == 0) {
        [self stopEditing];
    }
}

- (void)removeEntity:(id)sender
{
    [[DesignsManager sharedInstance] workingDesign].dirty = YES;
    
    UIButton* removeButton = (UIButton*)sender;
    [self.furniture3DViewController removeEntity:removeButton.tag];
    [removeButton removeFromSuperview];
    
    if (self.furniture3DViewController.entities.count == 0)
        [self stopEditing];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)resetScaleForProduct:(Entity*)entity{
    if (entity) {
        [self.furniture3DViewController resetObjectScale:entity];
    }
}

- (void)adjustBrightnessForProduct:(Entity*)entity brightness:(float)val{
    if (entity) {
        [self.furniture3DViewController adjustObject:entity brightness:val];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)openInteralWebViewWithUrl:(NSString *)url{
    NSString *selectedUrl = [url copy];
    if ([ConfigManager isReDirectToMarketPlaceActive]) {
        selectedUrl = [ConfigManager getMarketPlaceUrl];
    }
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:selectedUrl];
    [self presentViewController:web animated:YES completion:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)duplicateProduct:(Entity*)entity
{
    if (!entity)
        return;
    
    self.entityToDuplicate = self.furniture3DViewController.activeEntity;
    
    self.currentlyDuplicatingProduct = YES;
    
//    [self productSelected:entity.modelId
//             andVariateId:entity.variationId
//               andVersion:timestamp];
    [self loadModelFromZip:entity.modelId
           withVariationId:entity.variationId];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) closeProductInfoView
{
    if (self.productTagBaseView && [self.productTagBaseView.view superview]!=nil)
    {
        self.iphoneCatalogButton.hidden = NO;
        [self.productTagBaseView closeProductInfoView:nil];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)productEntityWithProductId:(NSString*)productId{
    
    self.entityToReplace = self.furniture3DViewController.activeEntity;
    
    self.currentlyReplacingProduct = YES;
    
    [self productSelected:productId
             andVariateId:nil
               andVersion:nil];
}

- (void)variateEntity:(Entity*)entity withVariationId:(NSString*)variationId
{
    if ([entity isKindOfClass:[Entity class]]) {
        
        self.currentlyReplacingProduct = YES;
        self.entityToReplace = entity;
        NSLog(@"Entity modelId: %@ for variation: %@",entity.modelId,variationId);
        [self productSelected:entity.modelId
                 andVariateId:variationId
                   andVersion:@""];
        
        
        // set family data for product info view before replacing the entity
        if (self.productTagBaseView.isProductReplacedFromFamily == NO)
        {
            [self.productTagBaseView setIsProductReplacedFromFamily:YES];
        }
    }
}

////////////////////////////////////////////////////////////////
//                 SaveDesignPopupDelegate                   //
////////////////////////////////////////////////////////////////

#pragma mark - SaveDesignPopupDelegate
-(NSString*)getDesignName{
    if (self.originalDesignObject && [NSString notEmpty:self.originalDesignObject.title]) {
        return self.originalDesignObject.title;
    }
    return @"";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*)generateShareUrl{
    
    NSString *linkUrl=@"";
    
    if([[DesignsManager sharedInstance] workingDesign].publicDesignID != nil)
    {
        linkUrl = [[ConfigManager sharedInstance] generateShareUrl:@"1" : [[DesignsManager sharedInstance] workingDesign].publicDesignID] ;
    }
    else{
      
//        NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
//        linkUrl=[[[dict objectForKey:@"share"] objectForKey:@"url"] objectForKey:@"link"];
//        NSLog(@"%@",linkUrl);

    }

    
    return linkUrl;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(NSString*)getDesignOwner{
    
    
    if (self.originalDesignObject && [NSString notEmpty:self.originalDesignObject.author]) {
        return self.originalDesignObject.author;
    }
    return @"";
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)updateDesignTitle:(NSString*)title andDescription:(NSString*)desc andURL:(NSString*)url{
    if (!self.originalDesignObject) {
        self.originalDesignObject=[[GalleryItemDO alloc] init];
    }

    if ([[self getDesignOwner] isEqualToString:[[[UserManager sharedInstance] currentUser] getUserFullName]]) {
        self.originalGalleryItem.url=url;
    }
    
    self.originalDesignObject.title=title;
    self.originalDesignObject._description=desc;
    self.originalDesignObject.url=url;
    self.originalDesignObject.author=[[[UserManager sharedInstance] currentUser] getUserFullName];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(UIImage*)getScreenShot
{    
    // get the background image
    UIImage * bottomImage=[UIImage imageWithView:self.imageView];
    
    // get the current furniture rendering frame
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate glkVC].paused = YES;
    
    if (![[appDelegate.glkView superview] isEqual:self.furniture3DViewController.view]) {
        [self.furniture3DViewController.view addSubview:appDelegate.glkView];
    }
    
    /*The following needed for iphone save design as the GLKView looses its context  and the snapshot will be empty*/
    appDelegate.glkVC.delegate = self.furniture3DViewController;
    appDelegate.glkView.contentScaleFactor = [UIScreen mainScreen].scale;
    appDelegate.glkView.delegate = self.furniture3DViewController;
    [appDelegate.glkView bindDrawable];
    [appDelegate.glkView display];
    
    UIImage* furniture = [self.furniture3DViewController snapshot];
    
    [appDelegate glkVC].paused = NO;
    
    CGRect finalRect = CGRectMake(0,0,furniture.size.width,furniture.size.height);
    
    UIGraphicsEndImageContext();
    
    // combine the images
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(finalRect.size.width,
                                                      finalRect.size.height),NO,0.0);
    [bottomImage drawInRect:finalRect];
    [furniture drawInRect:finalRect];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage * resizedImage = [viewImage scaleToFitLargestSideWithScaleFactor:1280 scaleFactor: viewImage.scale supportUpscale:NO];
    
    return resizedImage;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)backPressedOnIphoneAfterSave{
    [self closeProductInfoView];
    [[DesignsManager sharedInstance] disregardCurrentAutoSaveObject];
    [self leavePressed];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)saveRequestedBeforeLeave{
    return isSaveRequestedBeforeLeave;
}

#pragma mark - ScengeSnapshotDelegate
-(void)performRender:(CGSize)targetSize
{
    // render the furnitures in the offscreen buffer
    float tFov = self.furniture3DViewController.camera.fovVertical;
    glViewport(0, 0, targetSize.width, targetSize.height);
    
    // update fov
    SavedDesign *savedDesign = [[DesignsManager sharedInstance] workingDesign];
    self.furniture3DViewController.camera.fovVertical = [savedDesign fovForScreenSize:targetSize];
    
    //update ratio
    GLfloat ratio = (GLfloat) targetSize.width / targetSize.height;
    [self.furniture3DViewController updateProjectionWithRatio:ratio];
    
    [self.furniture3DViewController glkViewControllerUpdate:nil];
    [self.furniture3DViewController render:[DrawMode normalDrawMode] highlight:NO];
    self.furniture3DViewController.camera.fovVertical = tFov;
}

////////////////////////////////////////////////////////////////
//                 Grid Options methods                       //
////////////////////////////////////////////////////////////////

#pragma mark - Grid Options methods
- (void)chooseGridOption:(GridOptions)gridOptionPicked
{
    // Switch the user's choice for painting
    switch(gridOptionPicked) {
        case GRID_OPTION_NONE:
            [self.gridOptionsViewController.view setAlpha:0.0];
            [self.gridOptionsViewController.view setHidden:YES];
            
            break;
        case GRID_OPTION_REAL_SCALE:
        {
            [self.gridOptionsViewController.view setAlpha:0.0];
            [self.gridOptionsViewController.view setHidden:YES];
            if (![self showScaleDialog:YES])
            {
                [self closeProductInfoView];
                [self adjustPressed];
            }
        }
            break;
        case GRID_OPTION_SNAP_TO_GRID:
            break;
        default: break;
    }
}

////////////////////////////////////////////////////////////////
//                 Image Options methods                      //
////////////////////////////////////////////////////////////////

#pragma mark - Image Options methods
- (void)chooseImageOption:(ImageOptions)imageOptionPicked
{
    // Hide the Image Options View
    [self.imageOptionsView.view setAlpha:0.0];
    [self.imageOptionsView.view setHidden:YES];
    
    // Switch the user's choice for painting
    switch(imageOptionPicked) {
        case IMAGE_OPTION_NONE:
            break;
        case IMAGE_OPTION_BRIGHTNESS:
            [self openBrightnessImageOption];
            break;
        case IMAGE_OPTION_CONCEAL:
            [self openClearRoomAction];
            break;
        default: break;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)imageOptionsPressed:(id)sender
{
    [self closeProductInfoView];
    [self.imageOptionsView.view setFrame:self.view.frame];
    [self addChildViewController:self.imageOptionsView];
    [self.view addSubview:self.imageOptionsView.view];
    [self.imageOptionsView.view setAlpha:0];
    [self.imageOptionsView.view setHidden:NO];
    [self.imageOptionsView.containerView setCenter:CGPointMake([(UIButton *)sender center].x , self.imageOptionsView.containerView.center.y)];
    [UIView animateWithDuration:0.3 animations:^{
        self.imageOptionsView.view.alpha = 1;
    }];
    [self.imageOptionsView setDelegate:self];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)openBrightnessImageOption
{
    ImageBackgroundEffectsViewController *ibevc = [ControllersFactory instantiateViewControllerWithIdentifier:@"ImageBackgroundEffectsViewController"
                                                                                                 inStoryboard:kRedesignStoryboard];
    ibevc.delegate = self;
    [ibevc initBrightnessLevel:[[DesignsManager sharedInstance] workingDesign].bgBrightness];
    
    ibevc.view.frame = [UIScreen currentScreenBoundsDependOnOrientation];
    
    [self.view addSubview:ibevc.view];
    [self addChildViewController:ibevc];
    
    if (IS_IPAD) {
        [self.iPadTopBar setHidden:YES];
        [self.undoView setHidden:YES];
    } else {
        [self.iphoneMenuVC hideMenuButton];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)changeBackgroundBrightness:(float)brightnessLevel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = [[DesignsManager sharedInstance] workingDesign].image;
        
        // Use gamma correction instead of brightness here. It is more useful than simple brightness
        UIImage *myImg = [UIPaintSession gammaCorrectImage:image withGamma:brightnessLevel];
        [self.imageView setImage:myImg];
    });
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)cancelBackgroundBrightnessChange:(float)originalBrightnessLevel
{
    [self.imageView setImage:[[DesignsManager sharedInstance] workingDesign].image];
    [self changeBackgroundBrightness:originalBrightnessLevel];
    
    if (IS_IPAD) {
        [self.iPadTopBar setHidden:NO];
        [self.undoView setHidden:NO];
    } else {
        [self.iphoneMenuVC showMenuButton];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)acceptBackgroundBrightnessChange:(float)brightnessLevel
{
    [[DesignsManager sharedInstance] workingDesign].bgBrightness = brightnessLevel;
    if (IS_IPAD) {
        [self.iPadTopBar setHidden:NO];
        [self.undoView setHidden:NO];
    } else {
        [self.iphoneMenuVC showMenuButton];
    }
}

////////////////////////////////////////////////////////////////
//                 Conceal methods                          //
////////////////////////////////////////////////////////////////

#pragma mark - Conceal methods
- (void)openClearRoomAction
{
    SavedDesign * design = [[DesignsManager sharedInstance] workingDesign];
    NSData * data = nil;
    
    //if saved design object
    if ([design supportsFullConcealAPI])
    {
        data = [design generateConcealRepresentationJSON];
    }
    
    ConcealViewController * conceal = [ControllersFactory instantiateViewControllerWithIdentifier:@"ConcealViewController" inStoryboard:kRedesignStoryboard];
    conceal.delegate = self;
    
    UIImage * img = [UIView imageWithView:self.imageView];
    [conceal configureConcealWith:img andData:data];
    
    if (IS_IPHONE) {
        CGRect rect = conceal.view.frame;
        rect.size.width = [UIScreen currentScreenBoundsDependOnOrientation].size.width;
        rect.size.height = [UIScreen currentScreenBoundsDependOnOrientation].size.height;
        conceal.view.frame = rect;
    } else {
        conceal.view.frame = [UIScreen currentScreenBoundsDependOnOrientation];
    }
    
    conceal.view.hidden = YES;
    
    [self.view addSubview:conceal.view];
    [self addChildViewController:conceal];
    
    if ([conceal initializeConcealer])
    {
        conceal.view.hidden = NO;
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:FLURRY_CONCEAL_TOOL_SUCCESS_INIT  withParameters:@{}];
        }
#endif
    }else{
        [conceal removeFromParentViewController];
        [conceal.view removeFromSuperview];
        
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"erh_unknown_error_msg", @"")
                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles: nil] show];
        
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:FLURRY_CONCEAL_TOOL_FAILED_INIT  withParameters:@{}];
        }
#endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)concealDoneWithNewImage:(UIImage *)image
{
    if (image)
    {
        self.imageView.image = [image copy];
        [[DesignsManager sharedInstance] workingDesign].image = self.imageView.image;
        [self.furniture3DViewController updateBackgroundColor];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////
//                  Undo/Redo Actions                         //
////////////////////////////////////////////////////////////////

#pragma mark - Undo/Redo Actions
- (void)updateUndoRedoStates
{
    self.undoButton.enabled = [self.furniture3DViewController canUndo];
    self.redoButton.enabled = [self.furniture3DViewController canRedo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)performRedoAction:(id)sender
{
    
    if ([self.furniture3DViewController respondsToSelector:@selector(applyRedoStep)] &&
        [self.furniture3DViewController canRedo])
    {
        [self.furniture3DViewController applyRedoStep];
    }
    
    [self updateUndoRedoStates];
    
    if (editingMode) {
        
        //clean
        [self clearDeleteButtonsFromView];
        editingMode = NO;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)performUndoAction:(id)sender
{
    if ([self.furniture3DViewController respondsToSelector:@selector(applyUndoStep)] &&
        [self.furniture3DViewController canUndo])
    {
        [self.furniture3DViewController applyUndoStep];
    }
    
    [self updateUndoRedoStates];
    
    if (editingMode) {
        
        //clean
        [self clearDeleteButtonsFromView];
        editingMode = NO;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)clearDeleteButtonsFromView{
    for (UIView* view in self.view.subviews) {
        if (view.tag > 0) [view removeFromSuperview];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)iphonePaintModeColor:(id)sender {
    [self closeProductInfoView];
    [self paintPressed];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)deletePressed:(id)sender {
    [self closeProductInfoView];
    [self startEditing];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)savePressed:(id)sender {
    
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]){
        [[UIMenuManager sharedInstance] showAlert];
        return;
    }
    
#ifdef USE_UMENG
//        [MobClick event:@"save"];
#endif
    
    [self closeProductInfoView];
    [self savePressed];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* t = [touches anyObject];
    if ([self.view hitTest:[t locationInView:self.view] withEvent:event].tag == 0) {
        [self stopEditing];
    }
}


@end
