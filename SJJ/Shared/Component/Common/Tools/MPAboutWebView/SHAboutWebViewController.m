
#import "SHAboutWebViewController.h"
#import "MBProgressHUD.h"

@interface SHAboutWebViewController ()<UIWebViewDelegate>

/// webView for show html info.
@property (weak, nonatomic) IBOutlet UIWebView *aboutWebView;

/// the label for show version.
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

/// the string for navigation title.
@property (nonatomic, strong) NSString* titleString;

/// the string for html code name.
@property (nonatomic, strong) NSString* fileName;

@end

@implementation SHAboutWebViewController

@synthesize title;
@synthesize fileName;


- (instancetype)initWithParm:(NSString *)titleStr
                    withFile:(NSString *)fileNameStr
{
    self = [self init];
    if (self)
    {
        self.titleString=titleStr;
        self.fileName = fileNameStr;
        
    }
    return self;
}


- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
    
    [self initBar];
    
    [self initData];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    UIScrollView *scrollView = self.aboutWebView.scrollView;
    scrollView.bounces = NO;
    scrollView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0);
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.aboutWebView.frame), 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
}

- (void)initBar {
    
    self.titleLabel.text = self.titleString;
    
    self.rightButton.hidden = YES;
}

- (void)initData {
    self.versionLabel.text = [SHAppGlobal AppGlobal_GetAppMainVersion];
    
    [self viewLoadHtml];
}

- (void)viewLoadHtml {
    
    NSString *strHtml = [self LoadContractString];
    _aboutWebView.delegate = self;
    [_aboutWebView loadHTMLString:strHtml baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] resourcePath] isDirectory: YES]];
}
- (NSString*)LoadContractString{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.fileName  ofType:@"txt"];
    NSString *strHtml = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return strHtml;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSURL * url = [request URL];
    if ([url.absoluteString isEqualToString:@"http://www.apache.org/licenses/LICENSE-2.0"] ||
        [url.absoluteString isEqualToString:@"http://www.autodesk.com/company/legal-notices-trademarks/software-license-agreements"])
    {
        [MBProgressHUD showHUDAddedTo:webView animated:YES];
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUDForView:webView animated:YES];
}


@end
