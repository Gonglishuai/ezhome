//
//  MPCaseScreenTableViewCell.m
//  MarketPlace
//
//  Created by xuezy on 16/2/23.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "MPCaseScreenTableViewCell.h"
#define Start_X 7.0f           // 第一个按钮的X坐标
#define Start_Y 10.0f           // 第一个按钮的Y坐标
#define Height_Space 20.0f      // 竖间距
#define Button_Height 30.0f    // 高
@interface MPCaseScreenTableViewCell ()
{
    UIButton *selectedButton;
}

@property (nonatomic,copy)NSString *typeTitle;
@end

@implementation MPCaseScreenTableViewCell

-(void) updateCellForIndex:(NSArray *) array withTitle:(NSString *)title andSelectIndes:(NSInteger)selectIndex {
    
    self.typeTitle = title;
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
        
    for (NSInteger i = 0; i<array.count; i++) {
        NSInteger index = i%4;
        NSInteger page = i/4;
        
        // 圆角按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat margin = 18*SCREEN_SCALE;
        CGFloat btn_width = (SCREEN_WIDTH -margin*4)/4;
        button.frame = CGRectMake(index * (btn_width + margin) + Start_X, page  * (Button_Height + Height_Space)+Start_Y,btn_width+2, Button_Height);

        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [button setTitleColor:[UIColor stec_titleTextColor] forState:UIControlStateNormal];

        [button setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateSelected];
        button.tag = 100*i;
        if (i == selectIndex) {
            button.selected = YES;
            button.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
            selectedButton = button;

        }else{
            
            button.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
            

        }
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        button.layer.borderWidth = 1;
        [self.contentView addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    
    
  if (selectedButton == button){
        selectedButton.selected = YES;
        selectedButton.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
        [selectedButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    }
    else {
        selectedButton.selected = NO;
        selectedButton.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
        [selectedButton setTitleColor:[UIColor stec_titleTextColor] forState:UIControlStateNormal];
        
        selectedButton = button;
        selectedButton.selected = YES;
        selectedButton.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
        [selectedButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    }
    
   
    if ([self.delegate respondsToSelector:@selector(cellWithSelectedIndex:andCellSection:)]) {
        [self.delegate cellWithSelectedIndex:button.tag/100 andCellSection:self.cellSection];
        
        if ([self.delegate respondsToSelector:@selector(selectType:type:)]) {
            [self.delegate selectType:selectedButton.titleLabel.text type:self.typeTitle];
        }
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
