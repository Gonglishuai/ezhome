
#import "ESHomePageNavigatorBar.h"

@interface ESHomePageNavigatorBar ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigatorTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation ESHomePageNavigatorBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.navigatorTopConstraint.constant = STATUSBAR_HEIGHT;
    
    self.searchButton.layer.masksToBounds = YES;
    self.searchButton.layer.cornerRadius = CGRectGetHeight(self.searchButton.frame)/2.0f;
}

+ (instancetype)homePageNavigatorBar
{
    ESHomePageNavigatorBar *bar = [[[NSBundle mainBundle]
                                   loadNibNamed:@"ESHomePageNavigatorBar"
                                   owner:self
                                   options:nil] firstObject];
    return bar;
}

- (IBAction)searchButtonDidTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(searchButtonDidTapped)])
    {
        [self.delegate searchButtonDidTapped];
    }
}

- (IBAction)rightButtonDidTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(rightButtonDidTapped)])
    {
        [self.delegate rightButtonDidTapped];
    }
}

- (IBAction)leftButtonDidTapped:(id)sender
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(leftButtonDidTapped)])
    {
        [self.delegate leftButtonDidTapped];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
