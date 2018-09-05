//
//  ImageOptionsDialogView.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 7/28/14.
//
//

#import "ImageOptionsDialogView.h"

@implementation ImageOptionsDialogView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [_concealerBtn setTitle:NSLocalizedString(@"concealer_button", @"") forState:UIControlStateNormal];
    [_brightnessBtn setTitle:NSLocalizedString(@"brightness_button", @"") forState:UIControlStateNormal];
}

-(IBAction)concealerClicked:(id)sender{
    if([self.delegate respondsToSelector:@selector(concealClicked)]){
        [self.delegate performSelector:@selector(concealClicked)];
    }
}

-(IBAction)brightnessClicked:(id)sender{
    if([self.delegate respondsToSelector:@selector(brightnessClicked)]){
        [self.delegate performSelector:@selector(brightnessClicked)];
    }
}

-(IBAction)closeImageOptionsDialogView:(id)sender{
    if([self.delegate respondsToSelector:@selector(closeImageOptionsDialogView)]){
        [self.delegate performSelector:@selector(closeImageOptionsDialogView)];
    }
}
@end
