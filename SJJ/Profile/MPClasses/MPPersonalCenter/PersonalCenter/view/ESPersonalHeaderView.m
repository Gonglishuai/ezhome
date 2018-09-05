//
//  ESPersonalHeaderView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESPersonalHeaderView.h"
#import "SHCenterTool.h"

@implementation ESPersonalHeaderView
{
    __weak IBOutlet UIButton *_userHeaderBtn;
    __weak IBOutlet UILabel *_userNameLabel;
    __weak IBOutlet UIButton *_headerViewRightBtn;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    _userHeaderBtn.layer.cornerRadius = 40.0f;
    _userHeaderBtn.layer.masksToBounds = YES;
}

- (void)updateHeaderView {
    if ([self.delegate respondsToSelector:@selector(userIsDesigner)]) {
        BOOL isDesigner = [self.delegate userIsDesigner];
        NSString *title = isDesigner ? @"主页" : @"";
        [_headerViewRightBtn setTitle:title forState:UIControlStateNormal];
        CGFloat left = isDesigner ? 41 : 0;
        [_headerViewRightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, left, 0, 0)];
        NSString *img = isDesigner ? @"arrow_right" : @"personal_qrcode";
        [_headerViewRightBtn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(getUserHeadIcon)]) {
        NSString *avatar = [self.delegate getUserHeadIcon];
        [SHCenterTool setHeadIcon:_userHeaderBtn avator:avatar];
    }
    
    if ([self.delegate respondsToSelector:@selector(getUserName)]) {
        NSString *name = [self.delegate getUserName];
        _userNameLabel.text = name;
    }
}

- (IBAction)userHeaderBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tapUserHeadIcon)]) {
        [self.delegate tapUserHeadIcon];
    }
}
- (IBAction)headerViewRightBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tapRightButton)]) {
        [self.delegate tapRightButton];
    }
}

@end
