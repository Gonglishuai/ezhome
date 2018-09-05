
#import "CoLinkPageViewController.h"
#import "CoLinkPageView.h"

@interface CoLinkPageViewController ()<CoLinkPageViewDelegate>

@end

@implementation CoLinkPageViewController
{
    NSArray *_arrayDS;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
}

- (void)initData
{
    _arrayDS = @[@"Guide-page_1",@"Guide-page_2",@"Guide-page_3"];
}

- (void)initUI
{
    [self.navgationImageview removeFromSuperview];
    
    CoLinkPageView *linkPageView = [CoLinkPageView linkPageView];
    linkPageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    linkPageView.viewDelegate = self;
    [linkPageView updateLinkPageViewWithImages:_arrayDS];
    [self.view addSubview:linkPageView];
}

- (void)enterButtonDidTapped:(UIView *)view
{
    if (self.clickEnter) {
        self.clickEnter();
    }
}

@end
