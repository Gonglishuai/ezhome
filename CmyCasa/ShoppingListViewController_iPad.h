//
//  ShoppingListViewController_iPad.h
//  Homestyler
//
//  Created by Dor Alon on 6/9/13.
//
//

#import <UIKit/UIKit.h>

@class ShoppingListManager;

@interface ShoppingListViewController_iPad : UIViewController<UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) DesignBaseClass* designObj;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView * loader;

-(IBAction)backPressed:(id)sender;
-(IBAction)sharePressed:(id)sender;
-(IBAction)navigateBackPressed:(id)sender;
-(void)updateData;
-(void)startBgAnimation;
@end
