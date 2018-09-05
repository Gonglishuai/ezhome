//
//  ESTagCollectionViewCell.m
//  EZHome
//
//  Created by shiyawei on 6/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESTagCollectionViewCell.h"
#import "Masonry.h"

@interface ESTagCollectionViewCell ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation ESTagCollectionViewCell

- (void)setContentString:(NSString *)contentString
{
    _contentString = [contentString copy];
    self.label.text = _contentString;
    [self addSubview:self.label];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.layer.cornerRadius = 5;
        _label.layer.masksToBounds = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"1233";
        _label.layer.borderColor = ColorFromRGA(0xDCDFE6, 1.0).CGColor;
        _label.textColor = ColorFromRGA(0xDCDFE6, 1.0);
        _label.layer.borderWidth = 1;
        _label.font = [UIFont systemFontOfSize:12];
    }
    return _label;
}

@end
