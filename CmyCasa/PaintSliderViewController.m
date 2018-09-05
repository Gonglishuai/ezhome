//
//  PaintSliderViewController.m
//  Homestyler
//
//  Created by Ma'ayan on 3/3/14.
//
//

#import "PaintSliderViewController.h"

@interface PaintSliderViewController ()
{
    float fMinValue;
    float fMaxValue;
    float fStartValue;
    
    NSString *strTitle;
    SliderLabelAccuracy accuracy;
}

@property (nonatomic, weak) IBOutlet UIButton *buttonRefresh;
@property (nonatomic, weak) IBOutlet UILabel *labelValue;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet UISlider *sliderValue;
@property (nonatomic, weak) IBOutlet UILabel *icon;

@property (nonatomic, weak) id <PaintSliderDelegate> delegate;


- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end

@implementation PaintSliderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sliderValue.minimumValue = fMinValue;
    self.sliderValue.maximumValue = fMaxValue;
    
    [self.sliderValue setValue:fStartValue animated:NO];

    [self updateLabelValue];
    
    self.labelTitle.text = strTitle;
    
    self.buttonRefresh.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)setWithStartValue:(float)fStart minimumValue:(float)fMin maxValue:(float)fMax title:(NSString *)title andDelegate:(id <PaintSliderDelegate>)delegate
{
    self.sliderValue.minimumValue = fMin;
    fMinValue = fMin;
    self.sliderValue.maximumValue = fMax;
    fMaxValue = fMax;
    
    [self.sliderValue setValue:fStart animated:NO];
    fStartValue = fStart;
    
    self.labelTitle.text = title;
    strTitle = title;
    
    self.delegate = delegate;
    accuracy = SliderLabelAccuracyInt;
}

- (void)setWithStartValue:(float)fStart minimumValue:(float)fMin maxValue:(float)fMax accuracy:(SliderLabelAccuracy)acc title:(NSString *)title andDelegate:(id <PaintSliderDelegate>)delegate
{
    [self setWithStartValue:fStart minimumValue:fMin maxValue:fMax title:title andDelegate:delegate];
    accuracy = acc;
}

- (IBAction)sliderValueChanged:(id)sender
{
    [self updateButtonAvailability];
    
    [self updateLabelValue];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(sliderValueChanged:sender:)]))
                       {
                           [self.delegate sliderValueChanged:self.sliderValue.value sender:self];
                       }
                   });
}

- (IBAction)sliderTouchUpInside:(id)sender
{
    [self updateButtonAvailability];
    
    [self updateLabelValue];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                        {
                            if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(sliderTouchUpWithValue:sender:)]))
                            {
                                [self.delegate sliderTouchUpWithValue:self.sliderValue.value sender:self];
                            }
                        });
}

- (IBAction)resetButtonPressed:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.sliderValue setValue:fStartValue animated:YES];
                       [self updateButtonAvailability];
                       [self updateLabelValue];
                   });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(sliderTouchUpWithValue:sender:)]))
                       {
                           [self.delegate sliderTouchUpWithValue:self.sliderValue.value sender:self];
                       }
                   });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(resetButtonPressedWithSender:)]))
                       {
                           [self.delegate resetButtonPressedWithSender:self];
                       }
                   });
}

- (void)updateLabelValue
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.labelValue.text = [self labelTextForValue:self.sliderValue.value];
                   });
}

- (void)updateButtonAvailability
{
    int iValueNow = (int) self.sliderValue.value;
    
    if (iValueNow != fStartValue)
    {
        self.buttonRefresh.enabled = YES;
    }
    else
    {
        self.buttonRefresh.enabled = NO;
    }
}

- (NSString *)labelTextForValue:(float)value
{
    float threshold2f = 0.005f;
    float threshold1f = 0.05f;
    
    float fDiff = fabsf(value - roundf(value));

    if ((accuracy == SliderLabelAccuracy2F) && (fDiff > threshold2f))
    {
        return [NSString stringWithFormat:@"%.2f", self.sliderValue.value];
    }
    else if (((accuracy == SliderLabelAccuracy2F) || (accuracy == SliderLabelAccuracy1F)) && (fDiff > threshold1f))
    {
        return [NSString stringWithFormat:@"%.1f", self.sliderValue.value];
    }

    return [NSString stringWithFormat:@"%d", (int) self.sliderValue.value];
}

#pragma mark - Public

- (void)setIconWithText:(NSString *)icon
{
    self.icon.text = icon;
}

@end
