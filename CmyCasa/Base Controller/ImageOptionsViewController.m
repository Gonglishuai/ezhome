//
//  ImageOptionsViewController.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/8/13.
//
//

#import "ImageOptionsViewController.h"

@interface ImageOptionsViewController ()

@end

@implementation ImageOptionsViewController

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
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)returnPressed:(id)sender
{
    [self.delegate chooseImageOption:IMAGE_OPTION_NONE];
}

- (IBAction)concealPressed:(id)sender
{
    [self.delegate chooseImageOption:IMAGE_OPTION_CONCEAL];
}

- (IBAction)brightnessPressed:(id)sender
{
    [self.delegate chooseImageOption:IMAGE_OPTION_BRIGHTNESS];
}

@end
