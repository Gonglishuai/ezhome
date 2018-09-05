
#import "ESHomePageHeadLineCell.h"
#import <Masonry.h>

@protocol ESHomePageHeadLineLabelDelegate <NSObject>

- (void)lineDidTappedWithIndex:(NSInteger)index;

@end

@interface ESHomePageHeadLineLabel : UILabel

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) id <ESHomePageHeadLineLabelDelegate>labelDelegate;

@end

@implementation ESHomePageHeadLineLabel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self addTap];
        [self initUI];
    }
    return self;
}

- (void)addTap
{
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lineDidTapped)]];
}

- (void)initUI
{
    self.font = [UIFont stec_tagFount];
    self.textColor = [UIColor stec_titleDarkColor];
}

- (void)lineDidTapped
{
    if (self.labelDelegate
        && [self.labelDelegate respondsToSelector:@selector(lineDidTappedWithIndex:)])
    {
        [self.labelDelegate lineDidTappedWithIndex:self.index];
    }
}

@end

@interface ESHomePageHeadLineCell ()<ESHomePageHeadLineLabelDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ESHomePageHeadLineCell
{
    NSTimer *_timer;
    NSInteger _infosCount;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getHeadLineInformation)])
    {
        NSArray *info = [self.cellDelegate getHeadLineInformation];
        if (info.count <= 0) return;
        
        _infosCount = info.count;
        
        if (info
            && [info isKindOfClass:[NSArray class]])
        {
            [self cleanScrollSubViews];
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) * (_infosCount + 1));
            
            ESHomePageHeadLineLabel *lastLabel = nil;
            for (NSInteger i = 0; i < _infosCount + 1; i++)
            {
                NSDictionary *dict = nil;
                if (i == _infosCount)
                {
                    dict = info[0];
                }
                else
                {
                    dict = info[i];
                }
                if (dict
                    && [dict isKindOfClass:[NSDictionary class]]
                    && dict[@"title"]
                    && [dict[@"title"] isKindOfClass:[NSString class]])
                {
                    ESHomePageHeadLineLabel *lineLabel = [[ESHomePageHeadLineLabel alloc] init];
                    lineLabel.text = dict[@"title"];
                    lineLabel.labelDelegate = self;
                    lineLabel.index = i == _infosCount ? 0 : i;
                    [self.scrollView addSubview:lineLabel];
                    
                    __weak UIScrollView *weakScrollView = self.scrollView;
                    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(weakScrollView).with.offset(0);
                        make.top.equalTo(lastLabel?lastLabel.mas_bottom:_scrollView.mas_top);
                        make.width.mas_equalTo(weakScrollView.mas_width);
                        make.height.mas_equalTo(weakScrollView.mas_height);
                    }];
                    lastLabel = lineLabel;
                }
            }
            
            [self setupTimer];
        }
    }
}

- (void)cleanScrollSubViews
{
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ESHomePageHeadLineLabel class]])
        {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - ESHomePageHeadLineLabelDelegate
- (void)lineDidTappedWithIndex:(NSInteger)index
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(headLineDidTappedWithIndex:)])
    {
        [self.cellDelegate headLineDidTappedWithIndex:index];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);
    CGFloat currentY = self.scrollView.contentOffset.y;
    NSInteger infoIndex = currentY/(scrollViewHeight * 1.0);
    if (infoIndex >= _infosCount)
    {// 滑动到最后一条时回滚到第一条
        self.scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - Timer
- (void)setupTimer
{
    [self invalidateTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:4.5f
                                              target:self
                                            selector:@selector(scrollHeadTitles)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    if (_timer
        && [_timer isKindOfClass:[NSTimer class]])
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)scrollHeadTitles
{
    CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);
    CGFloat currentY = self.scrollView.contentOffset.y;
    currentY += scrollViewHeight;
    BOOL animated = YES;
    if (currentY >= self.scrollView.contentSize.height)
    {
        currentY = 0.0f;
        animated = NO;
    }
    [self.scrollView scrollRectToVisible:CGRectMake(0, currentY, CGRectGetWidth(self.scrollView.frame), scrollViewHeight) animated:YES];
}

- (void)dealloc
{
    [self invalidateTimer];
}

@end
