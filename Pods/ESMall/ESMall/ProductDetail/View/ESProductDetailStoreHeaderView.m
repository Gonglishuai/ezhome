
#import "ESProductDetailStoreHeaderView.h"

@implementation ESProductDetailStoreHeaderView
{
    CGFloat _pointHeaderY;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initData];
        [self createHeaderView];
    }
    return self;
}

- (void)initData
{
    _pointHeaderY = -1.0f;
}

- (void)createHeaderView
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + 10)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.clipsToBounds = YES;
    backgroundView.layer.cornerRadius = 10.0f;
    [self addSubview:backgroundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0 - 15, 0, 30, CGRectGetHeight(self.frame))];
    imageView.image = [UIImage imageNamed:@"navigation_more"];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    
    CGFloat lineHeight = 0.5f;
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - lineHeight, CGRectGetWidth(self.frame), lineHeight);
    [self drawDashLine:lineView
            lineLength:5
           lineSpacing:2
             lineColor:[UIColor lightGrayColor]];
    [self addSubview:lineView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self addGestureRecognizer:pan];
}

#pragma mark pan   平移手势事件
-(void)panView:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:[UIApplication sharedApplication].keyWindow];
    if (_pointHeaderY <= 0)
    {
        CGPoint pointSelf = [sender locationInView:self];
        _pointHeaderY = pointSelf.y;
    }
    
    if (self.headerDelegate
        && [self.headerDelegate respondsToSelector:@selector(tapHeaderPointy:endStatus:)])
    {
        [self.headerDelegate tapHeaderPointy:point.y - _pointHeaderY endStatus:NO];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded
        || sender.state == UIGestureRecognizerStateCancelled
        || sender.state == UIGestureRecognizerStateFailed)
    {
        _pointHeaderY = -1.0f;
        
        if (self.headerDelegate
            && [self.headerDelegate respondsToSelector:@selector(tapHeaderPointy:endStatus:)])
        {
            [self.headerDelegate tapHeaderPointy:point.y - _pointHeaderY endStatus:YES];
        }
    }
}

#pragma mark - Methods
/// 做虚线
- (void)drawDashLine:(UIView *)lineView
          lineLength:(int)lineLength
         lineSpacing:(int)lineSpacing
           lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [lineView.layer addSublayer:shapeLayer];
}

@end
