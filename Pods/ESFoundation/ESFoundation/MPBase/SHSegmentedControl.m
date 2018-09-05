
#import "SHSegmentedControl.h"
#import "SHSegButton.h"

@implementation SHSegmentedControl
{
    UIView *_lineView;          //!< _lineView the line view.
    NSMutableArray *_arrBtns;   //!< _arrBtns the array of seg buttons.
    NSInteger _lastTag;         //!< _lastTag the tag of last click button.
    SHSegButton *_selectedBtn;  //!< the button which selected.
    CGFloat _titlesWidth;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

- (void)initUI {
//    UIView *viewTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
//    viewTopLine.backgroundColor = [UIColor colorWithRed:180/255.0 green:182/255.0 blue:180/255.0 alpha:1];
//    [self addSubview:viewTopLine];
//    
//    UIView *viewBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
//    viewBottomLine.backgroundColor = [UIColor colorWithRed:180/255.0 green:182/255.0 blue:180/255.0 alpha:1];
//    [self addSubview:viewBottomLine];
    
    _lineView = [[UIView alloc] init];
    _lineView.clipsToBounds = YES;
    _lineView.layer.cornerRadius = 1.0f;
    [self addSubview:_lineView];
}

- (void)initData {
    _lineColor          = [UIColor redColor];
    _titleColor         = [UIColor redColor];
    _titlePlaceColor    = [UIColor lightGrayColor];
    _time               = 0.2;
    _arrBtns            = [NSMutableArray array];
    _titleFont          = 17.0;
    _lastTag            = 0;
    _titlesWidth        = 0.0f;
    _selectedIndex      = 0;
}

#pragma Public Methods
- (void)createSegUIWithTitles:(NSArray *)titles {
    NSArray *widths = [self getButtonsWidthWithTitles:titles];
    CGFloat spaceWidth = (CGRectGetWidth(self.frame) - _titlesWidth)/(titles.count + 1);
    
    CGFloat x = spaceWidth;
    CGFloat y = 0;
//    CGFloat btnWidth = self.frame.size.width / (titles.count * 1.0);
    CGFloat btnHeight = CGRectGetHeight(self.frame);
    
    
    
    // create buttons.
    for (NSInteger i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        CGFloat btnWidth = [widths[i] doubleValue];
        SHSegButton *button = [SHSegButton createSegButtonWithTitle:title
                                                         titleColor:_titleColor
                                                    titlePlaceColor:_titlePlaceColor
                                                               font:_titleFont
                                                              frame:CGRectMake(x, y, btnWidth, btnHeight)
                                                             target:self
                                                             action:@selector(segButtonClick:)
                                                          buttonTag:i];
        
        [self addSubview:button];
        x += btnWidth + spaceWidth;
        
        if (i == _selectedIndex)
        {
            button.selected = YES;
            _selectedBtn = button;
            _lastTag = i;
        }
        [_arrBtns addObject:button];
    }
    
    // update line. when the titles.count <=1,hidden the lineView
    _lineView.backgroundColor = titles.count > 1 ? _lineColor : [UIColor clearColor];
    // dispathch_after for get the really _selectedBtn.titleLabel.frame.size.width
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

- (void)updateSelectedSegmentAtIndex:(NSInteger)index
{
    if (_lastTag == index) return;
    for (SHSegButton *segButton in _arrBtns)
    {
        if (segButton.buttonTag == index)
        {
            [self segButtonClick:segButton];
            break;
        }
    }
}

- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles;
{
    NSMutableArray *widths = [NSMutableArray array];
    
    for (NSString *title in titles)
    {
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_titleFont]}];
        
        CGFloat width = size.width;
        _titlesWidth += width;
        
        NSNumber *widthObj = [NSNumber numberWithFloat:width];
        [widths addObject:widthObj];
    }
    
    return widths;
}

#pragma mark - Button Click
- (void)segButtonClick:(SHSegButton *)btn {
    if (btn.buttonTag == _lastTag) return;
    _lastTag = btn.buttonTag;
    
    [self changeButtonStatusWithSegBthTag:btn.buttonTag];
    
    [UIView animateWithDuration:_time animations:^{
        CGFloat lineViewX = _selectedBtn.frame.origin.x + _selectedBtn.titleLabel.frame.origin.x;
        CGFloat lineViewW = _selectedBtn.titleLabel.frame.size.width;
        _lineView.frame = CGRectMake(lineViewX, CGRectGetHeight(self.frame) - 2, lineViewW, 2);
    }];
    if ([self.delegate respondsToSelector:@selector(segBtnClickWithTitleIndex:)]) {
        [self.delegate segBtnClickWithTitleIndex:btn.buttonTag];
    }
}

- (void)changeButtonStatusWithSegBthTag:(NSInteger)btnTag {
    for (SHSegButton *btn in _arrBtns) {
        if (btn.buttonTag == btnTag) {
            btn.selected = YES;
            _selectedBtn = btn;
            [self setNeedsLayout];
        } else {
            btn.selected = NO;
        }
    }
}

#pragma mark - Super Method
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat lineViewX = _selectedBtn.frame.origin.x + _selectedBtn.titleLabel.frame.origin.x;
    CGFloat lineViewW = _selectedBtn.titleLabel.frame.size.width;
    _lineView.frame = CGRectMake(lineViewX, CGRectGetHeight(self.frame) - 2, lineViewW, 2);
}


@end
