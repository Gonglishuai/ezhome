//
//  ESCaseCommentCell.m
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseCommentCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Size.h"

@interface ESCaseCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commitLabel;
@property(strong, nonatomic) void(^myBlock)(NSString *);
@property(strong, nonatomic) ESCaseCommentModel *datas;
@end

@implementation ESCaseCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _headerImgView.clipsToBounds = YES;
    _headerImgView.layer.cornerRadius = 43/2;
}

- (void)setFavDatas:(ESCaseCommentModel *)datas tapBlock:(void(^)(NSString *))tapBlock {
    _datas = datas;
    _myBlock = tapBlock;
    NSString *imgName = [NSString stringWithFormat:@"%@",_datas.avatar];
    if ([imgName hasPrefix:@"http"]) {
        [_headerImgView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:ICON_EQUAL_DEFAULT]];
    } else {
        [_headerImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
    if (_datas.nickName) {
        _nameLabel.text = _datas.nickName;
    } else {
        _nameLabel.text = _datas.phone;
    }
    
    _timeLabel.text = _datas.createTime;
    _commitLabel.text = _datas.comment;
}
- (IBAction)buttonClicked:(UIButton *)sender {
    if (_myBlock) {
        NSString *designerId = _datas.createId;
        _myBlock(designerId);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)currentCommitViewHeight:(NSString*)String {
    UILabel *_commitLabel = [[UILabel alloc] init];
    _commitLabel.text = [String stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL hasDescription = [NSString notEmpty:_commitLabel.text];
    CGFloat descHeight = 0;
    if (hasDescription && !_commitLabel.hidden) {
        CGSize size = [_commitLabel getActualTextHeightForLabel:35];
        descHeight += (ceil(size.height) + 4/* vert space between title and desc */);
    }
    return descHeight + 80;
}


@end
