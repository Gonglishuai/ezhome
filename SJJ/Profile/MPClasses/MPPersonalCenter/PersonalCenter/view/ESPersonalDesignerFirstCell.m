//
//  ESPersonalDesignerFirstCell.m
//  Consumer
//
//  Created by Jiao on 2017/7/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESPersonalDesignerFirstCell.h"

@implementation ESPersonalDesignerFirstCell
{
    __weak IBOutlet UIView *_myBiddingView;
    __weak IBOutlet UIView *_myProjectView;
    __weak IBOutlet UIView *_myAssetsView;
    
    __weak IBOutlet UIImageView *_biddingImgView;
    __weak IBOutlet UIImageView *_projectImgView;
    __weak IBOutlet UIImageView *_assetImgView;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyBiddingView:)];
    [_myBiddingView addGestureRecognizer:tgr1];
    
    UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyProjectView:)];
    [_myProjectView addGestureRecognizer:tgr2];
    
    UITapGestureRecognizer *tgr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyAssetsView:)];
    [_myAssetsView addGestureRecognizer:tgr3];
    
    
    [_biddingImgView setImage:[_biddingImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [_projectImgView setImage:[_projectImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [_assetImgView setImage:[_assetImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

- (void)tapMyBiddingView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tapMyBidding)]) {
        [self.delegate tapMyBidding];
    }
}

- (void)tapMyProjectView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tapDesignerMyProject)]) {
        [self.delegate tapDesignerMyProject];
    }
}

- (void)tapMyAssetsView:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tapMyAssets)]) {
        [self.delegate tapMyAssets];
    }
}

@end
