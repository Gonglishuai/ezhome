//
//  iphoneMyDesignEditViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "MyDesignEditBaseViewController.h"

@interface MyDesignEditViewController_iPhone : MyDesignEditBaseViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *pageScroll;
@property (weak, nonatomic) IBOutlet UIView *controlsContainer;


@end
