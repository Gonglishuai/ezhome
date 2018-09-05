//
//  ProfilePagesMenuViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/25/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileMasterBaseViewController.h"

@protocol PRofileMasterDelegate;

@interface ProfilePagesMenuViewController_iPhone : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) ProfileTabs selectedTab;
@property(nonatomic,strong) id<PRofileMasterDelegate,ProfileCountersDelegate> ownerDelegate;
@property(nonatomic) BOOL isLoggedInUserProfile;

- (IBAction)cancelMenuSelection:(id)sender;
- (NSString *)getTitleForTabCellNum:(ProfileTabs)num;
- (void)selectRowForTab:(ProfileTabs)tabs;
- (void)refreshTableMenu;
- (void)presentForContainer:(UIViewController *)controller;

@end
