//
//  ImageEffectShareBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 10/14/13.
//
//

#import "ImageEffectShareBaseViewController.h"
#import "SaveDesignBaseViewController.h"
#import "HSSharingLogic.h"
#import "ImageEffectsBaseViewController.h"
#import "ProtocolsDef.h"


@interface ImageEffectShareBaseViewController ()

@end

@implementation ImageEffectShareBaseViewController

-(void)initWithShareData:(HSShareObject*)shareObj{
    
    shareObj.canComposeMessage = YES;
    [super initWithShareData:shareObj];
    
    [self refreshUIData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lblShareDesignTitle.text = NSLocalizedString(@"share_your_design_title", @"");
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if (IS_IPHONE) {
        
        self.view.frame = [UIScreen currentScreenBoundsDependOnOrientation];
    }
}

#pragma mark - Orientation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{    
    return UIInterfaceOrientationMaskLandscape;
}


- (IBAction)skipAction:(id)sender {
    if (self.saveDesignFlowDelegate) {
        [self.saveDesignFlowDelegate skipStepRequested];
    }
}

- (IBAction)backAction:(id)sender {
    
    if ([self.arDelegate respondsToSelector:@selector(comeBackFromArController)]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.arDelegate comeBackFromArController];
        return;
    }
    
    if ([self.saveDesignFlowDelegate respondsToSelector:@selector(prevStepRequested:)]) {
        [self.saveDesignFlowDelegate prevStepRequested:SaveDesignShareKey];
    }
}

#pragma mark- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if (IS_IPAD) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect  frm=  self.viewContainer.frame;
            frm.origin.y=-260;
            self.viewContainer.frame=frm;
            
        } completion:^(BOOL finished) {
            
        } ];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (IS_IPAD) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            
            CGRect  frm=  self.viewContainer.frame;
            
            frm.origin.y=45;
            self.viewContainer.frame=frm;
            
        } completion:^(BOOL finished) {
            
        } ];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView  resignFirstResponder];
    }
    
    return YES;
}

@end
