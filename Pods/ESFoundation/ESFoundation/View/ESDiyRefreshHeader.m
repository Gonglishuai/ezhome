
#import "ESDiyRefreshHeader.h"
//#import "ESAppConfigManager.h"
#import "UIFont+Stec.h"
#import "MGJRouter.h"
#import "ESFoundationAssets.h"

@interface ESDiyRefreshHeader()
{
    __unsafe_unretained UIImageView *_gifView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@property (assign, nonatomic) NSInteger refreshMessageIndex;
@property (strong, nonatomic) NSArray *refreshMessages;

@end

@implementation ESDiyRefreshHeader

#pragma mark - 懒加载
- (UIImageView *)gifView
{
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages
{
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations
{
    if (!_stateDurations) {
        self.stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

- (NSArray *)refreshMessages
{
    if (!_refreshMessages)
    {
        __weak ESDiyRefreshHeader *weakHeader = self;
        [self getRefreshMessagesCallback:^(NSArray *arr) {
            weakHeader.refreshMessages = arr;
        }];
    }
    return _refreshMessages;
}

- (void)getRefreshMessagesCallback:(void(^)(NSArray *arr))callback
{
    [MGJRouter openURL:@"refresh/Header/TipMessage" withUserInfo:nil completion:^(id result) {
        
        NSArray *arrTips = @[@"装房子 买家具 我都来设计家"];
        if (result
            && [result isKindOfClass:[NSArray class]])
        {
            NSArray *arr = (id)result;
            if (arr.count > 0
                && [[arr firstObject] isKindOfClass:[NSString class]])
            {
                arrTips = arr;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
            {
                callback(arrTips);
            }
        });
        
    }];
}

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state
{
    if (images == nil) return;
    
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
    
    /* 根据图片设置控件的高度 */
    self.mj_h = 60;
}

- (void)setImages:(NSArray *)images forState:(MJRefreshState)state
{
    [self setImages:images duration:images.count * 0.1 forState:state];
}

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];
    
    self.lastUpdatedTimeLabel.hidden = YES;
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    NSArray *images = self.stateImages[@(MJRefreshStateIdle)];
    if (self.state != MJRefreshStateIdle || images.count == 0) return;
    // 停止动画
    [self.gifView stopAnimating];
    // 设置当前需要显示的图片
    
    if (pullingPercent < 0.35
        && images.count > 0)
    {
        self.gifView.image = images[0];
        return;
    }
    
    NSUInteger index =  images.count * (pullingPercent - 0.35);
    if (index >= images.count) index = images.count - 1;
    self.gifView.image = images[index];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.gifView.constraints.count) return;
    
    self.gifView.frame = self.bounds;
        
    self.stateLabel.mj_y = 0;
    self.stateLabel.mj_h = 20;
    self.gifView.mj_y = 23;
    self.gifView.mj_x = self.mj_w/2.0 - 17.0f;
    self.gifView.mj_w = 34;
    self.gifView.mj_h = 34;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshState oldState = self.state;
    if (state == oldState) return;
    
    [super setState:state];
    
    if (state == MJRefreshStateIdle)
    {
        [self performSelector:@selector(updateRefreshHeaderMessage) withObject:nil afterDelay:0.2f];
    }
    
    // 根据状态做事情
    if (state == MJRefreshStatePulling || state == MJRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;
        
        [self.gifView stopAnimating];
        if (images.count == 1) { // 单张图片
            self.gifView.image = [images lastObject];
        } else { // 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == MJRefreshStateIdle) {
        [self.gifView stopAnimating];
    }
}

+ (instancetype)headerWithRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    ESDiyRefreshHeader *refreshHeader = [super headerWithRefreshingTarget:target refreshingAction:action];
    
    [refreshHeader updateRefreshHeaderUI];
    return refreshHeader;
}

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    ESDiyRefreshHeader *refreshHeader = [super headerWithRefreshingBlock:refreshingBlock];

    [refreshHeader updateRefreshHeaderUI];
    return refreshHeader;
}

- (void)updateRefreshHeaderUI
{
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    NSMutableArray *refreshing = [NSMutableArray array];
    for (NSInteger i = 99; i >= 0; i--) {
        UIImage *image = [ESFoundationAssets bundleImage:[NSString stringWithFormat:@"header_refresh__00%02ld", i]];
        
        if (image)
        {
            [refreshing addObject:image];
            if (i >= 50)
            {
                [idleImages addObject:image];
            }
        }
    }
    [self setImages:idleImages duration:2 forState:MJRefreshStateIdle];
    [self setImages:@[[ESFoundationAssets bundleImage:@"header_refresh__0050"]] duration:2 forState:MJRefreshStatePulling];
    [self setImages:refreshing duration:1.8 forState:MJRefreshStateRefreshing];
    [self setImages:@[[ESFoundationAssets bundleImage:@"header_refresh__0050"]] forState:MJRefreshStateWillRefresh];
    // Hide the status
    self.stateLabel.hidden = NO;
    self.stateLabel.font = [UIFont stec_paramsFount];
    self.refreshMessageIndex = 0;
    [self updateRefreshHeaderMessage];
}

#pragma mark - Methods
- (void)updateRefreshHeaderMessage
{
    if (self.refreshMessageIndex >= self.refreshMessages.count
        || self.refreshMessageIndex < 0)
    {
        __weak ESDiyRefreshHeader *weakHeader = self;
        [self getRefreshMessagesCallback:^(NSArray *arr) {
            weakHeader.refreshMessages = arr;
        }];
        _refreshMessageIndex = 0;
    }
    NSString *refreMessage = _refreshMessages[_refreshMessageIndex];
    [self setTitle:refreMessage forState:MJRefreshStateIdle];
    [self setTitle:refreMessage forState:MJRefreshStatePulling];
    [self setTitle:refreMessage forState:MJRefreshStateRefreshing];
    [self setTitle:refreMessage forState:MJRefreshStateWillRefresh];
    
    _refreshMessageIndex++;
}

@end
