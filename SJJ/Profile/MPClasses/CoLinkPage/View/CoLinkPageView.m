
#import "CoLinkPageView.h"
#import "CoLinkPageImageView.h"

@interface CoLinkPageView ()

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CoLinkPageView
{
    CoLinkPageImageView *_imageView;
}

+ (instancetype)linkPageView
{
    NSArray *array = [[NSBundle mainBundle]
                      loadNibNamed:@"CoLinkPageImageView"
                      owner:self
                      options:nil];
    
    return [array lastObject];
}

- (void)updateLinkPageViewWithImages:(NSArray *)images
{
    self.pageControl.numberOfPages = images.count;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * images.count, 0);
    
    for (NSInteger i = 0; i < images.count; i++)
    {
        CoLinkPageImageView *imageView = [CoLinkPageImageView linkPageImageView];
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        imageView.image = [UIImage imageNamed:images[i]];
        [self layoutIfNeeded];

        // 如果是最后一页， 则让进入按钮可用
        if (i == images.count - 1)
        {
            imageView.enterButton.hidden = NO;
            imageView.enterButton.clipsToBounds = YES;
            imageView.enterButton.layer.cornerRadius = CGRectGetHeight(imageView.enterButton.frame)/2.0f;
            [imageView.enterButton addTarget:self
                                      action:@selector(enterbuttonClick:)
                            forControlEvents:UIControlEventTouchUpInside];
            _imageView = imageView;
        }
        [self.scrollView addSubview:imageView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    self.pageControl.currentPage = page;
}

#pragma mark - Button Click
- (void)enterbuttonClick:(UIButton *)button
{
//    WS(weakSelf);
//    [UIView animateWithDuration:0.3 animations:^{
////        _imageView.layer.transform = CATransform3DMakeScale(3, 3, 3);
////        _imageView.alpha = 0.3;
//    } completion:^(BOOL finished) {
//        if ([weakSelf.viewDelegate respondsToSelector:@selector(enterButtonDidTapped:)])
//        {
//            [weakSelf.viewDelegate enterButtonDidTapped:weakSelf];
//        }
//    }];
    if ([self.viewDelegate respondsToSelector:@selector(enterButtonDidTapped:)])
    {
        [self.viewDelegate enterButtonDidTapped:self];
    }
}

@end
