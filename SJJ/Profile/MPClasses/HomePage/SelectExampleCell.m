//
//  SelectExampleCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SelectExampleCell.h"
#import "MPCaseModel.h"
#import "UIImageView+WebCache.h"
#import "HomeConsumerExampleModel.h"
@interface SelectExampleCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImgView;
@property (weak, nonatomic) IBOutlet UILabel *typeAreaLabel;
@property (weak, nonatomic) IBOutlet UIImageView *personImgView;
@property (weak, nonatomic) IBOutlet UILabel *personNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (strong, nonatomic) NormalClickBlock myHeaderBlock;
@property (strong, nonatomic) NormalClickBlock myIMBlock;
@property (strong, nonatomic) MPCaseModel *myModel;
@property (strong, nonatomic) HomeConsumerExampleModel *myNewModel;
@end
@implementation SelectExampleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _mainImgView.clipsToBounds = YES;
    _mainImgView.layer.cornerRadius = 2;
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    _personImgView.clipsToBounds = YES;
    _typeAreaLabel.textColor = [UIColor whiteColor];
    _typeAreaLabel.font = [UIFont stec_bigTitleFount];
    _personNameLabel.textColor = [UIColor stec_titleTextColor];
    _personNameLabel.font = [UIFont stec_titleFount];
}

- (void)setNewModel:(HomeConsumerExampleModel *)model headerBlock:(NormalClickBlock)headerBlock IMBlock:(NormalClickBlock)IMblock {
    _myIMBlock = IMblock;
    _myHeaderBlock = headerBlock;
    _personImgView.layer.cornerRadius = _personImgView.frame.size.width/2;
    _myNewModel = model;
    
    [self.personImgView sd_setImageWithURL:[NSURL URLWithString:model.designer_cover] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
    //        self.caseTitleLabel.text  = (model.title == nil)?NSLocalizedString(@"just_tip_no_data", nil):model.title;
    //        self.caseInfoLabel.text  = [NSString stringWithFormat:@"%@ 丨 %@ 丨 %@㎡",
    //                                    (model.project_style == nil)?NSLocalizedString(@"just_tip_no_data", nil):model.project_style,
    //                                    (model.room_type == nil)?NSLocalizedString(@"just_tip_no_data", nil):model.room_type,
    //                                    (model.room_area == nil)?@"0":model.room_area];
    self.typeAreaLabel.text = [NSString stringWithFormat:@"%@  %@  %@",
                               ([model.style isEqualToString:@""])?@"其他":model.style,
                               ([model.house_type isEqualToString:@""])?@"其他":model.house_type,
                               (model.house_area == nil)?@"0":model.house_area];
    NSString *name = model.designer_nick_name ? model.designer_nick_name : @"";
    self.personNameLabel.text = name;
    [self.mainImgView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    
    [self layoutSubviews];
}

- (IBAction)IMButtonClicked:(UIButton *)sender {
    if (_myIMBlock) {
        _myIMBlock();
    }
}
- (IBAction)headerImgClicked:(UIButton *)sender {
    if (_myHeaderBlock) {
        _myHeaderBlock();
    }
}


@end
