//
//  iphonePaintViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import "PaintViewController_iPhone.h"
#import "PaintColorCategoryDO.h"
#import "ControllersFactory.h"

@interface PaintViewController_iPhone()
{
    __weak IBOutlet UIView *_paintDrawOptionsContainerView;
    __weak IBOutlet UIView *_paintDrawOptionsView;
}

-(void)adjustViewFrame:(UIButton *)currentBtn andCurrentView:(UIView *)currentView;
@end

@implementation PaintViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isPeekOpen=NO;
    self.canAnimatePeeking=YES;
    
    //Default
    self.applyButton.selected = YES;
    
    [self prepareSlidersView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    switch (self.paintMode) {
        case ePaintModeFloor:
            [self setPaintModeFloor:self.floorModeButton];
            break;
        case ePaintModeColor:
            [self setPaintModeColor:self.colorModeButton];
            break;
        case ePaintModeWallpaper:
            [self setPaintModeWallpaper:self.wallpaperModeButton];
            break;
        default:
            break;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self adjustViewFrame:self.toggleLineButton andCurrentView:_paintDrawOptionsView];
    [self adjustViewFrame:self.brightnessButton andCurrentView:sliderContainerView];
    [self adjustViewFrame:self.adjustButton andCurrentView:self.floortileWidget.sliderView];
    
    UIGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPaintDrawOptionsTapped)];
    [_paintDrawOptionsContainerView addGestureRecognizer:tap];
}

- (void)onPaintDrawOptionsTapped
{
    self.toggleLineButton.selected = NO;
    _paintDrawOptionsContainerView.hidden = YES;
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

-(void)dealloc{
    NSLog(@"dealloc - PaintViewController_iPhone");
}

- (void)prepareSlidersView
{
    viewSliders = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen currentScreenBoundsDependOnOrientation].size.width, [UIScreen currentScreenBoundsDependOnOrientation].size.height)];
    
    UIButton *btnBG = [[UIButton alloc] initWithFrame:viewSliders.frame];
    [btnBG addTarget:self action:@selector(hideContrastAndBrigthnessSliders) forControlEvents:UIControlEventTouchUpInside];
    [viewSliders addSubview:btnBG];
    
    sliderContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 254, 105)];
    
    [viewSliders addSubview:sliderContainerView];
    
    
    vcBrightnessSlider = (PaintSliderViewController *)[ControllersFactory instantiateViewControllerWithIdentifier:@"PaintSliderViewController" inStoryboard:kRedesignStoryboard];
    [vcBrightnessSlider setWithStartValue:BRIGHTNESS_DEFAULT_VALUE
                             minimumValue:BRIGHTNESS_MIN_VALUE
                                 maxValue:BRIGHTNESS_MAX_VALUE
                                    title:NSLocalizedString(@"paint_view_brightness_popup_title", @"")
                              andDelegate:self];
    vcBrightnessSlider.view.frame = CGRectMake(0, 0, 254, 52);
    [vcBrightnessSlider setIconWithText:@""];
    
    [sliderContainerView addSubview:vcBrightnessSlider.view];
    
    vcContrastSlider = (PaintSliderViewController *)[ControllersFactory instantiateViewControllerWithIdentifier:@"PaintSliderViewController" inStoryboard:kRedesignStoryboard];
    [vcContrastSlider setWithStartValue:OPACITY_DEFAULT_VALUE
                           minimumValue:OPACITY_MIN_VALUE
                               maxValue:OPACITY_MAX_VALUE
                               accuracy:SliderLabelAccuracy2F
                                  title:NSLocalizedString(@"paint_view_contrast_popup_title", @"")
                            andDelegate:self];
    vcContrastSlider.view.frame = CGRectMake(vcBrightnessSlider.view.frame.origin.x, vcBrightnessSlider.view.frame.origin.y + 52, vcBrightnessSlider.view.frame.size.width, vcBrightnessSlider.view.frame.size.height);
    [vcContrastSlider setIconWithText:@""];
    
    [sliderContainerView addSubview:vcContrastSlider.view];
    
    viewSliders.userInteractionEnabled = YES;
    viewSliders.hidden = YES;
    [self.view addSubview:viewSliders];
    [self.view bringSubviewToFront:viewSliders];
}

// hide the company table if company name is 'Generic' and only one company exists
-(void)hideCompanyTableView:(NSString *)companyName{
    
    if ([ConfigManager isShowCompaniesPaintActive]) {
        
        // we hide the company table only if the company name is "Generic" (and only one company exists - as checked in 'numberOfRowsInSection')
        if (![companyName isEqualToString:@"Generic"]){
            [self showCompanyTableView];
        }else{
            [self hideCopanyTableView];
        }
        
    }else{
        [self hideCopanyTableView];
    }
}

-(void)hideCopanyTableView{
    self.palleteView.hidden = NO;
    self.tableView.hidden = YES;
    [self.collectionView setFrame:CGRectMake(0, 0, self.palleteView.frame.size.width, self.palleteView.frame.size.height)];
}

// show the company table
-(void)showCompanyTableView
{
    self.palleteView.hidden = NO;
    self.tableView.hidden = NO;
    [self.collectionView setFrame:CGRectMake(0, 0, self.palleteView.frame.size.width, self.palleteView.frame.size.height)];
}


#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 87; //returns floating point which will be used for a cell row height at specified row index
}

#pragma mark- Override Base Class

- (IBAction)changeColorPressed:(id)sender {
    [super changeColorPressed:sender];
    self.toggleLineButton.selected=NO;
    _paintDrawOptionsContainerView.hidden=YES;
}

- (IBAction)changeColorPressedIphone:(id)sender {
    [super changeColorPressed:sender];
    
    //User pressed the back button
    if ([self.delegate respondsToSelector:@selector(cancelPressed:)]) {
        [self.delegate cancelPressed:self];
    }
}

-(void)fillCategories{
    NSArray * categories=self.selectedCompany.categories;
    
    [self.categoriesScroller.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i=0; i<[categories count]; i++) {
        
      UIButton * btn=  [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i;
//        btn.frame=CGRectMake(+i*50, 5, 45, 40);
        if (i==0) {
            btn.selected=YES;
        }
        [btn addTarget:self action:@selector(changeCategoryForColors:) forControlEvents:UIControlEventTouchUpInside];
        
        PaintColorCategoryDO * pcat=[categories objectAtIndex:i] ;
        [btn setBackgroundColor:[pcat.categoryColorHex hextoColorDIY]];
        
        [btn setTitle:@"1" forState:UIControlStateSelected];
        [self.categoriesScroller addSubview:btn];
        
    }
}

-(void)changeCategoryForColors:(id)sender{
    
    UIButton* btn=(UIButton*)sender;
    NSArray * categories=self.selectedCompany.categories;
    
    if ([self.selectedColorCategory isEqual:[categories objectAtIndex:btn.tag]]) {
        return;
    }
    self.selectedColorCategory=[categories objectAtIndex:btn.tag];
    
    [self.categoriesScroller.subviews makeObjectsPerformSelector:@selector(setSelected:) withObject:[NSNumber numberWithBool:NO]];
 
    btn.selected=YES;
    
    [self loadColorPaletteAnimated:YES];
}

- (IBAction)paintTypeLineAction:(id)sender {
    
    [self paintTypeChangedByType:ePaintLine];
    
    [self updateLineButtonIcon:sender];
    
    self.toggleLineButton.selected=NO;
    _paintDrawOptionsContainerView.hidden=YES;
}

- (IBAction)paintTypeFreeLineAction:(id)sender {
    
    [self paintTypeChangedByType:ePaintFreeLine];
    
    [self updateLineButtonIcon:sender];

    self.toggleLineButton.selected=NO;
    _paintDrawOptionsContainerView.hidden=YES;
}

- (IBAction)paintTypeFillAction:(id)sender {
    
    [self paintTypeChangedByType:ePaintFill];
    
    [self updateLineButtonIcon:sender];
    
    self.toggleLineButton.selected=NO;
    _paintDrawOptionsContainerView.hidden=YES;
}

- (void)updateLineButtonIcon:(id)sender
{
    HSNUIIconLabelButton *btn = (HSNUIIconLabelButton *) sender;

    [self.toggleLineButton setTitle:[btn.btnIcon titleForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.toggleLineButton setTitleColor:[btn.btnIcon titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
}

- (IBAction)toggleLineFeatures:(id)sender {
    //show or hide
    [self hideContrastAndBrigthnessSliders];
    if (self.toggleLineButton.selected) {
        //unselect and close
        self.toggleLineButton.selected=NO;
        _paintDrawOptionsContainerView.hidden=YES;
    }else{
        self.toggleLineButton.selected=YES;
        _paintDrawOptionsContainerView.hidden=NO;
    }
}

- (void)closePaintLikeOptions{
    [super closePaintLikeOptions];
    
    if ([self.brightnessButton isKindOfClass:[HSNUIIconLabelButton class]])
    {
        HSNUIIconLabelButton *nBtn = (HSNUIIconLabelButton *) self.brightnessButton;
        nBtn.btnIcon.selected = NO;
    }
    
    if (self.toggleLineButton.selected) {
        //unselect and close
        self.toggleLineButton.selected=NO;
        _paintDrawOptionsContainerView.hidden=YES;
    }
}

- (IBAction)paintRemoveToggleAction:(id)sender {
    
    if (!self.paintSession.gotAnythingToUndo) {
        return;
    }
    self.toggleLineButton.selected=NO;
    _paintDrawOptionsContainerView.hidden=YES;
    
    [[HelpManager sharedInstance] helpClosedForKey:@"remove_tip"];
    if ([sender isEqual:self.applyButton]) {
        self.applyButton.selected=YES;
        self.removeButton.selected=NO;
        
    } else {
        self.applyButton.selected=NO;
        self.removeButton.selected=YES;
    }
    [self updatePaintMode];
}

- (void) updatePaintMode {
    if (self.removeButton.selected) {
        self.paintSession.isPositive = NO;
        self.canvasView.brushColor = UIColorFromGrayLevelWithAlpha(255, 0.5);
    } else {
        self.paintSession.isPositive = YES;
        self.canvasView.brushColor = self.chosenColor;
    }
}

- (void) startedStrokeOnCanvasView:(RMCanvasView *)canvasView {
    [super startedStrokeOnCanvasView:canvasView];
}

- (IBAction)setPaintModeWallpaper:(id)sender {
    if (self.wallpaperModeButton.selected != YES) {
        self.colorModeButton.selected = NO;
        self.wallpaperModeButton.selected = YES;
        self.floorModeButton.selected = NO;
        [self.wallpaperModeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [self.colorModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.floorModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self wallpaperPickerPressed:sender];
    }
}

- (IBAction)setPaintModeFloor:(id)sender {
    if (self.floorModeButton.selected != YES) {
        self.floorModeButton.selected = YES;
        self.colorModeButton.selected = NO;
        self.wallpaperModeButton.selected = NO;
        [self.floorModeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [self.colorModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.wallpaperModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self floortilePickerPressed:sender];
    }
}

- (IBAction)setPaintModeColor:(id)sender {
    if (self.colorModeButton.selected != YES) {
        self.floorModeButton.selected = NO;
        self.colorModeButton.selected = YES;
        self.wallpaperModeButton.selected = NO;
        [self.colorModeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [self.floorModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.wallpaperModeButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self paintPickerPressed:sender];
    }
}

- (IBAction)websiteVisitAction:(id)sender {
    
    if (self.selectedCompanyWebSiteURL) {
        [self openInteralWebViewWithUrl:self.selectedCompanyWebSiteURL];
    }
}

#pragma mark - IBActions
- (IBAction)buttonBrightnessPressed:(id)sender
{
    [self closePaintLikeOptions];
    viewSliders.hidden = !viewSliders.hidden;
    
    if (viewSliders.hidden == NO)
    {
        self.brightnessButton.selected = YES;

        if ([self.brightnessButton isKindOfClass:[HSNUIIconLabelButton class]])
        {
            HSNUIIconLabelButton *nBtn = (HSNUIIconLabelButton *) self.brightnessButton;
            nBtn.btnIcon.selected = YES;
        }
    }
}

#pragma mark - Paint Slider Delegate

- (void)hideContrastAndBrigthnessSliders
{
    viewSliders.hidden = YES;
    
    self.brightnessButton.selected = NO;
    
    if ([self.brightnessButton isKindOfClass:[HSNUIIconLabelButton class]])
    {
        HSNUIIconLabelButton *nBtn = (HSNUIIconLabelButton *) self.brightnessButton;
        nBtn.btnIcon.selected = NO;
    }
}

- (void)showHelpAfterPaint
{
    [super showHelpAfterPaint];
}

-(void)adjustViewFrame:(UIButton *)currentBtn andCurrentView:(UIView *)currentView{

    CGFloat spacing = 8;
    CGRect btnFrame = currentBtn.frame;
    CGRect viewFrame = currentView.frame;

    //1
    CGFloat viewX = btnFrame.origin.x + btnFrame.size.width / 2 - viewFrame.size.width / 2;
    CGFloat viewMaxX = viewX + viewFrame.size.width;
    CGFloat availableMaxX =  [UIScreen mainScreen ].bounds.size.width - ([ConfigManager deviceTypeisIPhoneX] ? 40 : spacing );
    if (viewMaxX > availableMaxX) {
        viewMaxX = availableMaxX;
        viewX = viewMaxX - viewFrame.size.width;
    }
    CGFloat viewY = CGRectGetMinY(self.bottomBar.frame)-viewFrame.size.height - spacing;
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentView setFrame:CGRectMake(viewX, viewY, currentView.frame.size.width,  currentView.frame.size.height)];
    });
    
}

@end










