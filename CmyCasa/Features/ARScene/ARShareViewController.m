//
//  ARShareViewController.m
//  EZHome
//
//  Created by xiefei on 8/12/17.
//

#import "ARShareViewController.h"

@interface ARShareViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@end

@implementation ARShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.shareImageView.image = self.image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)shareBtn:(id)sender {
    
    NSArray *postItems=@[self.image];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    controller.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
//        if (activityType) {
//            NSString *message;
//            if (completed) {
//                message = NSLocalizedString(@"multi_share_all_success", nil);
//            }else{
//                message = NSLocalizedString(@"err_msg_failed_image_upload", nil);
//            }
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
//
//            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            }];
//
//            [alert addAction:ok];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
    };
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        [self presentViewController:controller animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover

        UIPopoverPresentationController *popover = controller.popoverPresentationController;
        if (popover) {
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = 0;
        }
        [self presentViewController:controller animated:YES completion:nil];
    }
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
