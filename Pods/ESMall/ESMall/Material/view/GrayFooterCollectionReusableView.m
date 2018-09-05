//
//  GrayFooterCollectionReusableView.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "GrayFooterCollectionReusableView.h"

@implementation GrayFooterCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor stec_viewBackgroundColor];
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    _titleLabel.text = @"没有更多啦~";
    _titleLabel.hidden = YES;
}

- (IBAction)moreButtonDidTapped:(id)sender
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(moreButtonDidTapped)])
    {
        [self.viewDelegate moreButtonDidTapped];
    }
}

@end
