//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProfilePageBaseViewController.h"


@interface UserProfileBaseTableViewController : ProfilePageBaseViewController< UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableContent;
@property (strong, nonatomic)  UIView *internalHeaderContainer;

-(void)insertHeaderView:(UIView*)headerView;
-(UITableView*)getTableView;
-(void)placeFooterAndHeader;
@end