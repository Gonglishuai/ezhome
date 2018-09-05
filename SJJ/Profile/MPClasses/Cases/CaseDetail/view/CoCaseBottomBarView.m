//
//  CoCaseBottomBarView.m
//  Consumer
//
//  Created by Jiao on 16/7/19.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseBottomBarView.h"
#import "ES2DCaseDetail.h"
#import "UIImageView+WebCache.h"
#import "JRKeychain.h"
@implementation CoCaseBottomBarView
{
    UIImageView *_headIcon;
    UIImageView *_cerIcon;
    UILabel *_nameLabel;
    UIButton *_focus;
    UILabel *_subInfoLabel;
    UIButton *_chatButton;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createViewsWithFrame:frame];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)createViewsWithFrame:(CGRect)frame {
    //头像
    _headIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18, -16, 52, 52)];
    _headIcon.layer.masksToBounds = YES;
    _headIcon.layer.cornerRadius = _headIcon.frame.size.width / 2;
    _headIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadIcon:)];
    [_headIcon addGestureRecognizer:tgr];
    [self addSubview:_headIcon];
    
    //头像边框
    UIImageView *headOutline = [[UIImageView alloc] initWithFrame:CGRectMake(16, -18, 56, 56)];
    [headOutline setImage:[UIImage imageNamed:@"home_icon_white_line"]];
    [self addSubview:headOutline];
    
    //认证图标
    _cerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(60, 20, 16, 20)];
    [_cerIcon setImage:[UIImage imageNamed:@"Verified_V"]];
    [self addSubview:_cerIcon];
    
    //名字
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 8, 60, 21)];
    [_nameLabel setTextColor:[UIColor blackColor]];
    [_nameLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self addSubview:_nameLabel];
    
    //关注
    _focus = [UIButton buttonWithType:UIButtonTypeCustom];
    _focus.frame = CGRectMake(160, 8, 50, 18);
    [_focus setTitle:@"+  关注" forState:UIControlStateNormal];
    [_focus setTitle:@"取消关注" forState:UIControlStateSelected];
    _focus.hidden = YES;
    [_focus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_focus setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateSelected];
    _focus.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    _focus.layer.cornerRadius = 2.0f;
    _focus.layer.borderColor = [[UIColor stec_blueTextColor] CGColor];
    _focus.layer.borderWidth = 1.0f;
    [_focus addTarget:self action:@selector(focusButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_focus];
    
   
    
    //聊天按钮
    _chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat X = frame.size.width - 16 - 35;
    CGFloat Y = (frame.size.height - 47) / 2;
    _chatButton.frame = CGRectMake(X, Y, 47, 47);
    [_chatButton setImage:[UIImage imageNamed:@"home_chat"] forState:UIControlStateNormal];
    [_chatButton addTarget:self action:@selector(chatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    _chatButton.hidden = [SHAppGlobal AppGlobal_GetIsDesignerMode];
    [self addSubview:_chatButton];
    
    
    //子信息
    _subInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 30, _chatButton.frame.origin.x - 92 - 8 , 21)];
    [_subInfoLabel setTextColor:COLOR(102, 102, 102, 1)];
    [_subInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    _subInfoLabel.adjustsFontSizeToFitWidth = YES;
    _subInfoLabel.minimumScaleFactor = 0.67f;
    [self addSubview:_subInfoLabel];
}

- (void)getData {
    if ([self.delegate respondsToSelector:@selector(getDesignerInfo)]) {
        ES2DCaseDetail *caseDetail = [self.delegate getDesignerInfo];
        
        [_headIcon sd_setImageWithURL:[NSURL URLWithString:caseDetail.designerInfo.avatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];

        _nameLabel.text = caseDetail.designerInfo.userName ?: NSLocalizedString(@"暂无数据", nil);
        
        [self calculateLength];
        // 拼接字段 风格 户型(室厅卫) 面积 造价
        NSString *style = caseDetail.projectStyle ?: @"其他";
        NSString *type = caseDetail.roomType ?: @"其他";
        NSString *area = caseDetail.roomArea ?: @"0";
        NSString * _subInfoStr = [NSString stringWithFormat:@"%@ %@ %@", style, type, area];
        
        if (caseDetail.prjPrice && caseDetail.prjPrice >= 0) {
            _subInfoStr = [_subInfoStr stringByAppendingFormat:@"  %@万元",caseDetail.prjPrice];
        }else {
            _subInfoStr = [_subInfoStr stringByAppendingString:@"  未填写"];
        }
        
        _subInfoLabel.text = _subInfoStr;
        _cerIcon.hidden = !caseDetail.designerInfo.isAuth;
        
        if ([self.delegate respondsToSelector:@selector(getLoginStatus)]) {
            BOOL loginStatus = [self.delegate getLoginStatus];
            if (loginStatus) {
                
                if ([caseDetail.designerInfo.designerId isEqualToString:[JRKeychain loadSingleUserInfo:UserInfoCodeJId]]) {
                    
                    _focus.hidden = YES;
                }else {
                    _focus.hidden = NO;
                    if (!caseDetail.designerInfo.isFollow) {
                        _focus.selected = NO;
                        _focus.titleLabel.font = [UIFont systemFontOfSize:12.0f];
                        _focus.backgroundColor = [UIColor stec_ableButtonBackColor];
                    }else {
                        _focus.selected = YES;
                        _focus.titleLabel.font = [UIFont systemFontOfSize:11.0f];
                        _focus.backgroundColor = [UIColor whiteColor];
                    }
                }
                
            }else {
                _focus.hidden = NO;
                _focus.selected = NO;
                _focus.backgroundColor = [UIColor stec_blueTextColor];
            }

        }
//        if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
//            _chatButton.hidden = YES;
//        }else {
//            _chatButton.hidden = NO;
//        }
    }
    
}

- (void)tapHeadIcon:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tapHeadIcon)]) {
        [self.delegate tapHeadIcon];
    }
}

- (void)chatBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(chatBtnClick)]) {
        [self.delegate chatBtnClick];
    }
}

- (void)focusButtonClick:(UIButton *)sender {
    BOOL selectedStatus = sender.selected;
    __block UIButton *button = sender;
    if ([self.delegate respondsToSelector:@selector(focusBtnClickWithFocus:withSuccess:)]) {
        [self.delegate focusBtnClickWithFocus:!sender.selected withSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                button.selected = !selectedStatus;
                button.backgroundColor = !selectedStatus ? [UIColor whiteColor] : [UIColor stec_ableButtonBackColor];
                button.titleLabel.font = !selectedStatus ? [UIFont systemFontOfSize:11.0f] : [UIFont systemFontOfSize:12.0f];
            });
        }];
    }
}

- (void)calculateLength {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [_nameLabel.text boundingRectWithSize:CGSizeMake(120, _nameLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading |NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    
    labelSize.height = ceil(labelSize.height);
    
    labelSize.width = ceil(labelSize.width);
    
    if (labelSize.width > _nameLabel.frame.size.width) {
        CGFloat changed = labelSize.width - _nameLabel.frame.size.width;
        if (changed > 100) {
            changed = 100;
        }
        _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, _nameLabel.frame.size.width + changed, _nameLabel.frame.size.height);
        _focus.frame = CGRectMake(_focus.frame.origin.x + changed, _focus.frame.origin.y, _focus.frame.size.width, _focus.frame.size.height);
    }
    
}
@end
