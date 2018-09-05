//
//  ESRecDetailDescreptionViewController.m
//  demo
//
//  Created by shiyawei on 13/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecDetailDescreptionViewController.h"

@interface ESRecDetailDescreptionViewController ()
@property (nonatomic,strong)    UITextView *textView;
@property (nonatomic,strong)    UIButton *cancelBtn;
@property (nonatomic,strong)    UILabel *titleLabel;
@end

@implementation ESRecDetailDescreptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ColorFromRGA(0xFCFCFC,1.0);//#FCFCFC 100%
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.textView];
}


#pragma mark --- Private Method
- (void)dismissAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 懒加载
- (UITextView *)textView {
    if (!_textView) {
        NSString *text = @"1、请正确核实并填写客户手机号码，对于尚未注册设计家的客户系统将为客户自动注册账号。\n2、在您推荐给该业主后，系统将仅通过站内信形式通知业主；同时业主登陆APP-个人中心后，可查看您的推荐记录。\n3、为便于业主快速查看清单，建议推荐成功后，通过发送至微信好友等形式分享给业主清单。\n4、通过手机定向推荐给客户后，客户购买该方案/清单中包含与您合作品牌的商品后，将算作您的推荐订单。";
        _textView = [[UITextView alloc] init];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.backgroundColor = self.view.backgroundColor;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        
        paragraphStyle.lineSpacing = 20;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:14],
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     NSForegroundColorAttributeName:ColorFromRGA(0x7A7B87,1.0)
                                     };
        NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        _textView.attributedText = attributeText;
        
        _textView.frame = CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 13, self.view.frame.size.width - 40, self.view.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 13);
    }
    return _textView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"推荐说明";
        _titleLabel.textColor = ColorFromRGA(0x2D2D34,1.0);//#2D2D34 100%
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.frame = CGRectMake(0, STATUSBAR_HEIGHT + 33, self.view.frame.size.width, 22);
    }
    return _titleLabel;
}
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:@"alert_close"];
        [_cancelBtn setImage:image forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(20, STATUSBAR_HEIGHT + 15, 35, 35 * image.size.height / image.size.width);
    }
    return _cancelBtn;
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
