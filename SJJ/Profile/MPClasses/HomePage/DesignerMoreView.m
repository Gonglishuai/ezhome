//
//  DesignerMoreView.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "DesignerMoreView.h"

@interface DesignerMoreView()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *moreLabel;
@property (strong, nonatomic) void(^myblock)(void); ;
@end

@implementation DesignerMoreView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    _backImageView.clipsToBounds = YES;
    _backImageView.layer.cornerRadius = 2;
    _moreLabel.textColor = [UIColor stec_titleTextColor];
    _moreLabel.font = [UIFont stec_bigTitleFount];
    _moreLabel.textColor = [UIColor stec_subTitleTextColor];
    _moreLabel.layer.borderWidth = 1.5;
    _moreLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
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
