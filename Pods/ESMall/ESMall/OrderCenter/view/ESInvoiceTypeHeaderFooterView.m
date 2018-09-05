//
//  ESInvoiceTypeHeaderFooterView.m
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceTypeHeaderFooterView.h"

@interface ESInvoiceTypeHeaderFooterView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) void(^myblock)(NSString *);
@end

@implementation ESInvoiceTypeHeaderFooterView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.font = [UIFont stec_subTitleFount];
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    [_changeButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    
}

- (void)setTitle:(NSString *)title selected:(BOOL)selected isHistory:(BOOL)isHistory block:(void(^)(NSString *))block {
    _titleLabel.text = title;
    _myblock = block;
    _changeButton.hidden = isHistory;
    if (selected) {
        _selectImageView.image = [UIImage imageNamed:@"pay_way_select"];
    } else {
        _selectImageView.image = [UIImage imageNamed:@"pay_way_unselect"];
    }
    if (selected && isHistory) {
        _changeButton.hidden = NO;
    } else {
        _changeButton.hidden = YES;
    }
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(@"1");
    }
}
- (IBAction)changeButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(@"2");
    }
}

@end
