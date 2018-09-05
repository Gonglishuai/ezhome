//
//  ImageBackgroundEffectsViewController.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import "ImageBackgroundEffectsViewController.h"

@interface ImageBackgroundEffectsViewController ()

@end

@implementation ImageBackgroundEffectsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.brightnessSlider setMaximumValue:[[ConfigManager sharedInstance] backgroundBrightnessMaxValue]];
    [self.brightnessSlider setMinimumValue:[[ConfigManager sharedInstance] backgroundBrightnessMinValue]];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)initBrightnessLevel:(float)brightnessLevel
{
    self.initBrightnessLevel = brightnessLevel;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.brightnessSlider setValue:brightnessLevel animated:NO];
    });
}

- (IBAction)brightnessSliderChanged:(UISlider *)sender
{
    if (!self.delegate)
        return;
    
    if ([self.delegate respondsToSelector:@selector(changeBackgroundBrightness:)])
        [self.delegate changeBackgroundBrightness:[sender value]];
    
}

- (IBAction)cancelPressed:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (!self.delegate)
        return;
    
    if ([self.delegate respondsToSelector:@selector(cancelBackgroundBrightnessChange:)])
        [self.delegate cancelBackgroundBrightnessChange:self.initBrightnessLevel];

}

- (IBAction)donePressed:(id)sender
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (!self.delegate)
        return;
    
    if ([self.delegate respondsToSelector:@selector(acceptBackgroundBrightnessChange:)])
        [self.delegate acceptBackgroundBrightnessChange:self.brightnessSlider.value];
}

- (IBAction)resetPressed:(id)sender
{
    [self.brightnessSlider setValue:self.initBrightnessLevel];
    
    if (!self.delegate)
        return;
    
    if ([self.delegate respondsToSelector:@selector(changeBackgroundBrightness:)])
        [self.delegate changeBackgroundBrightness:self.initBrightnessLevel];
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

@end
