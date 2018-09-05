//
//  ImageBackgroundEffectsViewController.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import <UIKit/UIKit.h>

#define IMAGE_BACKGROUND_DEFAULT_VALUE  (1.0)

///////////////////////////////////////////////////////
//                  PROTOCOL                         //
///////////////////////////////////////////////////////
/** Define the protocol for returning the user's choice to **/
/** the caller                                             **/
@protocol ImageBackgroundEffectsDelegate <NSObject>
@required
- (void)changeBackgroundBrightness:(float)brightnessLevel;
- (void)cancelBackgroundBrightnessChange:(float)originalBrightnessLevel;
- (void)acceptBackgroundBrightnessChange:(float)brightnessLevel;
@end


///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////
@interface ImageBackgroundEffectsViewController : UIViewController

- (void)initBrightnessLevel:(float)brightnessLevel;

///////////////////// IBActions //////////////////////
- (IBAction)brightnessSliderChanged:(UISlider *)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;
- (IBAction)resetPressed:(id)sender;

///////////////////// Properties //////////////////////
@property (strong, nonatomic) id<ImageBackgroundEffectsDelegate> delegate;
@property (nonatomic) float initBrightnessLevel;

///////////////////// Outlets /////////////////////////
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *cancelButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *doneButton;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@end
