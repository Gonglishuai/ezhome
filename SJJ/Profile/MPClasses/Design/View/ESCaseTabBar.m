//
//  ESCaseTabBar.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseTabBar.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>

@interface ESCaseTabBar()

@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) void(^myblock)(NSString*);
@property (strong, nonatomic) ESCaseDetailModel *mycaseDetailModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightbuttonWidthLayoutConstraint;
@end

@implementation ESCaseTabBar

- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backgroundColor = [UIColor stec_viewBackgroundColor];

    _middleButton.backgroundColor = [UIColor whiteColor];
    [_middleButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    [_middleButton setTitle:@"加入我的样板间" forState:UIControlStateNormal];
    _rightButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightButton setTitle:@"预约" forState:UIControlStateNormal];
    _rightbuttonWidthLayoutConstraint.constant = self.bounds.size.width/2;
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _middleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        _rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    
}

+ (instancetype)creatWithFrame:(CGRect)frame Block:(void(^)(NSString*))block {
    ESCaseTabBar *caseTabBar = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    caseTabBar.frame = frame;
    caseTabBar.myblock = block;
    return caseTabBar;
}


- (void)setWithPersonInfo:(ESCaseDetailModel *)caseDetailModel {
    _mycaseDetailModel = caseDetailModel;
    _rightbuttonWidthLayoutConstraint.constant = self.bounds.size.width/2;
//    _rightButton.frame = CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, self.bounds.size.height);
    if (_mycaseDetailModel.productId && _mycaseDetailModel.productId.length>0) {
        if (caseDetailModel.showAddFav) {
            _middleButton.backgroundColor = [UIColor whiteColor];
            [_middleButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
            [_middleButton setTitle:@"加入我的样板间" forState:UIControlStateNormal];
            
        } else {
            _middleButton.backgroundColor = [UIColor stec_unabelButtonBackColor];
            [_middleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_middleButton setTitle:@"已加入我的样板间" forState:UIControlStateNormal];
        }
    } else {
//        _rightButton.frame = self.bounds;
        _rightbuttonWidthLayoutConstraint.constant = 0;
        
    }
    
}

- (void)setEdgeInsets {
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _middleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        _rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (IBAction)middleButtonClicked:(UIButton *)sender {
    if (_mycaseDetailModel.showAddFav) {
        if (_myblock) {
            _myblock(@"2");
        }
    }
}
- (IBAction)rightButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(@"3");
    }
}


@end
