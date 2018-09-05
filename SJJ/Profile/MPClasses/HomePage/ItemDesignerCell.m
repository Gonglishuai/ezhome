//
//  ItemDesignerCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ItemDesignerCell.h"

@interface ItemDesignerCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView3;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgView4;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel3;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel4;

@property (strong, nonatomic)ItemClickBlock myblock;
@end
@implementation ItemDesignerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.backgroundColor = [UIColor stec_lineGrayColor];
    _titleLabel1.textColor = [UIColor stec_titleTextColor];
    _titleLabel1.font = [UIFont stec_bigTitleFount];
    _titleLabel2.textColor = [UIColor stec_titleTextColor];
    _titleLabel2.font = [UIFont stec_bigTitleFount];
    _titleLabel3.textColor = [UIColor stec_titleTextColor];
    _titleLabel3.font = [UIFont stec_bigTitleFount];
    _titleLabel4.textColor = [UIColor stec_titleTextColor];
    _titleLabel4.font = [UIFont stec_bigTitleFount];
    _headerImgView1.image = [[UIImage imageNamed:@"home_designer_Item1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView2.image = [[UIImage imageNamed:@"home_designer_Item2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView3.image = [[UIImage imageNamed:@"home_designer_Item_buy"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _headerImgView4.image = [[UIImage imageNamed:@"home_designer_Item4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
