
#import "ESProductDetailLoopCell.h"
#import "JRPageControl.h"
#import "ESTouchImageView.h"
#import "ESProductImagesModel.h"
#import "ESProductDetailWebView.h"

@interface ESProductDetailLoopCell ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ESProductDetailLoopCell
{
    JRPageControl *_pageControl;
    UIImageView *_emptyImageView;
    ESProductDetailWebView *_webView;
    
    BOOL _hasImage;
    BOOL _hasModelUrl;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellDelegate
        || ![self.cellDelegate respondsToSelector:@selector(getLoopImagesAtIndexPath:)]
        || ![self.cellDelegate respondsToSelector:@selector(getLoopModelUrlAtIndexPath:)])
    {
        return;
    }
    
    NSArray *images = [(id)self.cellDelegate getLoopImagesAtIndexPath:indexPath];
    NSString *modelUrlStr = [(id)self.cellDelegate getLoopModelUrlAtIndexPath:indexPath];
    
    if (images
        && [images isKindOfClass:[NSArray class]]
        && images.count > 0)
    {
        _hasImage = YES;
    }
    
    if (modelUrlStr
        && [modelUrlStr isKindOfClass:[NSString class]]
        && modelUrlStr.length > 0)
    {
        _hasModelUrl = YES;
    }
    
    if (!_hasImage && !_hasModelUrl)
    {
        [self createEmptyImageView];
        return;
    }
    else
    {
        [_emptyImageView removeFromSuperview];
    }
    
    BOOL shouldUpdate = [self updateScrollViewWithImageCount:images.count];
    if (!shouldUpdate)
    {
        return;
    }
    
    if (_hasModelUrl)
    {
        SHLog(@"modelUrlStr:%@", modelUrlStr);

        WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
        _webView = [[ESProductDetailWebView alloc] initWithFrame:self.scrollView.bounds
                                                   configuration:webConfig];
        NSURL *modelUrl = [NSURL URLWithString:modelUrlStr];
        [_webView loadRequest:[NSURLRequest requestWithURL:modelUrl]];
        [_scrollView addSubview:_webView];
    }
    if (_hasImage)
    {
        for (NSInteger i = 0; i < images.count; i++)
        {
            ESProductImagesModel *imageModel = images[i];
            ESTouchImageView *imageView = [[ESTouchImageView alloc]
                                           initWithFrame:CGRectMake(
                                                                    SCREEN_WIDTH * (_hasModelUrl ? i + 1 : i),
                                                                    0,
                                                                    SCREEN_WIDTH,
                                                                    SCREEN_WIDTH
                                                                    )];
            imageView.index = i;
            [imageView updateImageViewWithUrlStr:imageModel.imageUrl];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(imageViewDidTapped:)];
            [imageView addGestureRecognizer:tap];
            [_scrollView addSubview:imageView];
        }
    }
}

- (void)createEmptyImageView
{
    if (_emptyImageView)
    {
        return;
    }
    
    _emptyImageView = [[UIImageView alloc]
                       initWithFrame:CGRectMake(
                                                0,
                                                0,
                                                SCREEN_WIDTH,
                                                SCREEN_WIDTH
                                                )];
    _emptyImageView.image = [UIImage imageNamed:@"image_default"];
    [_scrollView addSubview:_emptyImageView];
}

- (BOOL)updateScrollViewWithImageCount:(NSInteger)count
{
    if (_pageControl)
    {
        return NO;
    }
    
    NSInteger imageCount = count;
    if (_hasModelUrl)
    {
        imageCount += 1;
    }
    
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * imageCount, SCREEN_WIDTH);
    
    // 设置分页显示的圆点
    _pageControl = [[JRPageControl alloc] init];
    _pageControl.alpha = 0.8;
    _pageControl.currentColor = [UIColor whiteColor];
    _pageControl.otherColour = [UIColor grayColor];
    _pageControl.frame = CGRectMake(0, SCREEN_WIDTH - 9, SCREEN_WIDTH, 9);
    _pageControl.numberOfPages = imageCount;
    _pageControl.hidesForSinglePage = YES;
    [self.contentView addSubview:_pageControl];
    
    return YES;
}

#pragma mark - Tap Method
- (void)imageViewDidTapped:(UITapGestureRecognizer *)tap
{
    if (![tap.view isKindOfClass:[ESTouchImageView class]])
    {
        return;
    }
    
    ESTouchImageView *imageView = (id)tap.view;
    
    NSMutableArray *arrM = [NSMutableArray array];
    for (UIView *view in _scrollView.subviews)
    {
        if ([view isKindOfClass:[ESTouchImageView class]])
        {
            [arrM addObject:view];
        }
    }
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(imageDidTppedAtLoopCell:index:imageViews:)])
    {
        [(id)self.cellDelegate imageDidTppedAtLoopCell:self
                                                 index:imageView.index
                                            imageViews:[arrM copy]];
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame);
    _pageControl.currentPage = index;
}

#pragma mark - ESPhotoBrowserDelegate
- (void)photoBrowserDidChangedToPageAtIndex:(NSUInteger)index
{
    NSInteger browserIndex = _hasModelUrl ? index + 1 : index;
    if (browserIndex == _pageControl.currentPage)
    {
        return;
    }
    
    SHLog(@"ESPhotoBrowserDelegate photoBrowserDidChangedToPageAtIndex:%ld", index);
    
    ESTouchImageView *imageView = nil;
    for (ESTouchImageView *imageV in _scrollView.subviews)
    {
        if ([imageV isKindOfClass:[ESTouchImageView class]]
            && imageV.index == index)
        {
            imageView = imageV;
        }
    }
    
    [_scrollView scrollRectToVisible:imageView.frame animated:NO];
    _pageControl.currentPage = browserIndex;
}

- (void)dealloc
{
    SHLog(@"ESProductDetailLoopCell dealloc");
}

@end
