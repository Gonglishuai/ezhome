//
//  ProgressPopupBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/5/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    ProgressDefault = 0,
    ProgressClear
} ProgressPopupBackgroundColor;

@interface ProgressPopupBaseViewController : UIViewController
{
@protected
    Boolean _isErrorMode;
    NSTimer* _timeoutTimer;
    int nLoadingRequsetCounter;
}

@property (weak, nonatomic) IBOutlet UILabel *lblLoading;
@property (weak, nonatomic) IBOutlet UILabel *lblLoadingTipsTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingTipIndicator;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *lblLoadingCenter;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (assign,nonatomic) ProgressPopupBackgroundColor colorStyle;


+(ProgressPopupBaseViewController*)sharedInstance;

-(void)startLoading:(UIViewController*)senderView;
-(void)stopLoading;
-(void)startLoadingWithoutText:(UIViewController *)senderView;
-(void)startLoadingTipsWithOrientation:(UIViewController*)senderView isLandscape:(BOOL)isLandscape;
-(void)setServerErrorMode;
-(void)setErrorMode: (NSString*) strLine1;
-(void)reset;

@end
