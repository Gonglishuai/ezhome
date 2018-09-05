//
//  CoDesignerDetailHeadView.m
//  Consumer
//
//  Created by xuezy on 16/7/25.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoDesignerDetailHeadView.h"

@interface CoDesignerDetailHeadView ()
{
    
    __weak IBOutlet UIView *_bottom3DLineView;
    __weak IBOutlet UILabel *_commen3DCaseLabel;
    
    __weak IBOutlet UILabel *_commenCaseLabel;//2D
    
    __weak IBOutlet UILabel *_remarksLabel;
    
    __weak IBOutlet UIView *_bottomLineView; // 2D
    __weak IBOutlet UIView *_bottomLineCommentView;
    NSInteger _curIndex;
}
@end

@implementation CoDesignerDetailHeadView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    _curIndex = 0;
    
    UITapGestureRecognizer *tgr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCommenItem:)];//2D
    [_commenCaseLabel addGestureRecognizer:tgr1];
    
    UITapGestureRecognizer *tgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemarks:)];
    [_remarksLabel addGestureRecognizer:tgr2];
    
    UITapGestureRecognizer  *tgr3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap3DCommenItem:)];
    [_commen3DCaseLabel addGestureRecognizer:tgr3];
    
    _bottomLineView.backgroundColor = [UIColor stec_ableButtonBackColor];
    _bottom3DLineView.backgroundColor = [UIColor stec_ableButtonBackColor];
    _bottomLineCommentView.backgroundColor = [UIColor stec_ableButtonBackColor];
    _remarksLabel.textColor = [UIColor stec_titleTextColor];
    _commenCaseLabel.textColor = [UIColor stec_blueTextColor];
    _commen3DCaseLabel.textColor = [UIColor stec_titleTextColor];
    
    _bottomLineCommentView.hidden = YES;
    _bottom3DLineView.hidden = YES;
    
}
//2D
- (void)tapCommenItem:(UITapGestureRecognizer *)sender {
    if (_curIndex != 0) {
        SHLog(@"%f",_commenCaseLabel.center.x);
        [UIView animateWithDuration:0.25f animations:^{
            _bottomLineView.center = CGPointMake(_commenCaseLabel.center.x, 39);
            _bottomLineCommentView.center = CGPointMake(_commenCaseLabel.center.x, 39);
            _bottom3DLineView.center = CGPointMake(_commenCaseLabel.center.x, 39);

        } completion:^(BOOL finished) {
            _remarksLabel.textColor = [UIColor stec_titleTextColor];
            _commenCaseLabel.textColor = [UIColor stec_blueTextColor];
            _commen3DCaseLabel.textColor = [UIColor stec_titleTextColor];
            
            _bottomLineView.hidden = NO;
            _bottomLineCommentView.hidden = YES;
            _bottom3DLineView.hidden = YES;
            _curIndex = 0;
            if ([self.delegate respondsToSelector:@selector(selectSegBtnClickWithTitleIndex:)]) {
                [self.delegate selectSegBtnClickWithTitleIndex:_curIndex];
            }
        }];
    }
   
}
// 3D 案例集
- (void)tap3DCommenItem:(UITapGestureRecognizer *)sender {
    if (_curIndex != 2) {
        SHLog(@"%f",_commenCaseLabel.center.x);
        [UIView animateWithDuration:0.25f animations:^{
            _bottomLineView.center = CGPointMake(_commen3DCaseLabel.center.x, 39);
            _bottom3DLineView.center = CGPointMake(_commen3DCaseLabel.center.x, 39);
            _bottomLineCommentView.center = CGPointMake(_commen3DCaseLabel.center.x, 39);
            
        } completion:^(BOOL finished) {
            _remarksLabel.textColor = [UIColor stec_titleTextColor];
            _commenCaseLabel.textColor = [UIColor stec_titleTextColor];
            _commen3DCaseLabel.textColor = [UIColor stec_blueTextColor];
            
            _bottom3DLineView.hidden = NO;
            _bottomLineView.hidden = YES;
            _bottomLineCommentView.hidden = YES;
            _curIndex = 2;
            if ([self.delegate respondsToSelector:@selector(selectSegBtnClickWithTitleIndex:)]) {
                [self.delegate selectSegBtnClickWithTitleIndex:_curIndex];
            }
        }];
    }
    
}


- (void)tapRemarks:(UITapGestureRecognizer *)sender {
    if (_curIndex != 1) {
        [UIView animateWithDuration:0.25f animations:^{
            _bottomLineView.center = CGPointMake(_remarksLabel.center.x, 39);
            _bottomLineCommentView.center = CGPointMake(_remarksLabel.center.x, 39);
            _bottom3DLineView.center =  CGPointMake(_remarksLabel.center.x, 39);

        } completion:^(BOOL finished) {
            _remarksLabel.textColor = [UIColor stec_blueTextColor];
            _commenCaseLabel.textColor = [UIColor stec_titleTextColor];
            _commen3DCaseLabel.textColor = [UIColor stec_titleTextColor];
            
            _bottomLineView.hidden = YES;
            _bottom3DLineView.hidden = YES;
            _bottomLineCommentView.hidden = NO;
            _curIndex = 1;
            if ([self.delegate respondsToSelector:@selector(selectSegBtnClickWithTitleIndex:)]) {
                [self.delegate selectSegBtnClickWithTitleIndex:_curIndex];
            }
        }];
        
    }
    
}

- (void)updateDesignerDetailHeadView {
    
    if ([self.delegate respondsToSelector:@selector(getDesignerCommentsCount)]) {
        NSInteger count = [self.delegate getDesignerCommentsCount];
        NSString *commentCountStr = [NSString stringWithFormat:@"评价(%ld)",(long)count];
        _remarksLabel.text = commentCountStr;

    }
}

- (void)segBtnClickWithTitleIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(selectSegBtnClickWithTitleIndex:)]) {
        
        [self.delegate selectSegBtnClickWithTitleIndex:index];
    }
}


@end
