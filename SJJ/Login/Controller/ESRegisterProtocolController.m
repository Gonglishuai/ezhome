//
//  ESRegisterProtocolController.m
//  Homestyler
//
//  Created by shiyawei on 5/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRegisterProtocolController.h"

#import "Masonry.h"

@interface ESRegisterProtocolController ()
@property (nonatomic,strong)    UIView *topView;
@property (nonatomic,strong)    UITextView *textView;
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UIButton *backBtn;
@end

@implementation ESRegisterProtocolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUIView];
    
    [self readFile];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)createUIView {
    
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.left.mas_offset(0);
        make.right.mas_offset(0);
        make.height.mas_offset(NAVBAR_HEIGHT);
    }];
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.mas_offset(STATUSBAR_HEIGHT + 15);

    }];
    
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.width.mas_offset(40);
        make.height.mas_offset(40);
    }];
    
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
        make.bottom.mas_offset(0);
    }];
}

-(void)readFile{
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"register_areement"ofType:@"text"] encoding:NSUTF8StringEncoding error:&error];
    if (jsonString == nil) {
        return ;
    }
    NSError *err = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData  options:NSJSONReadingMutableContainers error:&err];
    if (dic == nil) {
        return ;
    }
    
    NSString *title = dic[@"title"];
    self.titleLabel.text = title;
    
    NSArray *arr = dic[@"items"];
    NSString *text = [arr componentsJoinedByString:@"\n"];
    
    NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
    //调整行间距
    paragraphStyle.lineSpacing= 5;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    NSDictionary*attriDict =@{NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@(0.5)};
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attriDict];
    self.textView.attributedText = attributedString;
}
- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark --- 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor stec_viewBackgroundColor];
        
    }
    return _topView;
}
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.showsVerticalScrollIndicator = NO;
        _textView.editable = NO;
        _textView.backgroundColor = [UIColor whiteColor];
//        [_textView setContentOffset:CGPointZero animated:NO];
        [_textView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    return _textView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        
    }
    return _titleLabel;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setImage:[UIImage imageNamed:@"patrol_audio_delete"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    return _backBtn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
