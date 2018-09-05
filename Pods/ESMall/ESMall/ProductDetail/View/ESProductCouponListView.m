
#import "ESProductCouponListView.h"
#import "ESProductCouponListCell.h"
#import "ESProductDetailCouponsModel.h"

@interface ESProductCouponListView ()
<
UITableViewDelegate,
UITableViewDataSource,
ESProductCouponListCellDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ESProductCouponListView
{
    NSArray *_arrayDS;
    
    UIView *_blurView;
    UIView *_backgroundView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESProductCouponListCell" bundle:[ESMallAssets hostBundle]] forCellReuseIdentifier:@"ESProductCouponListCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    _blurView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _blurView.backgroundColor = [UIColor blackColor];
    _blurView.alpha = 0.01f;
    [_blurView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(hideCouponListView)]];
    [_backgroundView addSubview:_blurView];
}

+ (instancetype)couponListView
{
    NSArray *arr = [[ESMallAssets hostBundle] loadNibNamed:@"ESProductCouponListView"
                                                 owner:self
                                               options:nil];
    return [arr firstObject];
}

+ (void)showCouponListViewWithDataSource:(NSArray *)array
{
    ESProductCouponListView *view = [ESProductCouponListView couponListView];
    [view showCouponListViewWithDataSource:array];
}

- (void)showCouponListViewWithDataSource:(NSArray *)array
{
    _arrayDS = array;
    
    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT/3.0f);
    [_backgroundView addSubview:self];
    
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundView];
    
    __weak UIView *weakSelf = self;
    __weak UIView *weakBlur = _blurView;
    [UIView animateWithDuration:0.3f animations:^{
        weakBlur.alpha = 0.5f;
        weakSelf.frame = CGRectMake(
                                    0,
                                    SCREEN_HEIGHT * (2/3.0f),
                                    SCREEN_WIDTH,
                                    SCREEN_HEIGHT/3.0f
                                    );
    }];
}

- (void)hideCouponListView
{
    __weak UIView *weakSelf = self;
    __weak UIView *weakBlur = _blurView;
    [UIView animateWithDuration:0.2f animations:^{
        weakBlur.alpha = 0.01f;
        weakSelf.frame = CGRectMake(
                                    0,
                                    SCREEN_HEIGHT,
                                    SCREEN_WIDTH,
                                    SCREEN_HEIGHT/3.0f
                                    );
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
    }];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_arrayDS
        && [_arrayDS isKindOfClass:[NSArray class]])
    {
        return _arrayDS.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_arrayDS
        && [_arrayDS isKindOfClass:[NSArray class]]
        && indexPath.row < _arrayDS.count)
    {
        ESProductDetailCouponsModel *model = _arrayDS[indexPath.row];
        if ([model isKindOfClass:[ESProductDetailCouponsModel class]])
        {
            return model.height;
        }
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"ESProductCouponListCell";
    ESProductCouponListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.cellDelegate = self;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}

#pragma mark - ESProductCouponListCellDelegate
- (ESProductDetailCouponsModel *)getCouponListDataWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _arrayDS.count)
    {
        ESProductDetailCouponsModel *model = _arrayDS[indexPath.section];
        return model;
    }
    
    return nil;
}

#pragma mark - Button Method
- (IBAction)closeButtonDidTapped:(id)sender
{
    [self hideCouponListView];
}

@end
