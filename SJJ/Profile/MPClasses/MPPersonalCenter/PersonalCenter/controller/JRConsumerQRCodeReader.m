//
//  JRConsumerQRCodeReader.m
//  Consumer
//
//  Created by jiang on 2017/6/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRConsumerQRCodeReader.h"
#import "JRWebViewController.h"
#import "HtmlURL.h"

@interface JRConsumerQRCodeReader ()
@property (nonatomic, strong)UIButton *createButton;
@end

@implementation JRConsumerQRCodeReader

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCreatrButton];
    // Do any additional setup after loading the view.
}

- (void)initCreatrButton {
    int buttonHeight = 45;
    int buttonWidth = 200;
    _createButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    _createButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-75);
    [_createButton setTintColor:[UIColor whiteColor]];
    _createButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    _createButton.titleLabel.font = [UIFont stec_bigTitleFount];
    _createButton.clipsToBounds = YES;
    _createButton.layer.cornerRadius = buttonHeight/2.0;
    _createButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_createButton setTitle:@"输入业主信息" forState:UIControlStateNormal];
    [_createButton addTarget:self action:@selector(createPackage) forControlEvents:UIControlEventTouchUpInside];
    [self.viewPreview addSubview:_createButton];
    
    //    _labellStatus = [[UILabel alloc] initWithFrame:CGRectMake(_viewPreview.frame.size.width/2 - 150, _boxImageView.frame.origin.y + CGRectGetWidth(_boxImageView.frame) + 5, 300, 50)];
    //    _labellStatus.textColor = [UIColor whiteColor];
    //    _labellStatus.textAlignment = NSTextAlignmentCenter;
    //    _labellStatus.adjustsFontSizeToFitWidth = YES;
    //    _labellStatus.text = NSLocalizedString(@"just_QR_code_message", nil);
    //    [_viewPreview addSubview:_labellStatus];
}
- (void)createPackage {
    JRWebViewController *webViewCon = [[JRWebViewController alloc] init];
    if (self.type == QRReaderTypePackage)
    {
        [webViewCon setTitle:@"" url:kCreatePackage];
    }
    else if (self.type == QRReaderTypeEnterprise)
    {
        [webViewCon setTitle:@"" url:kCreateEnterprise];
    }
    webViewCon.hidesBottomBarWhenPushed = YES;
    [webViewCon setNavigationBarHidden:YES
                         hasBackButton:NO];
    [self.navigationController pushViewController:webViewCon animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
