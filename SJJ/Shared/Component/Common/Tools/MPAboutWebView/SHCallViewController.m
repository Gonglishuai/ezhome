
#import "SHCallViewController.h"
#import "SHAlertView.h"

@interface SHCallViewController ()

/// call image.
@property (weak, nonatomic) IBOutlet UIImageView *callImage;

///call information.
@property (weak, nonatomic) IBOutlet UILabel *callInfo;

@end

@implementation SHCallViewController

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initBar];
    
    [self.callImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callphone)]];
    [self.callInfo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callphone)]];
    
}

- (void)callphone {
    [SHAlertView showAlertWithTitle:nil
                            message:[NSString stringWithFormat:@"%@%@?",@"拨打",@"4006503333"]
                     cancelKeyTitle:@"取消"
                      rightKeyTitle:@"拨打"
                           rightKey:^{
                               
                               [[UIApplication sharedApplication]
                                openURL:[NSURL URLWithString:
                                         [NSString stringWithFormat:@"tel://%@",@"4006503333"]]];
                               
                           } cancelKey:nil];
}

- (void)initBar {
    self.titleLabel.text = @"联系方式";
    self.rightButton.hidden = YES;
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
