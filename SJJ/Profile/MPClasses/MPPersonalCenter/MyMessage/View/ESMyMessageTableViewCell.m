//
//  ESMyMessageTableViewCell.m
//  Consumer
//
//  Created by 张德凯 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyMessageTableViewCell.h"
#import "Masonry.h"
#import "ESMyMessageModel.h"
#import "SHDateUtility.h"
#import "NSMutableAttributedString+Stec.h"

@interface ESMyMessageTableViewCell()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UILabel *dateLabel;

@end

@implementation ESMyMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = 0;
        //标题
        _titleLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.textColor = [UIColor stec_titleTextColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        
        CGFloat contentWidth = SIZEWIDTH(40);
        CGFloat leftgap = SIZEWIDTH(20);
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftgap);
            make.top.mas_equalTo(self.contentView.mas_top).offset(SIZEWIDTH(18));
            make.right.mas_equalTo(-leftgap);
            make.height.mas_equalTo(18);
//            make.width.mas_equalTo(SCREEN_WIDTH - contentWidth);
        }];
        
        //内容
        _contentLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_contentLabel];
        _contentLabel.textColor = [UIColor stec_tabbarNormalTextColor];
        _contentLabel.font = [UIFont systemFontOfSize:12];
        _contentLabel.numberOfLines = 0;
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftgap);
            make.top.equalTo(_titleLabel.mas_bottom).offset(SIZEWIDTH(8));
            make.width.mas_equalTo(SCREEN_WIDTH - contentWidth);
        }];
        
        //时间
        _dateLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_dateLabel];
        _dateLabel.textColor = [UIColor stec_unSelectedTextColor];
        _dateLabel.font = [UIFont systemFontOfSize:11];
        
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(leftgap);
            make.top.equalTo(_contentLabel.mas_bottom).offset(SIZEWIDTH(8));
            make.right.mas_equalTo(-leftgap);
            make.height.mas_equalTo(14);
        }];
        
        UILabel *line = [[UILabel alloc]init];
        [self.contentView addSubview:line];
        line.backgroundColor = [UIColor stec_lineGrayColor];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.equalTo(_dateLabel.mas_bottom).offset(SIZEWIDTH(18));
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

- (void)setMessageModel:(ESMyMessageModel *)model {
    _titleLabel.text = model.theme;

    _contentLabel.attributedText = [NSMutableAttributedString retainAttributeString:model.content linespace:5];
    
    _dateLabel.text = [SHDateUtility formattedDateForMessage:[model.sendTime doubleValue]];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
