//
//  HeaderCollectionReusableView.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "HeaderCollectionReusableView.h"
#import <ESFoundation/UIColor+Stec.h>
#import <ESFoundation/UIFont+Stec.h>

@interface HeaderCollectionReusableView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;


@end

@implementation HeaderCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_bigTitleFount];
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _subTitleLabel.font = [UIFont stec_headerFount];
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    _titleLabel.text = title;
    
    NSDictionary *dic = @{NSKernAttributeName:@1.5f};
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:subTitle attributes:dic];
    _subTitleLabel.attributedText = attributeStr;
    
}

@end
