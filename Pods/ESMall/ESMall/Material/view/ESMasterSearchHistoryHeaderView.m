//
//  ESMasterSearchHistoryHeaderView.m
//  Mall
//
//  Created by jiang on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMasterSearchHistoryHeaderView.h"

@interface ESMasterSearchHistoryHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) void(^myblock)(void);

@end

@implementation ESMasterSearchHistoryHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.font = [UIFont stec_remarkTextFount];
    _titleLabel.textColor = [UIColor stec_contentTextColor];
    [_deleteButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title Block:(void(^)(void))block {
    _titleLabel.text = title;
    _myblock = block;
}

- (IBAction)deleteButtonClicked:(id)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
