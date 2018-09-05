//
//  iphonePaintViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import "PaintBaseViewController.h"

@interface PaintViewController_iPhone : PaintBaseViewController{
    UIView *viewSliders;
    UIView *sliderContainerView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *categoriesScroller;
@property (weak, nonatomic) IBOutlet UIView *bottomCategoriesContainer;
@property (weak, nonatomic) IBOutlet UIView *topLeftContainer;
@property (weak, nonatomic) IBOutlet UIButton *toggleLineButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *colorModeButton;
@property (weak, nonatomic) IBOutlet UIButton *floorModeButton;
@property (weak, nonatomic) IBOutlet UIButton *wallpaperModeButton;
@property (nonatomic)BOOL isPeekOpen;
@property (nonatomic)BOOL canAnimatePeeking;

- (IBAction)changeColorPressedIphone:(id)sender ;
- (IBAction)changeColorPressed:(id)sender;
- (IBAction)paintTypeLineAction:(id)sender;
- (IBAction)paintTypeFreeLineAction:(id)sender;
- (IBAction)paintTypeFillAction:(id)sender;
- (IBAction)toggleLineFeatures:(id)sender;
- (IBAction)setPaintModeWallpaper:(id)sender;
- (IBAction)setPaintModeColor:(id)sender;
- (IBAction)websiteVisitAction:(id)sender;

@end
