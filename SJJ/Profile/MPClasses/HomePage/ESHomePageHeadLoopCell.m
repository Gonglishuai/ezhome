
#import "ESHomePageHeadLoopCell.h"
#import "UIImageView+WebCache.h"
#import <Masonry.h>

@protocol ESHomePageHeadLoopImageViewDelegate <NSObject>

- (void)imageViewDidTappedWithIndex:(NSInteger)index;

@end

@interface ESHomePageHeadLoopImageView : UIImageView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) id <ESHomePageHeadLoopImageViewDelegate>imageDelegate;

@end

@implementation ESHomePageHeadLoopImageView

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
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTapped)]];
}

- (void)initUI
{
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)imageDidTapped
{
    if (self.imageDelegate
        && [self.imageDelegate respondsToSelector:@selector(imageViewDidTappedWithIndex:)])
    {
        [self.imageDelegate imageViewDidTappedWithIndex:self.index];
    }
}

@end

@interface ESHomePageHeadLoopCell ()<ESHomePageHeadLoopImageViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *bottomSpaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceHeightConstraint;

@end

@implementation ESHomePageHeadLoopCell
{
    NSTimer *_timer;
    NSInteger _loopCount;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
}

- (void)updateBottomSpaceStatus:(BOOL)showStatus
{
    CGFloat spaceHeight = showStatus ? 4.0f : 0.0f;
    self.bottomSpaceHeightConstraint.constant = spaceHeight;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getHeadLoopInformation)])
    {
        NSArray *images = [self.cellDelegate getHeadLoopInformation];
        if (images.count <= 0) return;
        
        _loopCount = images.count;
        self.pageControl.numberOfPages = _loopCount;
        
        if (images
            && [images isKindOfClass:[NSArray class]])
        {
            [self cleanScrollSubViews];
            self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * (_loopCount + 2), CGRectGetHeight(self.scrollView.frame));
            
            ESHomePageHeadLoopImageView *lastImageView = nil;
            for (NSInteger i = 0; i < _loopCount + 2; i++)
            {
                NSInteger imageIndex = 0;
                if (i == _loopCount + 1)
                {
                    imageIndex = 0;
                }
                else if (i == 0)
                {
                    imageIndex = _loopCount - 1;
                }
                else
                {
                    imageIndex = i - 1;
                }
                NSString *imagePath = images[imageIndex];
                if (imagePath
                    && [imagePath isKindOfClass:[NSString class]])
                {
                    ESHomePageHeadLoopImageView *imageView = [[ESHomePageHeadLoopImageView alloc] init];
                    imageView.imageDelegate = self;
                    imageView.index = imageIndex;
                    [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
                    [self.scrollView addSubview:imageView];
                    
                    __weak UIScrollView *weakScrollView = self.scrollView;
                    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(lastImageView?lastImageView.mas_right:weakScrollView.mas_left);
                        make.top.equalTo(weakScrollView.mas_top);
                        make.width.mas_equalTo(SCREEN_WIDTH);
                        make.height.mas_equalTo(weakScrollView.mas_height);
                    }];
                    lastImageView = imageView;
                }
            }
            
            self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
            
            if (_loopCount > 1)
            {
                self.scrollView.scrollEnabled = YES;
                [self setupTimer];
            }
            else
            {
                self.scrollView.scrollEnabled = NO;
                [self invalidateTimer];
            }
        }
    }
}

- (void)cleanScrollSubViews
{
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ESHomePageHeadLoopImageView class]])
        {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - ESHomePageHeadLoopImageViewDelegate
- (void)imageViewDidTappedWithIndex:(NSInteger)index;
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(imageDidTappedWithIndex:)])
    {
        [self.cellDelegate imageDidTappedWithIndex:index];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat currentX = self.scrollView.contentOffset.x;
    NSInteger infoIndex = currentX/(SCREEN_WIDTH * 1.0);
    if (infoIndex >= _loopCount + 1)
    {// 滑动到最后一条时回滚到第一条
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
        self.pageControl.currentPage = 0;
    }
    else if (currentX == 0)
    {
        self.pageControl.currentPage = _loopCount - 1;
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * _loopCount, 0);
    }
    else
    {
        self.pageControl.currentPage = infoIndex - 1;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    SHLog(@"scrollViewWillBeginDragging");
    [self invalidateTimer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    SHLog(@"scrollViewWillEndDragging");
    [self invalidateTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    SHLog(@"scrollViewDidEndDragging");
    [self invalidateTimer];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    SHLog(@"scrollViewWillBeginDecelerating");
    [self invalidateTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    SHLog(@"scrollViewDidEndDecelerating");
    [self setupTimer];
}

#pragma mark - Timer
- (void)setupTimer
{
    [self invalidateTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:6.0f
                                              target:self
                                            selector:@selector(scrollLoopImages)
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

- (void)scrollLoopImages
{
    CGFloat currentX = self.scrollView.contentOffset.x;
    currentX += SCREEN_WIDTH;
    BOOL animated = YES;
    if (currentX >= self.scrollView.contentSize.width)
    {
        currentX = 0.0f;
        animated = NO;
    }
    [self.scrollView scrollRectToVisible:CGRectMake(currentX, 0, SCREEN_WIDTH, CGRectGetHeight(self.scrollView.frame)) animated:YES];
}

- (void)dealloc
{
    [self invalidateTimer];
}

@end
