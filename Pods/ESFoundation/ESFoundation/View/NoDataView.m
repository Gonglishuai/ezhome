//
//  NoDataView.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "NoDataView.h"
#import "UIColor+Stec.h"
#import "UIFont+Stec.h"
#import "ESFoundationAssets.h"
@interface NoDataView()
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) void(^myblock)(void);
@end

@implementation NoDataView

+ (instancetype)creatWithImgName:(NSString *)imgName title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)(void))block {
    NoDataView *noDataView = [[ESFoundationAssets hostBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:kNilOptions].lastObject;
    noDataView.myblock = block;
    noDataView.titleLabel.textColor = [UIColor stec_subTitleTextColor];
    noDataView.titleLabel.font = [UIFont stec_titleFount];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    
    noDataView.titleLabel.attributedText = attributedString;
    noDataView.titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([buttonTitle isEqualToString:@""] || buttonTitle == nil) {
        noDataView.actionButton.hidden = YES;
    } else {
        noDataView.actionButton.hidden = NO;
        [noDataView.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
        [noDataView.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        noDataView.actionButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        noDataView.actionButton.clipsToBounds = YES;
        noDataView.actionButton.layer.cornerRadius = 20.5f;
        
    }
    noDataView.mainImageView.image = [UIImage imageNamed:imgName];
    return noDataView;
}

- (void)setWithImgName:(NSString *)imgName title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)(void))block {

    self.myblock = block;
    self.titleLabel.textColor = [UIColor stec_subTitleTextColor];
    self.titleLabel.font = [UIFont stec_titleFount];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    
    self.titleLabel.attributedText = attributedString;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([buttonTitle isEqualToString:@""]|| buttonTitle == nil) {
        self.actionButton.hidden = YES;
    } else {
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
        [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.actionButton.backgroundColor = [UIColor stec_ableButtonBackColor];
        self.actionButton.clipsToBounds = YES;
        self.actionButton.layer.cornerRadius = 20.5f;
    }
    self.mainImageView.image = [UIImage imageNamed:imgName];
    
}

- (IBAction)actionButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
