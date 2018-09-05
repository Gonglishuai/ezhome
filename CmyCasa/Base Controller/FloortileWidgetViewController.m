//
//  FloortileWidgetViewController.m
//  Homestyler
//
//  Created by Avihay Assouline on 1/15/14.
//
//

#import "FloortileWidgetViewController.h"



@interface FloortileWidgetViewController ()

@end

@implementation FloortileWidgetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sliderAngle.value = SLIDER_ANGLE_START_DEGREE;
    [self.sliderAngle setMinimumValue:SLIDER_ANGLE_MIN_DEGREE];
    [self.sliderAngle setMaximumValue:SLIDER_ANGLE_MAX_DEGREE];
    
    self.sliderDepth.value = SLIDER_WIDTH_START_VAL;
    [self.sliderDepth setMinimumValue:SLIDER_WIDTH_MIN_VAL];
    [self.sliderDepth setMaximumValue:SLIDER_WIDTH_MAX_VAL];
    
    self.sliderWidth.value = SLIDER_HEIGHT_START_VAL;
    [self.sliderWidth setMinimumValue:SLIDER_HEIGHT_MIN_VAL];
    [self.sliderWidth setMaximumValue:SLIDER_HEIGHT_MAX_VAL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)sliderAngleChanged:(UISlider*)sender
{
    [self.delegate floortileAngleChanged:[sender value] * 2 * M_PI/180];
}

- (IBAction)sliderDepthChanged:(UISlider *)sender
{
    [self.delegate floortileDepthChanged:[sender value]];
}
- (IBAction)sliderWidthChanged:(UISlider *)sender
{
    [self.delegate floortileWidthChanged:[sender value]];
}
- (IBAction)btnClose:(id)sender
{
    [self.delegate closeFloortileWidgetDialog];
}
@end
