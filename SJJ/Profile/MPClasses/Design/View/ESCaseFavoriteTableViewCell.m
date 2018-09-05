//
//  ESCaseFavoriteTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseFavoriteTableViewCell.h"
#import <Masonry.h>

@interface ESCaseFavoriteTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (strong, nonatomic) void(^tapBlock)(void);

@end

@implementation ESCaseFavoriteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _backView.clipsToBounds = YES;
    _backView.layer.cornerRadius = 25;
    _numLabel.textColor = [UIColor whiteColor];
    _numLabel.font = [UIFont stec_titleFount];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFavNum:(NSString *)num isFav:(BOOL)isFav tapBlock:(void(^)(void))tapBlock {
    _numLabel.text = num?num:@"0";
    _tapBlock = tapBlock;
    if (isFav) {
        _backView.backgroundColor = [UIColor stec_unabelButtonBackColor];
    } else {
        _backView.backgroundColor = [UIColor stec_ableButtonBackColor];
    }
}
- (IBAction)favoriteButtonClicked:(UIButton *)sender {
    if (_tapBlock) {
        _tapBlock();
    }
}

@end
