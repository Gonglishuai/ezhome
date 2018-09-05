//
//  ESHotTalkCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2017/8/7.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESHotTalkCollectionViewCell.h"

@interface ESHotTalkCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESHotTalkCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    // Initialization code
}

- (void)setTitle:(NSString *)title imageName:(NSString *)imgName {
    _titleLabel.text = title;
    _backImageView.image = [UIImage imageNamed:imgName];
}
@end
