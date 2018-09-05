//
//  ItemCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ItemCollectionViewCell.h"

@interface ItemCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView3;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView4;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel4;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel4;
@property (strong, nonatomic)ItemClickBlock myblock;
@end

@implementation ItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor stec_lineGrayColor];
    _titleLabel1.textColor = [UIColor stec_titleTextColor];
    _titleLabel1.font = [UIFont stec_titleFount];
    _titleLabel2.textColor = [UIColor stec_titleTextColor];
    _titleLabel2.font = [UIFont stec_titleFount];
    _titleLabel3.textColor = [UIColor stec_titleTextColor];
    _titleLabel3.font = [UIFont stec_titleFount];
    _titleLabel4.textColor = [UIColor stec_titleTextColor];
    _titleLabel4.font = [UIFont stec_titleFount];
    _subTitleLabel1.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel1.font = [UIFont stec_remarkTextFount];
    _subTitleLabel2.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel2.font = [UIFont stec_remarkTextFount];
    _subTitleLabel3.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel3.font = [UIFont stec_remarkTextFount];
    _subTitleLabel4.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel4.font = [UIFont stec_remarkTextFount];
    
    _headerImgView1.image = [[UIImage imageNamed:@"home_consumer_Item1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView2.image = [[UIImage imageNamed:@"home_consumer_Item2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView3.image = [[UIImage imageNamed:@"home_designer_Item_buy"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView4.image = [[UIImage imageNamed:@"home_consumer_Item4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // Initialization code
}

- (void)setDataSource:(NSDictionary *)datas calculateBlock:(ItemClickBlock)block {
    _myblock = block;
}
- (IBAction)selectClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock(sender.tag);
    }
}

@end
