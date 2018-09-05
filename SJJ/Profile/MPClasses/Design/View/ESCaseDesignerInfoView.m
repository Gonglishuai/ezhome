//
//  ESCaseDesignerInfoView.m
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCaseDesignerInfoView.h"
#import "UIImageView+WebCache.h"
#import "EZHome-Swift.h"

@interface ESCaseDesignerInfoView()
@property (weak, nonatomic) IBOutlet UIImageView *designerAvatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *specialTag;
@property (weak, nonatomic) IBOutlet UILabel *communityName;
@property (weak, nonatomic) IBOutlet UILabel *roomStyleCode;
@property (weak, nonatomic) IBOutlet UILabel *roomType;
@property (weak, nonatomic) IBOutlet UILabel *roomArea;

@end

@implementation ESCaseDesignerInfoView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _designerAvatar.clipsToBounds = YES;
    _designerAvatar.layer.cornerRadius = 43/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)pushToDesignerPage:(UIButton *)sender {
    if (_myStyleType == CaseStyleType3D) {
        if (![_model.user.design_id isEqualToString:@""] && [self.delegate respondsToSelector:@selector(pushToDesignerPage:)]) {
            [self.delegate pushToDesignerPage:_model.user.design_id];
        }
    } else {
        if (![_model.designerId isEqualToString:@""] && [self.delegate respondsToSelector:@selector(pushToDesignerPage:)]) {
            [self.delegate pushToDesignerPage:_model.designerId];
        }
    }
}

-(void)setModel:(ESCaseDetailModel *)model {
    _model = model;
    NSString *userIcon = @"";
    NSString *roomDescription = @"";
    NSString *tag = @"";
    ESRoomType *type = [[ESRoomType alloc] init];
    if (_myStyleType == CaseStyleType2D) {
        userIcon = model.designerInfo.avatar;
        roomDescription = [NSString stringWithFormat:@"%@室%@厅%@卫",model.bedroom ?: @"",model.roomType ?: @"",model.restroom ?: @""];
        tag = type.roomStyleDict[model.projectStyle];
        self.roomArea.text = [NSString stringWithFormat:@"%@m²",model.roomArea];
    }else {
        self.roomArea.text = [NSString stringWithFormat:@"%@",model.roomArea];
        roomDescription = [NSString stringWithFormat:@"%@%@%@", [self exchangeToNumber:model.bedRoomNum],[self exchangeToNumber:model.livingRoomNum],[self exchangeToNumber:model.bathRoomNum]];
        tag = model.roomStyleCode;
    }
    
    [_designerAvatar sd_setImageWithURL:[NSURL URLWithString: _myStyleType == CaseStyleType2D ? userIcon : model.user.avatarUrl] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
    //self.name.text = model.user.name;
    //self.specialTag.text = model.specialTag;
    self.communityName.text = model.communityName;
    self.roomStyleCode.text = tag;
    self.roomType.text = roomDescription;
    
}

- (void)setDesginModel:(ESCaseDetailModel *)desginModel {
    self.name.text = [NSString stringWithFormat:@"%@ | %@年经验",desginModel.designerInfo.nickName ?: @"" ,desginModel.designerInfo.experience ?: @"1"];
    self.specialTag.text = [NSString stringWithFormat:@"擅长风格:%@",desginModel.designerInfo.styleNames ?: @""];
}

- (NSString *)exchangeToNumber:(NSString *)str {
    if (str == nil || str.length == 0 || [str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    NSString *subS = [str substringToIndex:1];
    NSString *numberS = @"";
    if ([subS isEqualToString:@"一"]) {
        numberS = @"1";
    }else if ([subS isEqualToString:@"两"]) {
        numberS = @"2";
    }else if ([subS isEqualToString:@"三"]) {
        numberS = @"3";
    }else if ([subS isEqualToString:@"四"]) {
        numberS = @"4";
    }else if ([subS isEqualToString:@"五"]) {
        numberS = @"5";
    }else if ([subS isEqualToString:@"六"]) {
        numberS = @"6";
    }else if ([subS isEqualToString:@"七"]) {
        numberS = @"7";
    }else if ([subS isEqualToString:@"八"]) {
        numberS = @"8";
    }else if ([subS isEqualToString:@"九"]) {
        numberS = @"9";
    }else {
//        return numberS;
    }
    NSString *resultS = [str stringByReplacingOccurrencesOfString:subS withString:numberS];
    return resultS;
}

@end
