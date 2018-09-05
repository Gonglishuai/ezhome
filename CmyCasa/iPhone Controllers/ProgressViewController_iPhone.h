//
//  ProgressViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import <UIKit/UIKit.h>

#import "ProgressPopupBaseViewController.h"


@interface ProgressViewController_iPhone : ProgressPopupBaseViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
