//
//  CheckMoreReusableView.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "CheckMoreReusableView.h"

@interface CheckMoreReusableView()

@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkMoreButton;
@property (strong, nonatomic) void(^myblock)(void);
@end

@implementation CheckMoreReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
    [_checkMoreButton setTitleColor:[UIColor stec_subTitleTextColor] forState:UIControlStateNormal];
    
}

- (void)setBlock:(void(^)(void))block {
    _myblock = block;
}
- (IBAction)checkMoreButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
