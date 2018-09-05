
//
//  PaintViewController.m
//  CmyCasa
//
//  Created by Or Sharir on 1/21/13.
//
//

#import "AppDelegate.h"
#import "PaintViewController.h"
#import "ProgressPopupViewController.h"
#import "ControllersFactory.h"
#import "HSNUIIconLabelButton.h"

@interface PaintViewController ()
{
    UIView *viewContrastSlider;
    UIView *viewBrightnessSlider;
}

@end

@implementation PaintViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareSlidersView];
    [self.paintActionPaintButton setTitle:NSLocalizedString(@"Apply_btn", @"") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 140; //returns floating point which will be used for a cell row height at specified row index
}

#pragma mark - IBActions
- (void)hideContrastAndBrigthnessSliders
{
    if (viewContrastSlider.alpha>0) {
        [self toggleContrastSlider];
    }
    
    if (viewBrightnessSlider.alpha>0) {
        [self toggleBrightnessSlider];
    }
}

- (IBAction)buttonBrightnessPressed:(id)sender
{
    [self toggleBrightnessSlider];
}

- (IBAction)buttonContrastPressed:(id)sender
{
    [self toggleContrastSlider];
}

- (void)prepareSlidersView
{
    CGFloat fWidth = 328;
    CGFloat fHeight = 100;
    
    viewBrightnessSlider = [[UIView alloc] initWithFrame:self.view.bounds];
    viewBrightnessSlider.userInteractionEnabled = YES;
    viewBrightnessSlider.alpha = 0;

    viewContrastSlider = [[UIView alloc] initWithFrame:self.view.bounds];
    viewContrastSlider.userInteractionEnabled = YES;
    viewContrastSlider.alpha = 0;

    UIButton *btnCloseSliderBrightness = [[UIButton alloc] initWithFrame:viewBrightnessSlider.frame];
    [btnCloseSliderBrightness addTarget:self action:@selector(hideContrastAndBrigthnessSliders) forControlEvents:UIControlEventTouchUpInside];
    [viewBrightnessSlider addSubview:btnCloseSliderBrightness];
    
    UIButton *btnCloseSliderContrast = [[UIButton alloc] initWithFrame:viewBrightnessSlider.frame];
    [btnCloseSliderContrast addTarget:self action:@selector(hideContrastAndBrigthnessSliders) forControlEvents:UIControlEventTouchUpInside];
    [viewContrastSlider addSubview:btnCloseSliderContrast];

    vcBrightnessSlider = (PaintSliderViewController *)[ControllersFactory instantiateViewControllerWithIdentifier:@"PaintSliderViewController" inStoryboard:kRedesignStoryboard];
    [vcBrightnessSlider setWithStartValue:BRIGHTNESS_DEFAULT_VALUE
                             minimumValue:BRIGHTNESS_MIN_VALUE
                                 maxValue:BRIGHTNESS_MAX_VALUE
                                    title:NSLocalizedString(@"paint_view_brightness_popup_title", @"")
                              andDelegate:self];
    
    vcBrightnessSlider.view.frame = CGRectMake([UIScreen currentScreenBoundsDependOnOrientation].size.width - fWidth - 260, [UIScreen currentScreenBoundsDependOnOrientation].size.height - fHeight - 70, fWidth, fHeight);
    
    [viewBrightnessSlider addSubview:vcBrightnessSlider.view];

    vcContrastSlider = (PaintSliderViewController *)[ControllersFactory instantiateViewControllerWithIdentifier:@"PaintSliderViewController" inStoryboard:kRedesignStoryboard];
    [vcContrastSlider setWithStartValue:OPACITY_DEFAULT_VALUE
                           minimumValue:OPACITY_MIN_VALUE
                               maxValue:OPACITY_MAX_VALUE
                                accuracy:SliderLabelAccuracy2F
                                   title:NSLocalizedString(@"paint_view_contrast_popup_title", @"")
                            andDelegate:self];
    
    vcContrastSlider.view.frame = CGRectMake([UIScreen currentScreenBoundsDependOnOrientation].size.width - fWidth - 180, [UIScreen currentScreenBoundsDependOnOrientation].size.height - fHeight - 70, fWidth, fHeight);

    [viewContrastSlider addSubview:vcContrastSlider.view];
    
    [self.view addSubview:viewBrightnessSlider];
    [self.view bringSubviewToFront:viewBrightnessSlider];

    [self.view addSubview:viewContrastSlider];
    [self.view bringSubviewToFront:viewContrastSlider];
}

- (void)toggleBrightnessSlider
{
    [self closePaintLikeOptions];
    
    if (viewContrastSlider.alpha)
    {
        [self toggleContrastSlider];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.2 animations:^
                        {
                            viewBrightnessSlider.alpha = 1 - viewBrightnessSlider.alpha;
                            
                        } completion:^ (BOOL finished)
                        {
                            if (viewBrightnessSlider.alpha > 0)
                            {
                                self.brightnessButton.selected = YES;
                            }
                        }];
                   });
}

- (void)toggleContrastSlider
{
    [self closePaintLikeOptions];

    if (viewBrightnessSlider.alpha)
    {
        [self toggleBrightnessSlider];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.2 animations:^
                        {
                            viewContrastSlider.alpha = 1 - viewContrastSlider.alpha;
                            
                        } completion:^ (BOOL finished)
                        {
                            if (viewContrastSlider.alpha > 0)
                            {
                                self.contrastButton.selected = YES;
                            }
                        }];
                   });
}

- (void)wallpaperPickFinished
{
    [super wallpaperPickFinished];
    
    [self togglePaintDrawAction:self.painFillButton];
    [self togglePaintAction:self.paintActionPaintButton];
}

- (IBAction)togglePaintDrawAction:(id)sender {
    
    UIButton *btnSender = (UIButton *) sender;
    int index = 0;
    
    self.painFillButton.selected = NO;
    self.paintLineButton.selected = NO;
    self.paintCurveButton.selected = NO;
    
    [self.paintActionPaintButton setTitleColor:[btnSender titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];
    [self.paintActionRemoveButton setTitleColor:[btnSender titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];
    [self.paintActionPaintButton.btnIcon setTitleColor:[btnSender titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];
    [self.paintActionRemoveButton.btnIcon setTitleColor:[btnSender titleColorForState:UIControlStateSelected] forState:UIControlStateSelected];

    if ([sender isEqual:self.painFillButton]) {
        self.painFillButton.selected = YES;

        index = 0;
    }
    
    if ([sender isEqual:self.paintLineButton]) {
        self.paintLineButton.selected = YES;
        
        index = 1;
    }

    if ([sender isEqual:self.paintCurveButton]) {
        self.paintCurveButton.selected = YES;
        
        index = 2;
    }
    [self paintTypeChangedByType:index];
}


- (IBAction)togglePaintAction:(id)sender {
    
    if ([sender isEqual:self.paintActionRemoveButton]) {
        self.paintActionRemoveButton.selected = YES;
        self.paintActionRemoveButton.btnIcon.selected = YES;
        self.paintActionPaintButton.selected = NO;
        self.paintActionPaintButton.btnIcon.selected = NO;
    }
    if ([sender isEqual:self.paintActionPaintButton]) {
        self.paintActionRemoveButton.selected = NO;
        self.paintActionRemoveButton.btnIcon.selected = NO;
        self.paintActionPaintButton.selected = YES;
        self.paintActionPaintButton.btnIcon.selected = YES;
    }
    [self updatePaintMode];
}

- (void) updatePaintMode {
    [super updatePaintMode];
    if (self.paintActionRemoveButton.selected == YES ) {
        self.paintSession.isPositive = NO;
        self.canvasView.brushColor = UIColorFromGrayLevelWithAlpha(255, 0.5);
    } else {
        self.canvasView.brushColor = self.chosenColor;
        self.paintSession.isPositive = YES;
    }
}

- (void) startedStrokeOnCanvasView:(RMCanvasView *)canvasView {
    if (self.paintLineButton.selected) {
        bIsFirstTimeForLine = NO;
    }
}

- (void)showHelpAfterPaint
{
    [super showHelpAfterPaint];
    
    if (self.paintActionPaintButton.selected == YES &&
        self.painFillButton.selected== YES )
    {
        [[HelpManager sharedInstance] presentHelpViewController:@"remove_tip" withController:self isForceToShow:YES];
    }
}


// hide the company icons table by resizing the palleteView
-(void)hideCompanyTableView:(NSString *)companyName
{
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
    float newWidth;
    float newXOrigin;
    self.palleteView.hidden = NO;
    
    newWidth = [UIScreen currentScreenBoundsDependOnOrientation].size.width - self.stylesLeftPickerView.frame.size.width - 1;
    newXOrigin = self.tableView.frame.origin.x + 1;
    
    // set the pallete above the company table
    DISPATCH_ASYNC_ON_MAIN_QUEUE([self.palleteView setFrame:CGRectMake(newXOrigin,self.palleteView.frame.origin.y,newWidth,self.palleteView.frame.size.height)]);
    [self.collectionView setFrame:CGRectMake(0, 0, newWidth, self.palleteView.frame.size.height)];
}

// show the company icons table by resizing the palleteView
-(void)showCompanyTableView
{
    self.palleteView.hidden = NO;
    float newWidth = [UIScreen currentScreenBoundsDependOnOrientation].size.width - self.stylesLeftPickerView.frame.size.width - self.tableView.frame.size.width - 1;
    float newXOrigin = self.tableView.frame.origin.x + self.tableView.frame.size.width + 1;
    
    DISPATCH_ASYNC_ON_MAIN_QUEUE([self.palleteView setFrame:CGRectMake(newXOrigin, self.palleteView.frame.origin.y, newWidth, self.palleteView.frame.size.height)]);
    [self.collectionView setFrame:CGRectMake(0, 0, newWidth, self.palleteView.frame.size.height)];
}

@end
