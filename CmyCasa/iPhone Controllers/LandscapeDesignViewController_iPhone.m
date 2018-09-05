//
//  LandscapeDesignViewController_iPhone.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 8/20/15.
//
//

#import "LandscapeDesignViewController_iPhone.h"
#import "ProgressPopupBaseViewController.h"

#import "UIImageView+LoadImage.h"

@interface LandscapeDesignViewController_iPhone ()
{
    NSMutableArray * _imageViewArray;
}
@end

@implementation LandscapeDesignViewController_iPhone


- (void)viewDidLoad {
    [super viewDidLoad];
    _imageViewArray = [NSMutableArray array];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self generateSlideshow];
    
    GalleryItemDO* item = [self.items objectAtIndex:self.index];
    [self loadImageFromUrl:[item url] index:self.index shouldScroll:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    
    NSLog(@"dealloc - LandscapeDesignViewController_iPhone");
}

-(void)clearScrollView{
    
    [self.scrollView setHidden:YES];
    
    for (UIView *view in [self.scrollView subviews]) {
        [view removeFromSuperview];
    }
    
    [_imageViewArray removeAllObjects];
    _imageViewArray = nil;
}

-(void)generateSlideshow{
    CGSize imageviewSize = self.view.bounds.size;
    for (int i = 0; i < [self.items count]; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * imageviewSize.width, 0, imageviewSize.width, imageviewSize.height)];
        imageView.tag = i;
        
        [_imageViewArray addObject:imageView];
        [self.scrollView addSubview:imageView];
    }
    
    [self.scrollView setContentSize:CGSizeMake(([self.items count] * imageviewSize.width), imageviewSize.height)] ;
}

-(void)loadImageFromUrl:(NSString*)url index:(NSInteger)index shouldScroll:(BOOL)shouldScroll{
    
    //load design image
    UIImageView * imageView = [_imageViewArray objectAtIndex:index];
    if (!imageView) {
        return;
    }
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

    CGSize imageviewSize = self.view.bounds.size;
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    __weak typeof(self) weakSelf = self;
    [imageView loadImageFromUrl:url withSize:imageSize defaultImage:nil animated:YES completion:^(UIImage *image, NSInteger uid, NSDictionary *imageMeta) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shouldScroll) {
                [weakSelf.scrollView scrollRectToVisible:CGRectMake(index * imageviewSize.width, 0, imageviewSize.width, imageviewSize.height) animated:NO];
            }

            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        });
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)in_scrollView {
    
    int width = self.scrollView.bounds.size.width;
    
    if (self.scrollView.contentOffset.x / width!= self.index){
        int tempItemIndex=self.scrollView.contentOffset.x/width;
        
        if (self.index != tempItemIndex) {

            if (self.index < [self.items count] && tempItemIndex < [self.items count]) {
                //moving forward
                if (self.index+1 == tempItemIndex) {
                    self.index = tempItemIndex;
                    GalleryItemDO* item = [self.items objectAtIndex:self.index];
                    [self loadImageFromUrl:[item url] index:self.index shouldScroll:NO];
                }
                //moving backward
                else if (self.index-1 == tempItemIndex) {
                    self.index = tempItemIndex;
                    GalleryItemDO* item = [self.items objectAtIndex:self.index];
                    [self loadImageFromUrl:[item url] index:self.index shouldScroll:NO];
                }
            }
        }
    }//end page change
}
- (IBAction)backLandscape:(id)sender {
    if (self.delegate != nil) {
        [self.delegate landscapeViewWillDismiss];
    }

    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
