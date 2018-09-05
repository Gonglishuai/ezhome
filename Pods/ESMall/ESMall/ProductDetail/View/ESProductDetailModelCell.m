
#import "ESProductDetailModelCell.h"
#import "ESProductDetailModelView.h"

@interface ESProductDetailModelCell ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ESProductDetailModelCell
{
    UIImageView *_emptyImageView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self needUpdate])
    {
        return;
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getProductSampleroomCountAtIndexPath:)])
    {
        NSInteger sampleroomCount = [(id)self.cellDelegate getProductSampleroomCountAtIndexPath:indexPath];
        
        if (sampleroomCount <= 0)
        {
            [self createEmptyImageView];
            return;
        }
        else
        {
            [_emptyImageView removeFromSuperview];
        }
        
        [self.scrollView layoutIfNeeded];
        self.scrollView.contentSize = CGSizeMake(
                                                 CGRectGetWidth(self.scrollView.frame) * sampleroomCount,
                                                 CGRectGetHeight(self.scrollView.frame) - 0.5f
                                                 );
        for (NSInteger i =0; i < sampleroomCount; i++)
        {
            ESProductDetailModelView *view = [ESProductDetailModelView productDetailModelView];
            view.frame = CGRectMake(
                                    i * CGRectGetWidth(self.scrollView.frame),
                                    0,
                                    CGRectGetWidth(self.scrollView.frame),
                                    CGRectGetHeight(self.scrollView.frame) - 0.5f
                                    );
            view.viewDelegate = (id)self.cellDelegate;
            [view updateModelViewWithIndex:i];
            [self.scrollView addSubview:view];
        }
    }
}

- (BOOL)needUpdate
{
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[ESProductDetailModelView class]])
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)createEmptyImageView
{
    if (_emptyImageView)
    {
        return;
    }
    
    _emptyImageView = [[UIImageView alloc]
                       initWithFrame:self.scrollView.bounds];
    _emptyImageView.image = [UIImage imageNamed:@"image_default"];
    _emptyImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_emptyImageView];
}

@end
