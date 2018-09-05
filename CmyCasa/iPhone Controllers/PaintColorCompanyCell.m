//
//  PaintColorCompanyCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/6/13.
//
//

#import "PaintColorCompanyCell.h"

@implementation PaintColorCompanyCell

#pragma mark -UseFor IphoneX LayOut-
-(void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectionBG.hidden=!selected;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.companyLogo.image = nil;
}

- (IBAction)openWebSiteAction:(id)sender
{
    if (self.websiteURL && [NSURL URLWithString:self.websiteURL]) {
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:self.websiteURL];
        }
    }
}
@end
