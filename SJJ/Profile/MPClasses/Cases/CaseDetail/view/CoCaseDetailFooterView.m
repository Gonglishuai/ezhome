//
//  CoCaseDetailFooterView.m
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseDetailFooterView.h"
#import "WXApi.h"
#import "SHAlertView.h"

@implementation CoCaseDetailFooterView
{
    __weak IBOutlet UIButton *_caseShareBtn;
    __weak IBOutlet UIButton *_caseZanBtn;
    
    BOOL _zan;
    
}
- (void)receiveLoginNotification:(NSNotification *)notification {
    [self updateCaseDetailFooterView];
}

- (void)updateCaseDetailFooterView {

    if ([self.delegate respondsToSelector:@selector(getCaseZan)]) {
        
        _zan = [self.delegate getCaseZan];
        _caseZanBtn.selected = _zan;
    }
    
    if ([self.delegate respondsToSelector:@selector(getCaseZanNumber)]) {
        NSInteger zanNum = [self.delegate getCaseZanNumber];
        [_caseZanBtn setTitle:[NSString stringWithFormat:@"点赞 %ld",(long)zanNum] forState:UIControlStateNormal];
    }
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(caseShare)]) {
        [self.delegate caseShare];
//        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
//
//        }else{
//            [SHAlertView showAlertWithTitle:@"提示" message:@"您没有安装微信" sureKey:^{
//
//            }];
//        }
        
    }
}

- (IBAction)zanBtnClick:(UIButton *)sender {
    //    sender.selected = !sender.selected;
    if (_zan == YES) {
        _caseZanBtn.userInteractionEnabled = NO;
    }else{
        _zan = YES;
        _caseZanBtn.userInteractionEnabled = YES;
        if ([self.delegate respondsToSelector:@selector(caseZanWithSuccess:andFailure:)]) {
            [self.delegate caseZanWithSuccess:^(BOOL selected) {
                sender.selected = selected;
            } andFailure:^{
                _zan = NO;
            }];
        }
    }
    
}

- (void)clickZan:(UIButton *)sender {
    
}

@end
