
#import "ESProductDeatilStoreMapViewController.h"
#import "ESProductStoreModel.h"
#import "ESProductDetailStoreMapView.h"
#import "MBProgressHUD.h"

@interface ESProductDeatilStoreMapViewController ()<ESProductDetailStoreMapViewDelegate>

@end

@implementation ESProductDeatilStoreMapViewController
{
    NSArray *_arrayDS;
    ESProductDetailStoreMapView *_mapView;
}

- (instancetype)initWithStores:(NSArray *)stores
{
    self = [super init];
    if (self)
    {
        if (stores
            && [stores isKindOfClass:[NSArray class]]
            && [[stores firstObject] isKindOfClass:[ESProductStoreModel class]])
        {
            _arrayDS = [ESProductStoreModel updateDataSource:stores withSelectedIndex:-1];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self updateData];
}

- (void)initData
{
    
}

- (void)initUI
{
    self.navgationImageview.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.mainContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.navigationBarBottomLine.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rightButton.hidden = YES;
    
    _mapView = [[ESProductDetailStoreMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _mapView.viewDelegate = self;
    [self.view insertSubview:_mapView
                belowSubview:self.navgationImageview];
}

- (void)updateData
{
    
}

#pragma mark - ESProductDetailStoreMapViewDelegate
- (NSArray <ESProductStoreModel *> *)getStoreInformations
{
    return _arrayDS;
}

- (NSInteger)getStoreCount
{
    return _arrayDS.count;
}

- (void)storeDidTappedWithName:(NSString *)storeName
                      latitude:(CGFloat)latitude
                     longitude:(CGFloat)longitude
{
    [self navigationWithName:storeName
                    latitude:latitude
                   longitude:longitude];
}

- (void)storeDidSelectedWithName:(NSString *)storeName
{
    _arrayDS = [ESProductStoreModel updateDataSource:_arrayDS withTitle:storeName];
    
    [_mapView refreshStoresTable];
}

- (void)storeItemDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return;
    }
    
    _arrayDS = [ESProductStoreModel updateDataSource:_arrayDS withSelectedIndex:indexPath.row];
    
    [_mapView refreshView];
}

#pragma mark - ESProductDetailStoreItemCellDelegate
- (ESProductStoreModel *)getProductStoreInformationAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _arrayDS.count)
    {
        return _arrayDS[indexPath.row];
    }
    
    return nil;
}

- (void)productStoreNavigationButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _arrayDS.count)
    {
        ESProductStoreModel *model = _arrayDS[indexPath.row];
        if (!model
            || ![model isKindOfClass:[ESProductStoreModel class]])
        {
            return;
        }
        
        [self navigationWithName:model.storeName
                        latitude:[model.latitude doubleValue]
                       longitude:[model.longitude doubleValue]];
    }
}

- (void)productStoreCallButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    SHLog(@"联系商家");
    if (indexPath.row < _arrayDS.count)
    {
        ESProductStoreModel *model = _arrayDS[indexPath.row];
        if (!model
            || ![model isKindOfClass:[ESProductStoreModel class]])
        {
            return;
        }
        
        NSString *phone = model.mobile;
        if (!phone
            || ![phone isKindOfClass:[NSString class]]
            || phone.length <= 0)
        {
            return;
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        else
        {
            SHLog(@"此设备不支持打电话");
        }
    }
}

#pragma mark - Methods
- (void)navigationWithName:(NSString *)storeName
                  latitude:(CGFloat)latitude
                 longitude:(CGFloat)longitude
{
    SHLog(@"去规划路线: %@", storeName);
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        NSString *url = [NSString stringWithFormat:
                         @"iosamap://path?sourceApplication=%@&sid=BGVIS1&sname=我的位置&did=BGVIS2&dlat=%lf&dlon=%lf&dname=%@&dev=0&m=0",
                         [[ESMallAssets hostBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey],
                         latitude,
                         longitude,
                         storeName];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        [self showHudWithMessage:@"您尚未安装高德地图" hideAfterDelay:1];
    }
}

- (void)showHudWithMessage:(NSString *)message
            hideAfterDelay:(NSTimeInterval)afterDelay
{
    if (!message
        || ![message isKindOfClass:[NSString class]])
    {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:afterDelay];
}

#pragma mark - Super Methods
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
