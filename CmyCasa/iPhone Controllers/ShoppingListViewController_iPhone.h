//
//  iPhoneShoppingListViewController.h
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import <UIKit/UIKit.h>
#import "ShoppingListManager.h"

@interface ShoppingListViewController_iPhone : UIViewController<UITableViewDataSource, MFMailComposeViewControllerDelegate>


@property (strong, nonatomic) NSMutableArray* items;
@property (weak, nonatomic) DesignBaseClass* designObj;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *navigateBackPressed;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

- (IBAction)sharePressed:(id)sender;

@end
