
#import "ESSaleAgreementViewController.h"
#import <WebKit/WebKit.h>
#import "HtmlURL.h"

@interface ESSaleAgreementViewController ()

@end

@implementation ESSaleAgreementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
}

- (void)initData
{
    
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"居然设计家线上买卖协议";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat bottomButtonHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT;
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(
                                                                     0,
                                                                     NAVBAR_HEIGHT,
                                                                     SCREEN_WIDTH,
                                                                     SCREEN_HEIGHT - NAVBAR_HEIGHT - bottomButtonHeight
                                                                     )
                                            configuration:configuration];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kSaleAgreeSment]]];
    [self.view addSubview:webView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, SCREEN_HEIGHT - bottomButtonHeight, SCREEN_WIDTH, bottomButtonHeight);
    button.titleLabel.font = [UIFont stec_buttonFount];
    button.backgroundColor = [UIColor stec_lineBlueColor];
    [button setTitle:@"同意" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bottomButtonDidTapped)
     forControlEvents:UIControlEventTouchUpInside];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    [self.view addSubview:button];
    
    if (self.hasApproved)
    {
        [button setTitle:@"已同意" forState:UIControlStateNormal];
    }
}

#pragma mark - Button Methods
- (void)bottomButtonDidTapped
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(saleAgreementAgreeButtonDidTapped)])
    {
        [self.delegate saleAgreementAgreeButtonDidTapped];
    }
    
    [self tapOnLeftButton:nil];
}

#pragma mark - Super Methods
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
