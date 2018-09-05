
#import "ESProductHeaderView.h"
#import "SHSegmentedControl.h"

@implementation ESProductHeaderView
{
    SHSegmentedControl *_segmentControl;
    UILabel *_titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initHeaderView];
    }
    return self;
}

- (void)initHeaderView
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.scrollEnabled = NO;
    self.bounces = NO;
    self.contentSize = CGSizeMake(
                                  CGRectGetWidth(self.frame),
                                  CGRectGetHeight(self.frame) * 2
                                  );
    
    _segmentControl = [[SHSegmentedControl alloc] initWithFrame:self.bounds];
    _segmentControl.lineColor = [UIColor stec_blueTextColor];
    _segmentControl.titleColor = [UIColor stec_blueTextColor];
    _segmentControl.titlePlaceColor = [UIColor stec_subTitleTextColor];
    _segmentControl.titleFont = 14.0f;
    [self addSubview:_segmentControl];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                            0,
                                                            CGRectGetHeight(self.frame),
                                                            CGRectGetWidth(self.frame),
                                                            CGRectGetHeight(self.frame)
                                                            )];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

#pragma mark - Setter
- (void)setHeaderDelegate:(id<ESProductHeaderViewDelegate>)headerDelegate
{
    _headerDelegate = headerDelegate;
    
    _segmentControl.delegate = (id)_headerDelegate;
}

#pragma mark - Public Methods
- (void)updateHeaderWithSegTitles:( NSArray <NSString *> * _Nonnull )titles
                      bottomTitle:(NSString * _Nonnull)bottomTitle
{
    if (!titles
        || ![titles isKindOfClass:[NSArray class]]
        || ![[titles firstObject] isKindOfClass:[NSString class]]
        || ![bottomTitle isKindOfClass:[NSString class]])
    {
        return;
    }
    
    [_segmentControl createSegUIWithTitles:titles];
    _titleLabel.text = bottomTitle;
}

- (void)updateSelectedSegmentAtIndex:(NSInteger)index
{
    [_segmentControl updateSelectedSegmentAtIndex:index];
}

- (void)updateHeaderWithType:(ESProductHeaderType)headerType
{
    CGRect scrollRect = CGRectZero;
    switch (headerType)
    {
        case ESProductHeaderTypeSeg:
        {
            scrollRect = _segmentControl.frame;
            break;
        }
        case ESProductHeaderTypeLabel:
        {
            scrollRect = _titleLabel.frame;
            break;
        }
        default:
            break;
    }
    [self scrollRectToVisible:scrollRect animated:YES];
}

@end
