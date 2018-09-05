//
//  ESOrderDetailPersonTableViewCell.m
//  ESMall
//
//  Created by jiang on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESOrderDetailPersonTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESOrderDetailPersonTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

@property (strong, nonatomic) void(^myPhoneBlock)(NSString *phoneNum);

@property (copy, nonatomic) NSString *phoneNum;

@end

@implementation ESOrderDetailPersonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _nameLabel.font = [UIFont stec_titleFount];
    _nameLabel.textColor = [UIColor stec_subTitleTextColor];
    [_phoneButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    _phoneButton.titleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setAvatar:(NSString *)avatar name:(NSString *)name phone:(NSString *)phone phoneBlock:(void(^)(NSString *phoneNum))phoneBlock {
    _myPhoneBlock = phoneBlock;
    _phoneNum = phone;
    if ([avatar hasPrefix:@"http"]) {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"headerDeafult"]];
    } else {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, avatar]] placeholderImage:[UIImage imageNamed:@"headerDeafult"]];
    }
    _nameLabel.text = [NSString stringWithFormat:@"%@", name];
    [_phoneButton setTitle:[NSString stringWithFormat:@"%@", phone] forState:UIControlStateNormal];
}

- (IBAction)phoneButtonClicked:(UIButton *)sender {
    if (_myPhoneBlock && _phoneNum.length>0) {
        _myPhoneBlock(_phoneNum);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
