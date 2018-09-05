//
//  ProfessionalPageViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/1/13.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"
//GAITrackedViewController
@interface ProfessionalPageViewController_iPhone : UIViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UserLogInDelegate, ProfessionalInfoCellDelegate>

@property(nonatomic) ProfessionalDO * professional;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)fillProfessionalInfo;
- (IBAction)navBack:(id)sender;
@end
