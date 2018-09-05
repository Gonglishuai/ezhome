//
//  ESMyOrderViewController.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMyOrderViewController.h"
#import "ESOrderAPI.h"
#import "SHSegmentedControl.h"

#import "ESOrderListViewController.h"
#import "ESReturnOrderListViewController.h"

@interface ESMyOrderViewController ()<UIScrollViewDelegate, SHSegmentedControlDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL pageControlUsed;
@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) BOOL rotating;
@property (nonatomic, strong)SHSegmentedControl *segment;

@end

@implementation ESMyOrderViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (NSUInteger i =0; i < [self.childViewControllers count]; i++) {
        [self loadScrollViewWithPage:i];
    }
    
    _page = 0;
    if (self.childViewControllers.count>0) {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
        if (viewController.view.superview != nil) {
            [viewController viewWillAppear:animated];
        }
    }
    
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * [self.childViewControllers count], SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.childViewControllers count]) {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
        if (viewController.view.superview != nil) {
            [viewController viewDidAppear:animated];
        }
    }
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.childViewControllers count]) {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
        if (viewController.view.superview != nil) {
            [viewController viewWillDisappear:animated];
        }
    }
    [super viewWillDisappear:animated];
    
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
    if (viewController.view.superview != nil) {
        [viewController viewDidDisappear:animated];
    }
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = @"我的订单";
    self.rightButton.hidden = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _page = 0;
    _segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    _segment.lineColor = [UIColor stec_blueTextColor];
    _segment.titleColor = [UIColor stec_blueTextColor];
    _segment.titlePlaceColor = [UIColor stec_titleTextColor];
    _segment.titleFont = 15.0f;
    _segment.delegate = self;
    [_segment createSegUIWithTitles:@[@"全部",@"待支付",@"已支付",@"退款退货"]];
    [self.view addSubview:_segment];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT))];
    [self.view addSubview:_scrollView];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setScrollEnabled:YES];
    self.scrollView.bounces = NO;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelegate:self];
    
    [self setChildrenControllers];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setChildrenControllers {
    for (NSInteger i = 0; i < 3; i++) {
        ESOrderListViewController *orderListViewCon = [[ESOrderListViewController alloc] init];
        [orderListViewCon setType:[NSString stringWithFormat:@"%ld", (long)i]];
        [self addChildViewController:orderListViewCon];
    }
    ESReturnOrderListViewController *returnOrderListViewCon = [[ESReturnOrderListViewController alloc] init];
    [self addChildViewController:returnOrderListViewCon];

}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
    [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    _rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
    [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * [self.childViewControllers count], SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT));
    NSUInteger page = 0;
    
    for (viewController in self.childViewControllers) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        viewController.view.frame = frame;
        page++;
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * _page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    UIViewController *viewController = [self.childViewControllers objectAtIndex:_page];
    [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}



- (void)loadScrollViewWithPage:(NSInteger)page {
    if (page < 0)
        return;
    if (page >= [self.childViewControllers count])
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [self.childViewControllers objectAtIndex:page];
    if (controller == nil) {
        return;
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)changePage:(NSInteger)page {

    _pageControlUsed = YES;
    CGRect frame = self.scrollView.frame;
    frame.origin.x = SCREEN_WIDTH * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];

    
    if (!_rotating) {
        UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
        UIViewController *newViewController = [self.childViewControllers objectAtIndex:page];
        [oldViewController viewWillDisappear:YES];
        [newViewController viewWillAppear:YES];
        [oldViewController viewDidDisappear:YES];
        [newViewController viewDidAppear:YES];
        
    }
    _page = page;
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = SCREEN_WIDTH;
    if (!_pageControlUsed)  {
        int page = self.scrollView.contentOffset.x / pageWidth;
        if (_page != page) {
            UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
            UIViewController *newViewController = [self.childViewControllers objectAtIndex:page];
            [oldViewController viewWillDisappear:YES];
            [newViewController viewWillAppear:YES];
            [oldViewController viewDidDisappear:YES];
            [newViewController viewDidAppear:YES];
            _page = page;
            if (!_pageControlUsed) {
                _rotating = YES;
                [_segment updateSelectedSegmentAtIndex:_page];
                _segment.selectedIndex = _page;
                _rotating = NO;
            }
        }
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
    _rotating = NO;
}
#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index {
    if (!_rotating) {
        [self changePage:index];
    }
    
}


@end
