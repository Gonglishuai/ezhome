
#import "SHAboutViewController.h"
#import "SHAboutWebViewController.h"
#import "SHCallViewController.h"
#import "SHAboutWebViewController.h"
#import "ESAboutViewController.h"

@interface SHAboutViewController ()<UITableViewDataSource,UITableViewDelegate>

/// tableView.
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SHAboutViewController
{
    NSArray *_arrayDS; //!< _arrayDS the array for data source.
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNavBar];
    [self initUI];
    [self initData];
}

- (void)initUI {
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)initData {
    _arrayDS = @[@"设计家介绍",@"联系方式",@"版权说明",@"版本"];
}

- (void)initNavBar {
    self.titleLabel.text = @"关于设计家";//NSLocalizedString(@"About the designer_key", nil);
    self.rightButton.hidden = YES;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayDS.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }

    if (indexPath.row == 3) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 21)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = ColorFromRGA(0x999999, 1);
        label.text = [SHAppGlobal AppGlobal_GetAppMainVersion];
        cell.accessoryView = label;
    } else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _arrayDS[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NSString *url = [NSString stringWithFormat:@"%@/static/pages/app/about/AboutUs/About.html", [JRNetEnvConfig sharedInstance].netEnvModel.WebHost];
        ESAboutViewController *reVC = [[ESAboutViewController alloc] initWithUrl:url andTitle:@"设计家介绍"];
//         SHAboutWebViewController *reVC = [[SHAboutWebViewController alloc] initWithParm:NSLocalizedString(@"just_tip_about_info", nil) withFile:@"About"];
         [self.navigationController pushViewController:reVC animated:YES];

    } else if (indexPath.row == 1) {
        
        [self.navigationController pushViewController:[[SHCallViewController alloc] init] animated:YES];
    } else if (indexPath.row == 2) {
        NSString *url = [NSString stringWithFormat:@"%@/static/pages/app/about/legal/legal.html", [JRNetEnvConfig sharedInstance].netEnvModel.WebHost];
        ESAboutViewController *reVC = [[ESAboutViewController alloc] initWithUrl:url andTitle:@"版权说明"];
//        SHAboutWebViewController *reVC = [[SHAboutWebViewController alloc] initWithParm:NSLocalizedString(@"just_tip_about_copyright", nil) withFile:@"legal"];
        [self.navigationController pushViewController:reVC animated:YES];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [[UIView alloc]init];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

-(void)viewDidLayoutSubviews
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
