//
//  PaintBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import <UIKit/UIKit.h>
#import "PaintProtocols.h"
#import "UIPaintSession.h"
#import "UIPaintView.h"
#import "General3DViewController+CubeAccess.h"
#import "SinglePaletteColorViewController.h"
#import "SinglePaletteWallpaperViewController.h"
#import "FloortileWidgetViewController.h"
#import "UIColorMacros.h"
#import "CollectionViewCell.h"
#import "PaintSliderViewController.h"
#import "HSNUIIconLabelButton.h"

// Brightness/Opacity default/min/max values for paint sliders
// TODO (Avihay/Maayan): Refactor PaintSlider so this will not be in this header but in the .m file
#define BRIGHTNESS_DEFAULT_VALUE    (0)
#define BRIGHTNESS_MAX_VALUE        (100)
#define BRIGHTNESS_MIN_VALUE        (-100)
#define OPACITY_DEFAULT_VALUE       (1)
#define OPACITY_MAX_VALUE           (1)
#define OPACITY_MIN_VALUE           (0)

///////////////////////////////////////////////////////
//           CLASS FORWARD DECLARETION               //
///////////////////////////////////////////////////////
@class ProtocolsDef;
@class CubeAccess;
@class FlurryDefs;
@class PaintCompanyDO;
@class PaintColorCategoryDO;
@class PSTCollectionView;
@class WallpapersManager;
@class WallpaperCompanyDO;
@class TilingDO;
@class FloortileDO;
@class FloortileCompanyDO;
@class FloortilesManager;

//GAITrackedViewController
///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface PaintBaseViewController : UIViewController<UIPaintViewDelegate, SinglePaletteColorDelegate, FloortileWidgetDelegate, SinglePaletteWallpaperDelegate,UICollectionViewDataSource, UICollectionViewDelegate, PaintSliderDelegate, GenericWebViewDelegate>{

    @protected
    BOOL bIsFirstTimeForLine;
    
    PaintSliderViewController *vcBrightnessSlider;
    PaintSliderViewController *vcContrastSlider;
}

///////////////////// Properties //////////////////////
@property (weak, nonatomic) IBOutlet UIView *undoRedoView;

@property (strong, nonatomic) UIPaintSession* paintSession;
@property (assign, nonatomic) PaintMode paintMode;
@property(nonatomic)PaintCompanyDO * selectedCompany;
@property (strong, nonatomic)  WallpaperCompanyDO* selectedWallpaperCompany;
@property (weak, nonatomic) id <DoneNavigationDelegate> delegate;
@property(nonatomic)PaintColorCategoryDO * selectedColorCategory;
@property (strong, nonatomic) UIPaintView* canvasView;
@property (assign) BOOL firstTime;
@property (nonatomic)   NSString * _chosenColorName;
@property (strong, nonatomic) FloortileWidgetViewController *floortileWidget;
@property (strong, nonatomic) FloortileCompanyDO* selectedFloortileCompany;
@property (strong, nonatomic) NSNumber* floorAngle;
@property (strong, nonatomic) NSNumber* floorWidthDelta;
@property (strong, nonatomic) NSNumber* floorHeightDelta;
@property (nonatomic, strong) NSString * selectedCompanyWebSiteURL;
///////////////////// Outlets /////////////////////////

@property (weak, nonatomic) UIColor *chosenColor;
@property (weak, nonatomic) UIImage *chosenPattern;
@property (nonatomic) CGFloat renderedPatternResizeFactor;
@property (nonatomic) CGPoint currentScribblePoint;
@property (strong, nonatomic) UIImage * originalImage;
@property (strong, nonatomic) UIImage * predefineMask;
@property (weak, nonatomic) IBOutlet UIButton               *websiteButton;
@property (weak, nonatomic) IBOutlet UIImageView            *backgroundImage;
@property (weak, nonatomic) IBOutlet UIButton               *undoButton;
@property (weak, nonatomic) IBOutlet UIButton               *redoButton;
@property (weak, nonatomic) IBOutlet UIImageView            *patternLabel;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton   *paintPickerButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton   *wallpaperPickerButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton   *floorButton;

@property (weak, nonatomic) IBOutlet UIView *stylesLeftPickerView;

@property (weak, nonatomic) IBOutlet UIView             * palleteView;
@property (weak, nonatomic) IBOutlet UIView             * colorWallpaperPicker;
@property (weak, nonatomic) IBOutlet UIView             * bottomBar;
@property (weak, nonatomic) IBOutlet UILabel            * chosenColorLabel;
@property (weak, nonatomic) IBOutlet UIButton           * brightnessButton;
@property (weak, nonatomic) IBOutlet UIButton           * contrastButton;
@property (weak, nonatomic) IBOutlet UIButton           * adjustButton;

///////////////////// Actions /////////////////////////
- (IBAction)paintRemoveToggleAction:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)changeColorPressed:(id)sender;

- (IBAction)paintPickerPressed:(id)sender;
- (IBAction)wallpaperPickerPressed:(id)sender;
- (IBAction)floortilePickerPressed:(id)sender;

- (IBAction)undoPressed:(id)sender;
- (IBAction)redoPressed:(id)sender;
- (IBAction)buttonBrightnessPressed:(id)sender;
- (IBAction)buttonContrastPressed:(id)sender;
- (IBAction)toggleFloortileWidget:(id)sender;
- (void)showHelpAfterPaint;
- (void)paintTypeChanged:(id)sender;

///////////////////// Methods /////////////////////////
- (void)loadColorPaletteAnimated:(BOOL)animated;
- (void)fillCategories;
- (void)setChoosenColorName:(NSString*)colorIDName;
- (void)hideContrastAndBrigthnessSliders;
- (void)updatePaintMode;
- (void)reset;
- (void)wallpaperPickFinished;
- (void)closePaintLikeOptions;
- (void) startedStrokeOnCanvasView:(RMCanvasView *)canvasView;

// Avihay 6/3/2014
- (void)paintRetinexBrightnessChanged:(float)brightnessLevel;
- (void)paintRetinexOpacityChanged:(float)opacityLevel;
@property (strong, nonatomic) NSNumber* brightnessLevel;    //  Brightness level of the retinex algorithm
@property (strong, nonatomic) NSNumber* opacityLevel;       //  Opacity level of the retinex algorithm


@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (assign, nonatomic) PaintItemType paintType;
- (void)paintTypeChangedByType:(PaintItemType)pIntexType;
#pragma mark-
#pragma mark - Iphone
@property (weak, nonatomic) IBOutlet UIButton *undoActionButton;
@property (weak, nonatomic) IBOutlet UIButton *reduActionButton;
@property (strong, nonatomic)  UICollectionView *collectionView;

@end
