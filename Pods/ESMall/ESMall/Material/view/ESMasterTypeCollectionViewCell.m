//
//  ESMasterTypeCollectionViewCell.m
//  Mall
//
//  Created by jiang on 2017/9/11.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMasterTypeCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface ESMasterTypeCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESMasterTypeCollectionViewCell

- (void) setInfo:(NSDictionary *)info {

    _iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", info[@"imgName"]?info[@"imgName"]:@""]];
    _titleLabel.text = info[@"title"] ? info[@"title"] : @"";
    
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];

    
}

@end
