//
//  PaintBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import "PaintBaseViewController.h"
#import "PaintColorCompanyCell.h"
#import "GeneralCubeViewController.h"
#import "UIImage+OpenCVWrapper.h"
#import "CollectionViewColorCell.h"
#import "CollectionViewWallPaperCell.h"
#import "ProtocolsDef.h"
#import "General3DViewController+CubeAccess.h"
#import "FlurryDefs.h"
#import "PaintCompanyDO.h"
#import "PaintColorCategoryDO.h"
#import "WallpapersManager.h"
#import "WallpaperCompanyDO.h"
#import "TilingDO.h"
#import "FloortilesManager.h"
#import "FloortileCompanyDO.h"
#import "PaintColorDO.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"
#import "PackageManager.h"
//#import "UMMobClick/MobClick.h"


#define PALLET_HEIGHT                       (286)
#define PAINT_AO_COLOR_MAX_DARK_COLOR       (0.2)
#define PAINT_AO_COLOR_KSIZE                (7)
#define PAINT_AO_COLOR_SIGMA                (4)
#define PAINT_AO_WALLPAPER_MAX_DARK_COLOR   (0.35)
#define PAINT_AO_WALLPAPER_KSIZE            (13)
#define PAINT_AO_WALLPAPER_SIGMA            (7)


#ifdef USE_FLURRY
#define RECORD_HSFLURRY(X) {if(ANALYTICS_ENABLED) X;}
#else
#define RECORD_HSFLURRY(X) {};
#endif


@interface PaintBaseViewController ()
{
    BOOL undoEnabled;
    BOOL redoEnabled;
    UIScribble* _scribble;
    CGRect _originalBottomFrame;
}

@property (atomic) BOOL isPainting;
@property (strong, nonatomic) UIImage* renderedPatternImage;
@property (strong, nonatomic) NSMutableArray* wallpaperPalletes;
@property CGFloat currrentTextureScale;
@property (nonatomic, weak) IBOutlet UIView *ivAdjustSeparator;
-(void)activateColorCompany:(PaintCompanyDO*)p;
-(void)activateWallpaperCompany:(WallpaperCompanyDO*)p;
@end

@implementation PaintBaseViewController
static NSString *cellIdentifierColor = @"colorCell";
static NSString *cellIdentifierWall = @"wallCell";
static NSString *headerViewIdentifier = @"Test Header View";
static NSString *footerViewIdentifier = @"Test Footer View";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.paintMode = ePaintModeColor;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    switch (self.paintMode) {
        case ePaintModeColor: {
            [self paintPickerPressed:self];
        }; break;
        case ePaintModeWallpaper: {
            [self wallpaperPickerPressed:self];
        }; break;
        case ePaintModeFloor: {
            [self floortilePickerPressed:self];
        }; break;
        default: break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_PAINT_SCREEN;

    [self initCollectionView];

    bIsFirstTimeForLine = YES;
    self.isPainting = NO;
    
    self.canvasView = [[UIPaintView alloc] initWithFrame:self.view.bounds];
    self.canvasView.delegate = self;
    self.canvasView.brushSize = 32;
    self.canvasView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.canvasView];
    
    [self.view sendSubviewToBack:self.canvasView];
    [self.view sendSubviewToBack:self.backgroundImage];
    
    UIGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground)];
    [self.backgroundImage addGestureRecognizer:tap];
    
    self.floortileWidget = [ControllersFactory instantiateViewControllerWithIdentifier:@"FloortileWidget" inStoryboard:kRedesignStoryboard];
    [self addChildViewController:self.floortileWidget];
    [self.view addSubview:self.floortileWidget.view];
    [self.view bringSubviewToFront:self.floortileWidget.view];
    [self.floortileWidget.view setHidden:YES];
    
    self.floortileWidget.delegate = self;
    
    // Loads colors from local jsons
    [ColorsManager sharedInstance];
    
    // Initialize floor/wall painting members
    _floorAngle = [NSNumber numberWithFloat:0.0f];
    _brightnessLevel =[NSNumber numberWithInt:BRIGHTNESS_DEFAULT_VALUE];
    _opacityLevel =[NSNumber numberWithFloat:OPACITY_DEFAULT_VALUE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.firstTime = YES;
    
    [self.canvasView setPaintViewMode:kUIPaintViewModeScribble];
    self.canvasView.frame = self.view.frame;

    [self updatePaintMode];

    self.backgroundImage.image = [[DesignsManager sharedInstance] workingDesign].image;
    self.originalImage =  [[DesignsManager sharedInstance] workingDesign].image;
    self.predefineMask = [[DesignsManager sharedInstance] workingDesign].maskImage;
    self.undoButton.enabled = NO;
    self.redoButton.enabled = NO;
    undoEnabled = NO;
    redoEnabled = NO;
    
    _floorAngle = [NSNumber numberWithFloat:0.0f];

    [self changeColorPressed:nil];
    [self paintTypeChanged:self];

    if ([self.tableView numberOfRowsInSection:0] > 0) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionTop];
    }
    
    // Cleanup the wall masks for this session
    [GeneralCubeViewController clearWallMasks];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)initCollectionView{
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [collectionViewFlowLayout setItemSize:CGSizeMake(116, PALLET_HEIGHT)];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeMake(0, 0)];
    [collectionViewFlowLayout setFooterReferenceSize:CGSizeMake(0, 0)];
    [collectionViewFlowLayout setMinimumInteritemSpacing:10];
    [collectionViewFlowLayout setMinimumLineSpacing:10];
    [collectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    CGRect frm = CGRectZero;
    
    if (IS_IPAD) {
        frm = CGRectMake(277, 0, 747, PALLET_HEIGHT);
    }else{
        frm = CGRectMake(50, 10, self.colorWallpaperPicker.frame.size.width-50, PALLET_HEIGHT);
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:frm collectionViewLayout:collectionViewFlowLayout];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[CollectionViewColorCell class] forCellWithReuseIdentifier:cellIdentifierColor];
    [_collectionView registerClass:[CollectionViewWallPaperCell class] forCellWithReuseIdentifier:cellIdentifierWall];
    
    [self.palleteView addSubview:_collectionView];
}

-(void)paintTypeChanged:(id)sender
{
    
}

-(UIPaintSession*)paintSession {
    if (_paintSession != nil) {
        return _paintSession;
    }
    _paintSession = [[UIPaintSession alloc] initWithImage:self.originalImage withScreenSize:self.view.frame.size];
    
    if (self.predefineMask){
        [_paintSession addPredefineMask:self.predefineMask];
    }
    
    return _paintSession;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (void)hideContrastAndBrigthnessSliders{
    //implemets in son's
}

- (IBAction)buttonContrastPressed:(id)sender{
    //implemets in son's
}

- (IBAction)buttonBrightnessPressed:(id)sender{
    //implemets in son's
}

- (UIColor*)chosenColor {
    return self.chosenColorLabel.backgroundColor;
}

- (void)setChosenColor:(UIColor *)chosenColor {
    self.chosenColorLabel.backgroundColor = chosenColor;
    [self updatePaintMode];
}

- (void)updatePaintMode
{
    
}

- (IBAction)paintRemoveToggleAction:(id)sender
{

}

- (void)paintTypeChangedByType:(PaintItemType)pIntexType {
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    [[HelpManager sharedInstance] helpClosedForKey:@"paint_line"];
    switch (pIntexType) {
        case ePaintFill:
        case ePaintFreeLine:
            self.canvasView.brushSize = 32;
            [self.canvasView setPaintViewMode:kUIPaintViewModeScribble];
            break;
        case ePaintLine:
            self.canvasView.brushSize = 16;
            [self.canvasView setPaintViewMode:kUIPaintViewModeLine];
            [[HelpManager sharedInstance] presentHelpViewController:@"paint_line" withController:self isForceToShow:bIsFirstTimeForLine];
            
            break;
        default:
            self.canvasView.brushSize = 32;
            [self.canvasView setPaintViewMode:kUIPaintViewModeScribble];
            break;
    }
    self.paintType = pIntexType;
}

-(void)paintTypeModeLine{
    
}

-(void)paintTypeModeFreeLine{
    
}

-(void)paintTypeModeFill{
    
}

- (IBAction)donePressed:(id)sender
{
    [self doneDrawingLine];
}

-(void)doneDrawingLine{
//    [HSFlurry logAnalyticEvent:EVENT_NAME_STYLE_WALL_FINISH];
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        if (self._chosenColorName!=nil) {
//            [ HSFlurry logEvent:FLURRY_PAINT_COLOR_SELECT withParameters:[NSDictionary dictionaryWithObject:self._chosenColorName forKey:@"choosen_color"]];
        }
    }
#endif
    
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    [self.paintSession reset];
    
    [[DesignsManager sharedInstance] workingDesign].image = self.backgroundImage.image;
    
    [self removeCanvasView];
    
    if ([self.delegate respondsToSelector:@selector(donePressed:)]) {
        [self.delegate donePressed:self];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    
    if ([self.delegate respondsToSelector:@selector(cancelPressed:)])
    {
        [self removeCanvasView];
        
        [self.paintSession reset];
        self.paintSession = nil;
        
        [self.delegate cancelPressed:self];
    }
}

-(void)removeCanvasView{
    [self.canvasView removeFromSuperview];
    self.canvasView.delegate = nil;
    self.canvasView = nil;
}

- (void)tapBackground {
    if (self.colorWallpaperPicker.hidden == NO) {
        if (self.firstTime) {
            [self cancelPressed:self];
        } else {
            [self changeColorPressed:self];
        }
    }
}

- (IBAction)changeColorPressed:(id)sender {
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    static bool lock = false;
    if (lock) return;
    
    if (self.colorWallpaperPicker.hidden == YES || self.firstTime == YES) {
        lock = true;
        void (^animations)(void) = ^{
            self.colorWallpaperPicker.alpha = 1;
            self.bottomBar.alpha = 0;
            self.undoButton.hidden=YES;
            self.redoButton.hidden=YES;
            self.undoRedoView.hidden=YES;
            self.colorWallpaperPicker.center = CGPointMake(self.colorWallpaperPicker.frame.size.width / 2, [UIScreen currentScreenBoundsDependOnOrientation].size.height - self.colorWallpaperPicker.frame.size.height/2);
        };
        
        self.canvasView.hidden = YES;
        self.colorWallpaperPicker.hidden = NO;
        if (sender != nil) {
            [UIView animateWithDuration:0.3 animations:animations completion:^(BOOL finished) {
                lock = false;
            }];
        } else {
            animations();
            lock = false;
        }
        
    } else {
        lock = true;
        void (^animations)(void) = ^{
            self.colorWallpaperPicker.alpha = 1;
            self.bottomBar.alpha = 1;
            self.undoButton.hidden=NO;
            self.redoButton.hidden=NO;
            self.undoRedoView.hidden=NO;
            self.colorWallpaperPicker.center = CGPointMake(self.colorWallpaperPicker.frame.size.width / 2, self.view.bounds.size.height + self.colorWallpaperPicker.frame.size.height / 2);
        };
        void (^completion)(BOOL) = ^(BOOL finished) {
            lock = false;
            self.colorWallpaperPicker.hidden = YES;
            self.canvasView.hidden = NO;
            
            [self wallpaperPickFinished];
        };
        if (self != nil) {
            [UIView animateWithDuration:0.3 animations:animations completion:completion];
        } else {
            animations();
            completion(YES);
        }
    }
}

- (IBAction)paintPickerPressed:(id)sender {

    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_PAINT_SELECT];
    }
#endif
    
    self.selectedCompanyWebSiteURL = nil;
    
    self.wallpaperPickerButton.selected = NO;
    self.wallpaperPickerButton.btnIcon.selected = NO;
    
    self.floorButton.selected = NO;
    self.floorButton.btnIcon.selected = NO;
    
    self.paintPickerButton.selected = YES;
    self.paintPickerButton.btnIcon.selected = YES;
    
    self.paintMode = ePaintModeColor;
    
    [self.tableView reloadData];
    
    if ([self.tableView numberOfRowsInSection:0]>0) {
        
        PaintCompanyDO * p =  [[[ColorsManager sharedInstance] colorCompanies] objectAtIndex:0];
        
        [self activateColorCompany:p];
        [self updateWebsiteButtonForCompany:p];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)wallpaperPickerPressed:(id)sender {
    
//    RECORD_HSFLURRY( [HSFlurry logEvent: FLURRY_PAINT_WALLPAPPER_CLICK] );
    
    self.selectedCompanyWebSiteURL = nil;
    
    self.websiteButton.hidden = YES;
    
    self.paintPickerButton.selected = NO;
    self.paintPickerButton.btnIcon.selected = NO;
    
    self.floorButton.selected = NO;
    self.floorButton.btnIcon.selected = NO;
    
    self.wallpaperPickerButton.selected = YES;
    self.wallpaperPickerButton.btnIcon.selected = YES;
    
    self.paintMode = ePaintModeWallpaper;
    
    [self.tableView reloadData];
    
    if ([self.tableView numberOfRowsInSection:0]>0) {

        WallpaperCompanyDO* p = [WallpapersManager sharedInstance].wallpaperCompanies[0];
        [self activateWallpaperCompany:p];
        [self updateWebsiteButtonForCompany:p];
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)floortilePickerPressed:(id)sender {
    
//    RECORD_HSFLURRY( [HSFlurry logEvent: FLURRY_PAINT_FLOORTILE_CLICK] );
    
    self.selectedCompanyWebSiteURL = nil;
    self.websiteButton.hidden = YES;
    
    self.paintPickerButton.selected = NO;
    self.paintPickerButton.btnIcon.selected = NO;
    
    self.wallpaperPickerButton.selected = NO;
    self.wallpaperPickerButton.btnIcon.selected = NO;
    
    self.floorButton.selected = YES;
    self.floorButton.btnIcon.selected = YES;

    self.paintMode = ePaintModeFloor;

    [self.tableView reloadData];
    
    if ([self.tableView numberOfRowsInSection:0]>0) {
        
        FloortileCompanyDO* p = [FloortilesManager sharedInstance].floortileCompanies[0];
        [self activateFloortileCompany:p];
        [self updateWebsiteButtonForCompany:p];
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void) startedStrokeOnCanvasView:(RMCanvasView *)canvasView {
}

- (void)painted:(UIPaintStep*)step endOfStroke:(BOOL)endOfStroke {
   
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    
    if (!_scribble) {
        _scribble = [[UIScribble alloc] initWithMode:self.paintType != ePaintFill lineWidth:step.brushSize];
    }
    
    UIColor* color;
    if ([step.color isEqual:self.chosenColor]) {
        color = UIColorFromGrayLevel(1);
    } else {
        color = UIColorFromGrayLevel(2);
    }
    
    [_scribble addToLine:[[ScribbleLinePart alloc] initWithStart:step.start end:step.end color:color]];
    
    if (endOfStroke)
    {
        UIPaintStep *firstStep = _scribble.line[0];
        
        self.currentScribblePoint = firstStep.start;
        
        [self.paintSession addScribble:_scribble];
        
        if (self.renderedPatternImage && self.chosenPattern != self.renderedPatternImage)
            self.chosenPattern = [self renderWallpaperToUIImage:self.renderedPatternImage resizeFactor:self.renderedPatternResizeFactor];
        
        _scribble = nil;
        
        [self updatePaint];
        [self.canvasView clearPaint];
        
        self.undoButton.enabled = YES;
        self.redoButton.enabled = NO;
        
        undoEnabled = YES;
        redoEnabled = NO;
                
        [self showHelpAfterPaint];
    }
}

- (void)tapped:(UIPaintView *)canvasView
{
    (void)canvasView;
    // toggle the visibility of bottom bar
    //self.bottomBar.hidden = !self.bottomBar.hidden;
    
    CGRect bottomFrame = self.bottomBar.frame;
    CGFloat bottomY = CGRectGetMaxY(self.view.frame);
    if (bottomFrame.origin.y < bottomY - 1) {
        // to hide
        if (CGRectIsEmpty(_originalBottomFrame)) {
            _originalBottomFrame = bottomFrame;
        }
        bottomFrame.origin.y = bottomY;
    } else {
        // to show
        NSAssert(!CGRectIsEmpty(_originalBottomFrame), @"unexpected empty _originalBottomFrame");
        if (!CGRectIsEmpty(_originalBottomFrame)) {
            bottomFrame = _originalBottomFrame;
        }
    }

    [UIView animateWithDuration:0.2 animations:^ {
        self.bottomBar.frame = bottomFrame;
    } completion:^(BOOL finished) {
    }];
}

- (void)showHelpAfterPaint
{
    //implemet in son's
}

-(void)updatePaint {
    NSLog(@"Update paint!");
    [self updatePaintInternal];
}

-(void)setChosenPattern:(UIImage *)chosenPattern
{
    _chosenPattern = chosenPattern;
}

-(void)updatePaintInternal
{
    undoEnabled = NO;
    redoEnabled = NO;
    if (self.undoActionButton) {
        undoEnabled = self.undoActionButton.enabled;
        redoEnabled = self.reduActionButton.enabled;
        self.undoActionButton.enabled = NO;
        self.reduActionButton.enabled = NO;
    } else if (self.undoButton) {
        undoEnabled = self.undoButton.enabled;
        redoEnabled = self.redoButton.enabled;
        self.undoButton.enabled = NO;
        self.redoButton.enabled = NO;
    }
    
    switch (self.paintMode)
    {
        case ePaintModeColor:
        {
            [self.paintSession enableAmbientOcclusion:PAINT_AO_COLOR_MAX_DARK_COLOR
                                                kSize:PAINT_AO_COLOR_KSIZE
                                                sigma:PAINT_AO_COLOR_SIGMA ];
            break;
        }
            
        case ePaintModeFloor:
        case ePaintModeWallpaper:
        default:
        {
            [self.paintSession enableAmbientOcclusion:PAINT_AO_WALLPAPER_MAX_DARK_COLOR
                                                kSize:PAINT_AO_WALLPAPER_KSIZE
                                                sigma:PAINT_AO_WALLPAPER_SIGMA ];
            break;
        }
            
    }
    
    bool useColorPaint = self.chosenColorLabel.hidden == NO;
    
    UIImage *chosPattern = self.chosenPattern;
    if (useColorPaint) {
        self.paintSession.color = self.chosenColor;
    } else {
        self.paintSession.texture = chosPattern;
    }
    
    UIImage* newImage  = self.paintSession.result;
    
    if(newImage){
        self.backgroundImage.image = newImage;
    }
        
    if (self.undoActionButton) {
        self.undoActionButton.enabled = undoEnabled;
        self.reduActionButton.enabled = redoEnabled;
    } else if (self.undoButton) {
        self.undoButton.enabled = undoEnabled;
        self.redoButton.enabled = redoEnabled;
    }
}

-(void)setChoosenColorName:(NSString*)colorIDName{
    self._chosenColorName = colorIDName;
}

#pragma mark - SinglePaletteColorDelegate
-(void)colorSelected:(UIColor *)color  andSourceObject:(PaintColorPalletItemDO*)colorObject {
    self.firstTime = NO;
    self.chosenColor = color;
    self.patternLabel.hidden = YES;
    self.chosenColorLabel.hidden = NO;
    [self changeColorPressed:self];
    [self updatePaint];
    
    // show help view after animation in 'changeColorPressed' finished
    //[[HelpManager sharedInstance] presentHelpViewController:@"help_paint" withController:self];

    NSString * selectedPaintCompany=(self.selectedCompany!=nil && self.selectedCompany.companyName!=nil)?self.selectedCompany.companyName:@"";
    NSString * colorName=(self._chosenColorName!=nil)?self._chosenColorName:@"";
    PaintColorDO *pColor=[colorObject getPaintColorObjectByName:colorName];
    
    NSString *colorID=(pColor.colorID!=nil)?pColor.colorID:@"";
//    [HSFlurry logAnalyticEvent:EVENT_NAME_STYLE_WALL_PICKER withParameters:@{EVENT_PARAM_DECORATION_BRAND:selectedPaintCompany,EVENT_PARAM_DECORATION_NAME:colorName,EVENT_PARAM_DECORATION_ID: colorID}];

#ifdef USE_UMENG
//    [MobClick event:@"paint" label:colorID];
#endif
}

// TODO: Change this method to be named differently
// Currently its called wallpaper but it actually manages floortiles as well. MAKE IT GENERIC
-(UIImage*)renderWallpaperToUIImage:(UIImage*)texture resizeFactor:(CGFloat)resizeFactor
{
    GeneralCubeViewController *cubeRenderer = [[GeneralCubeViewController alloc] init];
    cubeRenderer.useMipmapping = NO;
    cubeRenderer.cubeTextureScale = self.currrentTextureScale;
    CGRect f = CGRectMake(0, 0, self.originalImage.size.width * resizeFactor, self.originalImage.size.height * resizeFactor);
    cubeRenderer.view.frame = f;
    cubeRenderer.textureImage = texture;
    cubeRenderer.currentDesign = [[DesignsManager sharedInstance] workingDesign];
    [cubeRenderer refreshGLView];
    
    // Extend the cube renderer bounds to the entire screen
    // this is done to support the click on screen intersection with the cube's plane
    CGRect oldBounds = cubeRenderer.view.bounds;
    CGRect screenRect = [UIScreen currentScreenBoundsDependOnOrientation];
    cubeRenderer.view.bounds = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    WallSide currentWallSide = [cubeRenderer wallAtIntersectionOfPoint:self.currentScribblePoint];
    cubeRenderer.view.bounds = oldBounds;

    cubeRenderer.wireframeHidden = YES;
    
    [cubeRenderer glkViewLogic];
    
    // Set correct camera for rendering
    [cubeRenderer updateProjection];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    if (self.paintMode == ePaintModeFloor)
    {
        // In case the current design has a mask image,
        // render the entire plane at once. The masking will snap the render
        // directly to the floor. Else activate the currently clicked wall
        if (cubeRenderer.currentDesign.maskImage)
            [GeneralCubeViewController activateWall:WallAll];
        else
            [GeneralCubeViewController activateWall:currentWallSide];
        
        [cubeRenderer setWallSide:WallFloor];
        cubeRenderer.floorRotatingAngle = [self.floorAngle floatValue];
        cubeRenderer.floorWidthDelta = [self.floorWidthDelta floatValue];
        cubeRenderer.floorHeightDelta = [self.floorHeightDelta floatValue];
    }
    
    // temporary disabling multisampling due to the fact that images might be larger than the frame buffer size
    // a proper solution might be to resize the wallpaper to fit frame buffer size with multisampling enabled
    appDelegate.glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
    appDelegate.glkView.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
    
    // Retrieve the final image after rendering using OpenGL
    UIImage* final = [appDelegate.glkView snapshot];
    [appDelegate.glkView deleteDrawable];

    cubeRenderer = nil;
    
    return final;
}

-(void)wallpaperSelected:(UIImage *)image  withParentObject:(TilingDO*)wallpaper
{    
    self.currrentTextureScale = [wallpaper.tileSize floatValue] / 100.0;
    
    float width = MIN(image.size.width, image.size.height);
    UIImage* cropped = [image crop:CGRectMake(0, 0, width, width)];
    float newWidth = powf(2.0f, floorf(log2f(width)));
    UIImage* tex = [cropped resizeImageByFactor:newWidth / width];
    
    self._chosenColorName=nil;
    self.firstTime = NO;
    self.patternLabel.image = tex;
    self.chosenColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.patternLabel.hidden = NO;
    self.chosenColorLabel.hidden = YES;
    CGFloat resizeFactor = 1;
    float viewAspectRatio = [UIScreen currentScreenBoundsDependOnOrientation].size.width / [UIScreen currentScreenBoundsDependOnOrientation].size.height;
    float imageAspectRatio = self.originalImage.size.width / self.originalImage.size.height;
    
    if (imageAspectRatio >= viewAspectRatio)
        resizeFactor = [UIScreen mainScreen].scale * self.view.frame.size.height / self.originalImage.size.height;
    else
        resizeFactor = [UIScreen mainScreen].scale * self.view.frame.size.width / self.originalImage.size.width;
    
    resizeFactor = MIN(resizeFactor, 1);
    
    self.renderedPatternImage = tex;
    
    // we resize the pattern only for iphone 6 plus.
    //if ([ConfigManager deviceTypeIsIphone6Plus])
    // we resize the pattern for iphone 6 newer.
    if ([UIScreen mainScreen].scale > 1)
        resizeFactor = resizeFactor * (2/3.0);
    
    self.renderedPatternResizeFactor = resizeFactor;
    [self changeColorPressed:self];
    
    self.chosenPattern = [self renderWallpaperToUIImage:self.renderedPatternImage resizeFactor:self.renderedPatternResizeFactor];
    [self updatePaint];
    
    NSString * selectedWallpaperCompany = (self.selectedWallpaperCompany != nil && self.selectedWallpaperCompany.name!=nil) ? self.selectedWallpaperCompany.name:@"";
    
    if ([selectedWallpaperCompany isEqualToString:@""] && self.selectedFloortileCompany &&
        self.selectedFloortileCompany && self.selectedFloortileCompany.name)
        selectedWallpaperCompany = self.selectedFloortileCompany.name;
    
    NSString * wallpaperName = (wallpaper!=nil && wallpaper.title !=nil && wallpaper.title.length != 0) ? wallpaper.title:wallpaper.imageURL;
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_STYLE_WALL_PICKER
//                withParameters:@{EVENT_PARAM_DECORATION_BRAND : selectedWallpaperCompany,
//                                 EVENT_PARAM_DECORATION_NAME : wallpaperName}];
    
#ifdef USE_UMENG
//    [MobClick event:@"wallpaper" label:wallpaper.imageURL];
#endif
}

- (IBAction)undoPressed:(id)sender {
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    [self.paintSession undo];
    if (self.paintSession.gotAnythingToRedo) {
        self.redoButton.enabled = YES;
        self.reduActionButton.enabled = YES;
    }
    
    if (!self.paintSession.gotAnythingToUndo) {
        self.undoButton.enabled = NO;
        self.undoActionButton.enabled = NO;
    }
    [self updatePaint];
}

- (IBAction)redoPressed:(id)sender {
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    [self.paintSession redo];
    if (self.paintSession.gotAnythingToRedo) {
        self.redoButton.enabled = YES;
        self.reduActionButton.enabled = YES;
    } else {
        self.redoButton.enabled = NO;
        self.reduActionButton.enabled = NO;
    }
    
    if (!self.paintSession.gotAnythingToUndo) {
        self.undoButton.enabled = NO;
        self.undoActionButton.enabled = NO;
    } else {
        self.undoButton.enabled = YES;
        self.undoActionButton.enabled = YES;
    }
    
    [self updatePaint];
}

-(void)loadColorCompany:(PaintCompanyDO*)company{
    
    self.selectedCompany=company;
    [self fillCategories];
    
    if ([[self.selectedCompany categories] count]>0)
    {
        self.selectedColorCategory=[[self.selectedCompany categories] objectAtIndex:0];
    }
    
    [self loadColorPaletteAnimated:YES];
    [self updateWebsiteButtonForCompany:company];
   
}

-(void)updateWebsiteButtonForCompany:(CompanyBaseDO*)company{
    if ([company isVendroSiteLinkExists]) {
        self.selectedCompanyWebSiteURL = [company companyUrl];
        self.websiteButton.hidden = NO;
    }else{
        self.websiteButton.hidden = YES;
        self.selectedCompanyWebSiteURL = nil;
    }
}

-(void)loadWallpaperCompany:(WallpaperCompanyDO*)company{
    
    self.selectedWallpaperCompany=company;
    [self loadColorPaletteAnimated:YES];
    [self updateWebsiteButtonForCompany:company];
}

-(void)loadFloortileCompany:(FloortileCompanyDO*)company{
    
    self.selectedFloortileCompany = company;
    [self loadColorPaletteAnimated:YES];
    [self updateWebsiteButtonForCompany:company];
}

- (void)loadColorPaletteAnimated:(BOOL)animated{
    [_collectionView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.firstTime = YES;
    [super viewDidDisappear:animated];
}

-(void)dealloc {
    HSMDebugLog(@"Paint dealloc");
    
    [self setCanvasView:nil];
    [self setUndoButton:nil];
    [self setRedoButton:nil];
    [self setPatternLabel:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self setCollectionView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)fillCategories{
    
}


// hide the company icons table by resizing the palleteView  (hiding the table)
// implemented in device specific class
-(void)hideCompanyTableView:(NSString *)companyName
{
}

// show the company icons table by resizing the palleteView (hiding the table)
// implemented in device specific class
-(void)showCompanyTableView
{
}


#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 140; //returns floating point which will be used for a cell row height at specified row index
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (self.paintMode)
    {
        case ePaintModeColor: {
            if ([[ColorsManager sharedInstance].colorCompanies count] > 0)
            {
                PaintCompanyDO * p= [[ColorsManager sharedInstance].colorCompanies objectAtIndex:0];
                // check if we need to hide the company table
                [self hideCompanyTableView:p.companyName];
            }
            
            return [[ColorsManager sharedInstance].colorCompanies count];
        }; break;
            
        case ePaintModeWallpaper: {
            if ([[WallpapersManager sharedInstance].wallpaperCompanies count] > 0)
            {
                WallpaperCompanyDO * p = [[WallpapersManager sharedInstance].wallpaperCompanies objectAtIndex:0];
                // check if we need to hide the company table
                [self hideCompanyTableView:p.name];
            }
            
            return [[WallpapersManager sharedInstance].wallpaperCompanies count];
        }; break;
            
        case ePaintModeFloor: {
            if ([[FloortilesManager sharedInstance].floortileCompanies count] > 0)
            {
                FloortileCompanyDO * p = [[FloortilesManager sharedInstance].floortileCompanies objectAtIndex:0];
                // check if we need to hide the company table
                [self hideCompanyTableView:p.name];
            }
            
            return [[FloortilesManager sharedInstance].floortileCompanies count];
        }; break;
            
        default: break;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    PaintColorCompanyCell * cell = (PaintColorCompanyCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.genericWebViewDelegate = self;
    
    NSString * imageUrl=nil;
    
    NSString * companyURL = nil;
    switch (self.paintMode)
    {
        case ePaintModeColor:
        {
            NSArray * colorComanies = [[ColorsManager sharedInstance] colorCompanies];
            PaintCompanyDO *p = nil;
            if (colorComanies && indexPath.row < [colorComanies count]) {
                p = [colorComanies objectAtIndex:indexPath.row];
            }
            
            imageUrl = p.iconRetinaUrl;
            [cell.loadingInicator startAnimating];

            //Load the company logo on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *logo = p.getLogo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (logo) {
                        cell.companyLogo.image = logo;
                    }
                    [cell.loadingInicator stopAnimating];
                });
            });
            
            if ([p isVendroSiteLinkExists])
                companyURL = p.companyUrl;
        } break;
            
        case ePaintModeWallpaper:
        {
            WallpaperCompanyDO* p2 = [WallpapersManager sharedInstance].wallpaperCompanies[indexPath.row];
            [cell.loadingInicator startAnimating];
            
            //Load the company logo on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *logo = p2.getLogo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (logo) {
                        cell.companyLogo.image = logo;
                    }
                    [cell.loadingInicator stopAnimating];
                });
            });
            
            if ([p2 isVendroSiteLinkExists])
                companyURL = p2.companyUrl;
            
        } break;
            
        case ePaintModeFloor:
        {
            FloortileCompanyDO* p2 = [FloortilesManager sharedInstance].floortileCompanies[indexPath.row];
            [cell.loadingInicator startAnimating];
            
            //Load the company logo on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              
                UIImage *logo = p2.getLogo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (logo) {
                        cell.companyLogo.image = logo;
                    }
                    [cell.loadingInicator stopAnimating];
                });
            });
            
            if ([p2 isVendroSiteLinkExists])
                companyURL = p2.companyUrl;
        } break;
            
        default: break;
    }
    
    if (companyURL) {
        cell.websiteURL = companyURL;
        cell.websiteButton.hidden = ![ConfigManager isMoreInfoDisplay];
        [cell.websiteButton setTitle:NSLocalizedString(@"shopping_list_go_to_website", @"Go to Website") forState:UIControlStateNormal] ;
    }else
    {
        cell.websiteURL = nil;
        cell.websiteButton.hidden = YES;
    }
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (self.paintMode)
    {
        case ePaintModeColor:
        {
            PaintCompanyDO * p=  [[[ColorsManager sharedInstance] colorCompanies] objectAtIndex:indexPath.row];
            
            if (self.selectedCompany==nil || [self.selectedCompany isEqual:p]==false) {
                [self activateColorCompany:p];
            }
        } break;
            
        case ePaintModeWallpaper:
        {
            WallpaperCompanyDO *wp=[WallpapersManager sharedInstance].wallpaperCompanies[indexPath.row];
            if (self.selectedWallpaperCompany==nil || [self.selectedWallpaperCompany isEqual:wp]==false) {
                [self activateWallpaperCompany:wp ];
            }
        } break;
            
        case ePaintModeFloor:
        {
            FloortileCompanyDO *wp=[FloortilesManager sharedInstance].floortileCompanies[indexPath.row];
            if (self.selectedFloortileCompany==nil || [self.selectedFloortileCompany isEqual:wp]==false) {
                [self activateFloortileCompany:wp ];
            }
        } break;
            
        default: break; // TODO: LAUNCH ERROR
    }
}

-(void)activateColorCompany:(PaintCompanyDO*)p
{
    [self loadColorCompany:p];
}
-(void)activateWallpaperCompany:(WallpaperCompanyDO*)p
{
//    RECORD_HSFLURRY([ HSFlurry logEvent:FLURRY_PAINT_OPTION withParameters:[NSDictionary dictionaryWithObject:p.name forKey:@"wallpaper_option"]]);
    
    [self loadWallpaperCompany:p];
}

-(void)activateFloortileCompany:(FloortileCompanyDO*)p
{
//    RECORD_HSFLURRY([ HSFlurry logEvent:FLURRY_PAINT_OPTION withParameters:[NSDictionary dictionaryWithObject:p.name forKey:@"floortile_option"]]);
    
    [self loadFloortileCompany:p];
}

#pragma mark - UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.paintMode)
    {
        case ePaintModeColor: return CGSizeMake(116, PALLET_HEIGHT-15); break;
            
        case ePaintModeWallpaper: return CGSizeMake(151, PALLET_HEIGHT-15); break;
            
        case ePaintModeFloor: return CGSizeMake(151, PALLET_HEIGHT-15); break;
            
        default: break;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray * pallets=nil;
    
    switch (self.paintMode)
    {
        case ePaintModeColor:
        {
            if ([[self.selectedCompany categories] count]>0)
                pallets=(NSArray*)self.selectedColorCategory.categoryColors;
            else
                pallets=self.selectedCompany.flatAllPallets;
        }; break;
            
        case ePaintModeWallpaper:
        {
            pallets = self.selectedWallpaperCompany.wallpapers;
        }; break;
            
        case ePaintModeFloor:
        {
            pallets = self.selectedFloortileCompany.floortiles;
        }; break;
        default: break;
    }
    
    // if we were able to retrieve a current pallet return its count
    if (pallets)
        return [pallets count];
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identi = cellIdentifierWall;
    NSArray *pallets = nil;
    
    switch (self.paintMode)
    {
        case ePaintModeColor:
            identi = cellIdentifierColor;
            break;
            
        case ePaintModeWallpaper:
            identi = cellIdentifierWall;
            break;
            
        case ePaintModeFloor:
            identi = cellIdentifierWall;
            break;
        
        default: break;
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identi forIndexPath:indexPath];
    
    switch (self.paintMode) {
        case ePaintModeColor: {
            if ([[self.selectedCompany categories] count]>0)
                pallets = (NSArray*)self.selectedColorCategory.categoryColors;
            else
                pallets = self.selectedCompany.flatAllPallets;
            
            CollectionViewColorCell *ccell = (CollectionViewColorCell*)cell;
            
            if (pallets && indexPath.row < [pallets count])
                [ccell refreshWithContent:[pallets objectAtIndex:indexPath.row] andDelegate:self];
            
        }; break;
            
        case ePaintModeWallpaper: {
            pallets = self.selectedWallpaperCompany.wallpapers;
            CollectionViewWallPaperCell *ccell=(CollectionViewWallPaperCell*)cell;
            
            if (pallets && indexPath.row<[pallets count]) {
                [ccell refreshWithContent:[pallets objectAtIndex:indexPath.row] andDelegate:self];
            }
        }; break;
            
        case ePaintModeFloor: {
            pallets = self.selectedFloortileCompany.floortiles;
            CollectionViewWallPaperCell *ccell=(CollectionViewWallPaperCell*)cell;
            
            if (pallets && indexPath.row<[pallets count]) {
                [ccell refreshWithContent:[pallets objectAtIndex:indexPath.row] andDelegate:self];
            }
        }; break;
        default: break;
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	return nil;
    
}

#pragma mark - Class Function
- (void)floorPressed {
    // EMPTY IMPLEMENTATION
    // Add code here to handle user press on the floor button
}

- (void)updatePaintSynced
{
    if (!self.isPainting)
    {
        self.isPainting = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Set chosen parameters for the Retinex algorithm
            [self.paintSession setOpacity:[_opacityLevel floatValue]];
            [self.paintSession setBrightness:[_brightnessLevel integerValue]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.chosenPattern = [self renderWallpaperToUIImage:self.renderedPatternImage resizeFactor:1.0f];
                [self updatePaint];
                [self.canvasView clearPaint];
                self.chosenPattern = nil;
                self.undoButton.enabled = YES;
                self.redoButton.enabled = NO;
                undoEnabled = YES;
                redoEnabled = NO;
                [self showHelpAfterPaint];
                
                self.isPainting = NO;
            });
        });
    }
}

- (void)paintRetinexBrightnessChanged:(float)brightnessLevel
{
    _brightnessLevel = [NSNumber numberWithFloat:brightnessLevel];
    [self updatePaintSynced];
}

- (void)paintRetinexOpacityChanged:(float)opacityLevel
{
    _opacityLevel = [NSNumber numberWithFloat:opacityLevel];
    [self updatePaintSynced];
}

- (void)floortileAngleChanged:(float)angle
{
    _floorAngle = [NSNumber numberWithFloat:angle];
    [self updatePaintSynced];
}

- (void)floortileWidthChanged:(float)width
{
    _floorWidthDelta = [NSNumber numberWithFloat:width];
    [self updatePaintSynced];
}

- (void)floortileDepthChanged:(float)depth
{
    _floorHeightDelta = [NSNumber numberWithFloat:depth];
    [self updatePaintSynced];
}

- (void)closePaintLikeOptions{
    self.adjustButton.selected = NO;
    self.brightnessButton.selected = NO;
    self.contrastButton.selected = NO;

}

- (IBAction)toggleFloortileWidget:(id)sender
{
    [self closePaintLikeOptions];
   
    if ([self.floortileWidget.view isHidden])
    {
        [self.floortileWidget.view setAlpha:0];
        [self.floortileWidget.view setHidden:NO];
        [self.floortileWidget.view setUserInteractionEnabled:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.floortileWidget.view.alpha = 1;
            self.adjustButton.selected = YES;
        }];
    }
    else
    {
        [self.floortileWidget.view setAlpha:1];
        [self.floortileWidget.view setUserInteractionEnabled:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.floortileWidget.view.alpha = 0;
            [self.floortileWidget.view setHidden:YES];
            
        }];
    }
}

- (void)closeFloortileWidgetDialog
{
    [self toggleFloortileWidget:nil];
}

#pragma mark - Paint Slider Delegate

- (void)sliderValueChanged:(float)newValue sender:(id)sender
{
    if (sender == vcBrightnessSlider)
    {
        
    }
    else if (sender == vcContrastSlider)
    {
        
    }
}

- (void)sliderTouchUpWithValue:(float)currentValue sender:(id)sender
{
    if (sender == vcBrightnessSlider)
    {
        [self paintRetinexBrightnessChanged:currentValue];
    }
    else if (sender == vcContrastSlider)
    {
        [self paintRetinexOpacityChanged:currentValue];
    }
}

- (void)resetButtonPressedWithSender:(id)sender
{
    if (sender == vcBrightnessSlider)
    {
        [self paintRetinexBrightnessChanged:BRIGHTNESS_DEFAULT_VALUE];
    }
    else if (sender == vcContrastSlider)
    {
        [self paintRetinexOpacityChanged:OPACITY_DEFAULT_VALUE];
    }
}

- (void)reset
{
    [self.paintSession reset];
    self.backgroundImage.image = nil;
}

- (void)wallpaperPickFinished
{
    [[HelpManager sharedInstance] presentHelpViewController:@"help_paint" withController:self];
}

#pragma mark - GenericWebViewDelegate
-(void)openInteralWebViewWithUrl:(NSString *)url{
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:url];
    [self presentViewController:web animated:YES completion:nil];
}

@end
