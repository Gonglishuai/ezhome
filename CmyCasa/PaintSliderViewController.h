//
//  PaintSliderViewController.h
//  Homestyler
//
//  Created by Ma'ayan on 3/3/14.
//
//

#import <UIKit/UIKit.h>


@protocol PaintSliderDelegate <NSObject>

- (void)sliderValueChanged:(float)newValue sender:(id)sender;
- (void)sliderTouchUpWithValue:(float)currentValue sender:(id)sender;;
- (void)resetButtonPressedWithSender:(id)sender;

@end

typedef enum SliderLabelAccuracy
{
    SliderLabelAccuracy2F = 5001,
    SliderLabelAccuracy1F = 5002,
    SliderLabelAccuracyInt = 5003
} SliderLabelAccuracy;

@interface PaintSliderViewController : UIViewController

- (void)setWithStartValue:(float)fStart minimumValue:(float)fMin maxValue:(float)fMax title:(NSString *)title andDelegate:(id <PaintSliderDelegate>)delegate;
- (void)setWithStartValue:(float)fStart minimumValue:(float)fMin maxValue:(float)fMax accuracy:(SliderLabelAccuracy)acc title:(NSString *)title andDelegate:(id <PaintSliderDelegate>)delegate;
- (void)setIconWithText:(NSString*)icon;

@end
