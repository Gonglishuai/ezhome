
#import "ESProductDetailHeaderView.h"

@interface ESProductDetailHeaderView ()

@property (weak, nonatomic) IBOutlet UIView *headerBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@end

@implementation ESProductDetailHeaderView
{
    BOOL _openStatus;
    BOOL _lastOpenStatus;
    NSInteger _index;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(headerDidTapped)];
    [self.headerBackgroundView addGestureRecognizer:tap];
}

#pragma mark - Tap Method
- (void)headerDidTapped
{
    _openStatus = !_openStatus;
    [self showArrowIconWithAnimated:YES];
    
    if (self.headerDelegate
        && [self.headerDelegate respondsToSelector:@selector(productHeaderDidTappedAtIndex:status:)])
    {
        [self.headerDelegate productHeaderDidTappedAtIndex:_index
                                                    status:_openStatus];
    }
}

#pragma mark - Public Methods
+ (instancetype)productDetailHeaderView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESProductDetailHeaderView"
                                                   owner:self
                                                 options:nil];
    return [array firstObject];
}

- (void)updateHeaderAtIndex:(NSInteger)index;
{
    if (self.headerDelegate
        && [self.headerDelegate respondsToSelector:@selector(getShowStatusAtSection:)]
        && [self.headerDelegate respondsToSelector:@selector(getHeaderTitleAtSection:)])
    {
        _index = index;
        NSString *title = [self.headerDelegate getHeaderTitleAtSection:index];
        if (title
            && [title isKindOfClass:[NSString class]])
        {
            self.titleLabel.text = title;
        }
        
        _openStatus = [self.headerDelegate getShowStatusAtSection:index];
        self.bottomLineView.hidden = !_openStatus;
        [self showArrowIconWithAnimated:NO];
    }
}

#pragma mark - Method
- (void)showArrowIconWithAnimated:(BOOL)showAnimated
{
    NSInteger count = _openStatus?90:0;
    if (showAnimated)
    {
        __weak ESProductDetailHeaderView *weakSelf = self;
        [UIView animateWithDuration:0.3f animations:^{
            
            weakSelf.iconImageView.transform = CGAffineTransformMakeRotation(count * M_PI/180.0f);
        }];
    }
    else
    {
        self.iconImageView.transform = CGAffineTransformMakeRotation(count * M_PI/180.0f);
    }
}

@end
