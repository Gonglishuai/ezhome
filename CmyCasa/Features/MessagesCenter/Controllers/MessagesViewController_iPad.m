//
//  MessagesViewController_iPad.m
//  Homestyler
//
//  Created by liuyufei on 5/4/18.
//

#import "MessagesViewController_iPad.h"
#import "HSPopupViewControllerHelper.h"

@interface MessagesViewController_iPad ()

@property (strong, nonatomic) HSPopupViewControllerHelper *popupHelper;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation MessagesViewController_iPad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (HSPopupViewControllerHelper *)popupHelper {
    if (_popupHelper == nil) {
        _popupHelper = [HSPopupViewControllerHelper new];
    }
    return _popupHelper;
}

- (void)presentByParentViewController:(UIViewController*)parentViewController
                             animated:(BOOL)animated
                           completion:(void (^ __nullable)(void))completion {
    [self.popupHelper presentViewController:self
                     byParentViewController:parentViewController
                              maskViewBlock:^{
                                  return self.bgView;
                              }
                           contentViewBlock:^{
                               return self.containerView;
                           }
                                   animated:animated
                                 completion:completion];
}

- (IBAction)back:(UIButton *)sender {
    [self.popupHelper dismissViewController:self animated:YES completion:^{
        if (self.delegate) {
            [self.delegate popoverViewDidDismiss];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
